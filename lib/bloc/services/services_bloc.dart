import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'services_state.dart';
import 'services_event.dart';
import '../settings/settings.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final String alias;
  final List<String> filter;
  final List<String> columns;
  final SettingsBloc sBloc;

  StreamSubscription sBlocSubscription;
  StreamSubscription tickerSubscription;

  ServicesBloc(
      {@required this.alias,
      @required this.filter,
      @required this.sBloc,
      this.columns = const [
        "state",
        "host_name",
        "display_name",
        "description",
        "plugin_output",
        "comments",
        "last_state_change",
      ]})
      : super(ServicesStateUninitialized()) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          if (state.latestAlias == alias) {
            add(ServicesUpdate(action: state.state));
          }
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
  Stream<ServicesState> mapEventToState(ServicesEvent event) async* {
    if (event is ServicesStartFetching) {
      await _startFetching();
    } else if (event is ServicesUpdate) {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
          await _fetchData();
          break;
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          tickerSubscription.cancel();
          break;
        default:
      }
    }

    if (event is ServicesEventFetched) {
      yield ServicesStateFetched(alias: event.alias, services: event.services);
    }
  }

  Future<void> _startFetching() async {
    if (tickerSubscription != null) {
      return;
    }

    await _fetchData();

    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
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
      final services =
          await client.lqlGetTableServices(filter: filter, columns: columns);
      add(ServicesEventFetched(alias: alias, services: services));
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
