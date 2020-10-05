import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'package:retry/retry.dart';
import 'settings_state.dart';
import 'settings_event.dart';
import '../serializers.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with HydratedMixin {
  Map<String, Future<void>> _failedConnectionPoller = {};

  SettingsBloc() : super(SettingsState.init()) {
    hydrate();
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) {
    var state = serializers.deserializeWith(SettingsState.serializer, json);
    state = state.rebuild((b) {
      b
        ..state = SettingsStateEnum.uninitialized
        ..refreshSeconds = state.refreshSeconds == null ? 60 : b.refreshSeconds;
      state.connections.forEach((k, v) {
        b
          ..connections[k] = v.rebuild(
              (c) => c.state = SettingsConnectionStateEnum.uninitialized);
      });
    });

    return state;
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return serializers.serializeWith(SettingsState.serializer, state);
  }

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is AppStarted && state.state == SettingsStateEnum.uninitialized) {
      var keys = state.connections.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        final alias = keys[i];
        var s = state.connections[alias];
        var client = new cmkApi.Client(new cmkApi.ClientSettings(
            baseUrl: s.baseUrl,
            site: s.site,
            username: s.username,
            secret: s.secret,
            validateSsl: s.validateSsl));

        try {
          await client.testConnection();
          yield state.rebuild((b) => b
            ..connections[alias] = b.connections[alias].rebuild((b) => b
              ..state = SettingsConnectionStateEnum.connected
              ..client = client
              ..error = null));
          yield state.rebuild((b) => b
            ..state = SettingsStateEnum.clientConnected
            ..latestAlias = alias);
        } on cmkApi.CheckMkBaseError catch (e) {
          yield state.rebuild((b) => b
            ..connections[alias] = b.connections[alias].rebuild((b) => b
              ..state = SettingsConnectionStateEnum.failed
              ..error = e));
          yield state.rebuild((b) => b
            ..state = SettingsStateEnum.clientFailed
            ..latestAlias = alias);
        }
      }
      yield _updateConnectionState();
    }

    if (event is ThemeChanged) {
      yield state.rebuild((b) => b..isLightMode = event.lightMode);
    }

    if (event is NewConnection) {
      yield state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientConnected
        ..latestAlias = event.alias);
      yield state.rebuild((b) => b
        ..state = SettingsStateEnum.connected);
    }

    if (event is UpdateConnection) {
      yield state.rebuild((b) => b
        ..connections[event.alias] = event.connectionSettings
        ..state = SettingsStateEnum.clientUpdated
        ..latestAlias = event.alias);
      yield _updateConnectionState();
    }

    if (event is DeleteConnection) {
      yield state.rebuild((b) => b..connections.remove(event.alias));
      yield state.rebuild((b) => b
        ..state = SettingsStateEnum.clientDeleted
        ..latestAlias = event.alias);
      yield _updateConnectionState();
    }

    if (event is ConnectionFailed) {
      yield state.rebuild((b) => b
        ..connections[event.alias] = b.connections[event.alias].rebuild((b) => b
          ..state = SettingsConnectionStateEnum.failed
          ..error = event.error));
      yield state.rebuild((b) => b
        ..state = SettingsStateEnum.clientFailed
        ..latestAlias = event.alias);
      yield _updateConnectionState();

      _startConnectionPoller(event.alias);
    }

    if (event is ConnectionBack) {
      yield state.rebuild((b) => b
        ..connections[event.alias] = b.connections[event.alias].rebuild((b) => b
          ..state = SettingsConnectionStateEnum.connected
          ..error = null));
      yield state.rebuild((b) => b
        ..state = SettingsStateEnum.clientConnected
        ..latestAlias = event.alias);
      yield _updateConnectionState();
    }

    if (event is UpdateRefresh) {
      final myState = state.state;
      yield state.rebuild((b) => b
        ..state = SettingsStateEnum.updatedRefreshSeconds
        ..refreshSeconds = event.refreshSeconds);
      yield state.rebuild((b) => b..state = myState);
    }
  }

  SettingsState _updateConnectionState() {
    if (state.connections.length == 0) {
      return state.rebuild((b) => b..state = SettingsStateEnum.noConnection);
    }

    var cState = SettingsConnectionStateEnum.uninitialized;
    state.connections.forEach((alias, conn) {
      // Don't set uninitialised and don't reset connected back
      if (conn.state != SettingsConnectionStateEnum.uninitialized &&
          cState != SettingsConnectionStateEnum.connected) {
        cState = conn.state;
      }
    });

    switch (cState) {
      case SettingsConnectionStateEnum.uninitialized:
        return state.rebuild((b) => b..state = SettingsStateEnum.uninitialized);
        break;
      case SettingsConnectionStateEnum.connected:
        return state.rebuild((b) => b..state = SettingsStateEnum.connected);
        break;
      case SettingsConnectionStateEnum.failed:
        return state.rebuild((b) => b..state = SettingsStateEnum.failed);
        break;
    }

    return state;
  }

  void _startConnectionPoller(String alias) {
    if (_failedConnectionPoller.containsKey(alias)) {
      return;
    }

    final conn = state.connections[alias].client;
    _failedConnectionPoller[alias] = () async {
      await retry(conn.testConnection,
          retryIf: (e) => e is cmkApi.CheckMkBaseError);

      _failedConnectionPoller.remove(alias);
      add(ConnectionBack(alias));
    }();
  }
}
