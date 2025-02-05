import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:mutex/mutex.dart';
import 'package:retry/retry.dart';

import 'package:letscheck/bg_service.dart' as bg_service;
import 'settings_state.dart';
import 'settings_event.dart';
import '../serializers.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with HydratedMixin {
  final _failedConnections = <String>[];

  late Mutex mutex;
  StreamSubscription? failedConnectionsTicker;

  SettingsBloc() : super(SettingsState.init()) {
    hydrate();

    mutex = Mutex();

    on<AppStarted>((event, emit) async {
      if (state.state == SettingsStateEnum.uninitialized) {
        var keys = state.connections.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          final alias = keys[i];
          var s = state.connections[alias]!;
          var client = cmk_api.Client(cmk_api.ClientSettings(
              baseUrl: s.baseUrl,
              site: s.site,
              username: s.username,
              secret: s.secret,
              validateSsl: s.validateSsl));

          try {
            await client.testConnection();
            emit(state.rebuild((b) => b
              ..connections[alias] = b.connections[alias]!.rebuild((b) => b
                ..state = SettingsConnectionStateEnum.connected
                ..client = client
                ..error = null)));
            emit(state
                .rebuild((b) => b..state = SettingsStateEnum.clientConnected));
          } on cmk_api.CheckMkBaseError catch (e) {
            emit(state.rebuild((b) => b
              ..connections[alias] = b.connections[alias]!.rebuild((b) => b
                ..state = SettingsConnectionStateEnum.failed
                ..error = e)));
            emit(state
                .rebuild((b) => b..state = SettingsStateEnum.clientFailed));
          }
        }
        await _updateConnectionState(emit);
      }

      failedConnectionsTicker ??=
          Stream.periodic(Duration(seconds: 10)).listen((state) async {
        await _checkFailedConnections();
      });
    });

    on<ThemeChanged>((event, emit) async {
      emit(state.rebuild((b) => b..isLightMode = event.lightMode));
    });

    on<NewConnection>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientConnected));
      emit(state.rebuild((b) => b..state = SettingsStateEnum.connected));
    });

    on<UpdateConnection>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientUpdated));
      await _updateConnectionState(emit);
    });

    on<DeleteConnection>((event, emit) async {
      emit(state.rebuild((b) => b..connections.remove(event.alias)));
      emit(state.rebuild((b) => b..state = SettingsStateEnum.clientDeleted));
      await _updateConnectionState(emit);
    });

    on<ConnectionFailed>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] =
            b.connections[event.alias]!.rebuild((b) => b
              ..state = SettingsConnectionStateEnum.failed
              ..error = event.error)));
      emit(state.rebuild((b) => b..state = SettingsStateEnum.clientFailed));
      await _updateConnectionState(emit);

      _failedConnections.add(event.alias);
    });

    on<ConnectionBack>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] =
            b.connections[event.alias]!.rebuild((b) => b
              ..state = SettingsConnectionStateEnum.connected
              ..error = null)));
      emit(state.rebuild((b) => b..state = SettingsStateEnum.clientConnected));
      await _updateConnectionState(emit);

      _failedConnections.remove(event.alias);
    });

    on<UpdateRefresh>((event, emit) async {
      final myState = state.state;
      emit(state.rebuild((b) => b
        ..state = SettingsStateEnum.updatedRefreshSeconds
        ..refreshSeconds = event.refreshSeconds));
      emit(state.rebuild((b) => b..state = myState));

      // Update the background service.
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        bg_service.sendSettings(state);
      }
    });

    on<SettingsSetCurrentAlias>((event, emit) async {
      emit(state.rebuild((b) => b..currentAlias = event.alias));
    });
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) {
    var state = serializers.deserializeWith(SettingsState.serializer, json)!;
    state = state.rebuild((b) {
      b
        ..state = SettingsStateEnum.uninitialized
        ..refreshSeconds = b.refreshSeconds;
      state.connections.forEach((k, v) {
        b.connections[k] = v.rebuild(
            (c) => c.state = SettingsConnectionStateEnum.uninitialized);
      });
    });

    return state;
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return serializers.serializeWith(SettingsState.serializer, state)
        as Map<String, dynamic>;
  }

  Future<void> _updateConnectionState(Emitter<SettingsState> emit) async {
    if (state.connections.length == 0) {
      // Update the background service.
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        bg_service.sendSettings(state);
      }

      emit(state.rebuild((b) => b..state = SettingsStateEnum.noConnection));
    }

    var cState = SettingsConnectionStateEnum.uninitialized;
    state.connections.forEach((alias, conn) {
      // Don't set uninitialized and don't reset connected back
      if (conn.state != SettingsConnectionStateEnum.uninitialized &&
          cState != SettingsConnectionStateEnum.connected) {
        cState = conn.state!;
      }
    });

    switch (cState) {
      case SettingsConnectionStateEnum.uninitialized:
        emit(state.rebuild((b) => b..state = SettingsStateEnum.uninitialized));
      case SettingsConnectionStateEnum.connected:
        emit(state.rebuild((b) => b..state = SettingsStateEnum.connected));
      case SettingsConnectionStateEnum.failed:
        emit(state.rebuild((b) => b..state = SettingsStateEnum.failed));
    }

    // Update the background service.
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      bg_service.sendSettings(state);
    }
  }

  Future<void> _checkFailedConnections() async {
    try {
      await mutex.acquire();

      if (_failedConnections.isEmpty) {
        return;
      }

      for (final alias in _failedConnections) {
        final conn = state.connections[alias]!.client!;

        try {
          await retry(conn.testConnection, retryIf: (e) {
            if (e is cmk_api.CheckMkBaseError) {
              return true;
            }

            print("Other error in _checkFailedConnections");
            return false;
          });
          try {
            add(ConnectionBack(alias));
          } on StateError {
            // Ignore.
          }
        } finally {
          // Ignore.
        }
      }
    } finally {
      mutex.release();
    }
  }

  void dispose() {
    failedConnectionsTicker?.cancel();
  }
}
