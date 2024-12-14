import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:retry/retry.dart';
import 'settings_state.dart';
import 'settings_event.dart';
import '../serializers.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with HydratedMixin {
  final Map<String, Future<void>> _failedConnectionPoller = {};

  SettingsBloc() : super(SettingsState.init()) {
    hydrate();

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
            emit(state.rebuild((b) => b
              ..state = SettingsStateEnum.clientConnected
              ..latestAlias = alias));
          } on cmk_api.CheckMkBaseError catch (e) {
            emit(state.rebuild((b) => b
              ..connections[alias] = b.connections[alias]!.rebuild((b) => b
                ..state = SettingsConnectionStateEnum.failed
                ..error = e)));
            emit(state.rebuild((b) => b
              ..state = SettingsStateEnum.clientFailed
              ..latestAlias = alias));
          }
        }
        _updateConnectionState();
      }
    });

    on<ThemeChanged>((event, emit) async {
      emit(state.rebuild((b) => b..isLightMode = event.lightMode));
    });

    on<NewConnection>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientConnected
        ..latestAlias = event.alias));
      emit(state.rebuild((b) => b..state = SettingsStateEnum.connected));
    });

    on<UpdateConnection>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientUpdated
        ..latestAlias = event.alias));
      _updateConnectionState();
    });

    on<DeleteConnection>((event, emit) async {
      emit(state.rebuild((b) => b..connections.remove(event.alias)));
      emit(state.rebuild((b) => b
        ..state = SettingsStateEnum.clientDeleted
        ..latestAlias = event.alias));
      _updateConnectionState();
    });

    on<ConnectionFailed>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] =
            b.connections[event.alias]!.rebuild((b) => b
              ..state = SettingsConnectionStateEnum.failed
              ..error = event.error)));
      emit(state.rebuild((b) => b
        ..state = SettingsStateEnum.clientFailed
        ..latestAlias = event.alias));
      _updateConnectionState();

      _startConnectionPoller(event.alias);
    });

    on<ConnectionBack>((event, emit) async {
      emit(state.rebuild((b) => b
        ..connections[event.alias] =
            b.connections[event.alias]!.rebuild((b) => b
              ..state = SettingsConnectionStateEnum.connected
              ..error = null)));
      emit(state.rebuild((b) => b
        ..state = SettingsStateEnum.clientConnected
        ..latestAlias = event.alias));
      _updateConnectionState();
    });

    on<UpdateRefresh>((event, emit) async {
      final myState = state.state;
      emit(state.rebuild((b) => b
        ..state = SettingsStateEnum.updatedRefreshSeconds
        ..refreshSeconds = event.refreshSeconds));
      emit(state.rebuild((b) => b..state = myState));
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

  SettingsState _updateConnectionState() {
    if (state.connections.length == 0) {
      return state.rebuild((b) => b..state = SettingsStateEnum.noConnection);
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
        return state.rebuild((b) => b..state = SettingsStateEnum.uninitialized);
      case SettingsConnectionStateEnum.connected:
        return state.rebuild((b) => b..state = SettingsStateEnum.connected);
      case SettingsConnectionStateEnum.failed:
        return state.rebuild((b) => b..state = SettingsStateEnum.failed);
    }

    return state;
  }

  void _startConnectionPoller(String alias) {
    if (_failedConnectionPoller.containsKey(alias)) {
      return;
    }

    final conn = state.connections[alias]!.client!;
    _failedConnectionPoller[alias] = () async {
      await retry(conn.testConnection,
          retryIf: (e) => e is cmk_api.CheckMkBaseError);

      await _failedConnectionPoller.remove(alias);
      add(ConnectionBack(alias));
    }();
  }
}
