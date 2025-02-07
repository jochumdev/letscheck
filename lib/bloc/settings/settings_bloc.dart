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

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with HydratedMixin {
  final _failedConnections = <String>[];
  late Mutex mutex;
  StreamSubscription? failedConnectionsTicker;

  SettingsBloc() : super(const SettingsStateImpl(connections: {}, state: SettingsStateEnum.uninitialized, currentAlias: '', isLightMode: false, refreshSeconds: 60)) {
    hydrate();

    mutex = Mutex();

    on<AppStarted>((event, emit) async {
      if (state.state == SettingsStateEnum.uninitialized) {
        var keys = state.connections.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          final alias = keys[i];
          final connSettings = state.connections[alias]!;

          final client = cmk_api.Client(
              cmk_api.ClientSettings(baseUrl: connSettings.baseUrl, site: connSettings.site,
                  username: connSettings.username, secret: connSettings.secret,
                  validateSsl: connSettings.validateSsl));

          try {
            await client.testConnection();
            emit((state as SettingsStateImpl).copyWith(
              state: SettingsStateEnum.clientConnected,
              connections: Map.from(state.connections)
                ..update(alias, (conn) => conn.copyWith(
                    client: client, state: SettingsConnectionStateEnum.connected)),
            ));
          } on cmk_api.NetworkError {
            emit((state as SettingsStateImpl).copyWith(
              state: SettingsStateEnum.clientFailed,
              connections: Map.from(state.connections)
                ..update(alias, (conn) => conn.copyWith(
                    state: SettingsConnectionStateEnum.failed)),
            ));
          }
        }

        await _updateConnectionState(emit);

        failedConnectionsTicker ??=
            Stream.periodic(const Duration(seconds: 10)).listen((state) async {
          await _checkFailedConnections();
        });
      }
    });

    on<ThemeChanged>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: state.state,
        isLightMode: event.lightMode,
      ));
    });

    on<NewConnection>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.clientConnected,
        connections: Map.from(state.connections)
          ..[event.alias] = event.connectionSettings,
        currentAlias: event.alias,
      ));
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.connected,
      ));
    });

    on<UpdateConnection>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.clientUpdated,
        connections: Map.from(state.connections)
          ..[event.alias] = event.connectionSettings,
      ));
    });

    on<DeleteConnection>((event, emit) async {
      final connections = Map<String, SettingsStateConnection>.from(state.connections)..remove(event.alias);
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.clientDeleted,
        connections: connections,
      ));
    });

    on<ConnectionFailed>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.clientFailed,
        connections: Map.from(state.connections)
          ..update(event.alias, (conn) => conn.copyWith(
              state: SettingsConnectionStateEnum.failed)),
      ));

      await _updateConnectionState(emit);
      _failedConnections.add(event.alias);
    });

    on<ConnectionBack>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.clientConnected,
      ));
      _failedConnections.remove(event.alias);
    });

    on<UpdateRefresh>((event, emit) async {
      final myState = state.state;
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.updatedRefreshSeconds,
        refreshSeconds: event.refreshSeconds,
      ));
      emit((state as SettingsStateImpl).copyWith(
        state: myState,
      ));

      // Update the background service.
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        bg_service.sendSettings(state);
      }
    });

    on<SettingsSetCurrentAlias>((event, emit) async {
      emit((state as SettingsStateImpl).copyWith(
        state: state.state,
        currentAlias: event.alias,
      ));
    });
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) {
    final state = SettingsStateImpl.fromJson(json);

    final stateConns = state.connections;
    var conns = <String, SettingsStateConnection>{};

    stateConns.forEach((k, conn) => conns[k] = conn.copyWith(state: SettingsConnectionStateEnum.uninitialized));
    return state.copyWith(state: SettingsStateEnum.uninitialized, connections: conns);
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return state.toJson();
  }

  Future<void> _updateConnectionState(Emitter<SettingsState> emit) async {
    await failedConnectionsTicker?.cancel();

    // If we have no connections, set the state to noConnection.
    if (state.connections.isEmpty) {
      emit((state as SettingsStateImpl).copyWith(
        state: SettingsStateEnum.noConnection,
      ));
      return;
    }

    var cState = SettingsConnectionStateEnum.uninitialized;
    for (var alias in state.connections.keys) {
      var conn = state.connections[alias]!;
      if (conn.state == SettingsConnectionStateEnum.connected) {
        cState = SettingsConnectionStateEnum.connected;
        break;
      }
      if (conn.state == SettingsConnectionStateEnum.failed) {
        cState = SettingsConnectionStateEnum.failed;
      }
    }

    switch (cState) {
      case SettingsConnectionStateEnum.uninitialized:
        emit((state as SettingsStateImpl).copyWith(
          state: SettingsStateEnum.uninitialized,
        ));
      case SettingsConnectionStateEnum.connected:
        emit((state as SettingsStateImpl).copyWith(
          state: SettingsStateEnum.connected,
        ));
      case SettingsConnectionStateEnum.failed:
        emit((state as SettingsStateImpl).copyWith(
          state: SettingsStateEnum.failed,
        ));
      default:
    }

    // Update the background service.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
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
          await retry(
            () => conn.testConnection(),
            retryIf: (e) {
              if (e is cmk_api.NetworkError) {
                return true;
              }
              print("Other error in _checkFailedConnections");
              return false;
            },
          );
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
