import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'hosts_state.dart';
import 'hosts_event.dart';
import '../settings/settings.dart';

class HostsBloc extends Bloc<HostsEvent, HostsState> {
  final String alias;
  final List<String> filter;
  final SettingsBloc sBloc;

  StreamSubscription sBlocSubscription;
  StreamSubscription tickerSubscription;

  HostsBloc(
      {@required this.alias, @required this.filter, @required this.sBloc})
      : super(HostsStateUninitialized()) {
    sBlocSubscription = sBloc.listen((state) async {
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          if (state.latestAlias == alias) {
            add(HostsUpdate(
                action: state.state));
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
  Stream<HostsState> mapEventToState(HostsEvent event) async* {
    if (event is HostsStartFetching) {
      await _startFetching();
    } else if (event is HostsUpdate) {
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

    if (event is HostsEventFetched) {
      yield HostsStateFetched(alias: event.alias, hosts: event.hosts);
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
      final hosts = await client.lqlGetTableHosts(filter: filter);
      add(HostsEventFetched(alias: alias, hosts: hosts));
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
