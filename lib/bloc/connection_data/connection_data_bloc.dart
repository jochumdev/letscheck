import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'connection_data_state.dart';
import 'connection_data_event.dart';
import '../settings/settings.dart';

class ConnectionDataBloc
    extends Bloc<ConnectionDataEvent, ConnectionDataState> {
  final SettingsBloc sBloc;
  StreamSubscription sBlocSubscription;
  StreamSubscription tickerSubscription;

  ConnectionDataBloc({@required this.sBloc})
      : super(ConnectionDataState.init()) {
    sBlocSubscription = sBloc.listen((state) async {
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          add(UpdateClient(action: state.state, alias: state.latestAlias));
          break;
        case SettingsStateEnum.updatedRefreshSeconds:
          if (tickerSubscription != null) {
            tickerSubscription.cancel();
            tickerSubscription = null;
          }
          await _startFetching();
          break;
        default:
      }
    });
  }

  @override
  Stream<ConnectionDataState> mapEventToState(
      ConnectionDataEvent event) async* {
    if (event is StartFetching) {
      await _startFetching();
    } else if (event is UpdateClient) {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
          await _fetchData(event.alias);
          break;
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          yield state.rebuild((b) => b..stats.remove(event.alias));
          break;
        default:
      }
    } else if (event is NewConnectionData) {
      yield state.rebuild((b) => b
        ..stats[event.alias] = event.stats
        ..unhServices[event.alias] = event.unhServices);
    }
  }

  Future<void> _startFetching() async {
    if (tickerSubscription != null) {
      return;
    }

    // Initial fetch
    for (var alias in sBloc.state.connections.keys) {
      await _fetchData(alias);
    }

    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      for (var alias in sBloc.state.connections.keys) {
        await _fetchData(alias);
      }
    });
  }

  Future<void> _fetchData(String alias) async {
    if (!sBloc.state.connections.containsKey(alias)) {
      return;
    }

    if (sBloc.state.connections[alias].state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias].client;

    if (client == null) {
      // This should never happen
      return;
    }

    try {
      final stats = await client.lqlGetStatsTacticalOverview();
      final unhServices =
          await client.lqlGetTableServices(filter: ["services_unhandled"]);
      add(NewConnectionData(
          alias: alias, stats: stats, unhServices: unhServices));
    } on cmkApi.CheckMkBaseError catch (e) {
      sBloc.add(new ConnectionFailed(alias, e));
    }
  }

  void dispose() {
    if (tickerSubscription != null) {
      tickerSubscription.cancel();
    }
    sBlocSubscription.cancel();
  }
}
