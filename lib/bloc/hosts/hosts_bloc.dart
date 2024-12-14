import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import 'hosts_state.dart';
import 'hosts_event.dart';
import '../settings/settings.dart';

class HostsBloc extends Bloc<HostsEvent, HostsState> {
  final String alias;
  final List<String> filter;
  final SettingsBloc sBloc;

  late StreamSubscription sBlocSubscription;
  StreamSubscription? tickerSubscription;

  HostsBloc({required this.alias, required this.filter, required this.sBloc})
      : super(HostsStateUninitialized()) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state!) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          if (state.latestAlias == alias) {
            add(HostsUpdate(action: state.state!));
          }
          break;
        case SettingsStateEnum.updatedRefreshSeconds:
          if (tickerSubscription != null) {
            await tickerSubscription!.cancel();
            tickerSubscription = null;
          }
          await _startFetching();
          break;
        default:
      }
    });

    on<HostsStartFetching>((event, emit) async {
      await _startFetching();
    });

    on<HostsUpdate>((event, emit) async {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
          await _fetchData();
          break;
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          if (tickerSubscription != null) {
            await tickerSubscription!.cancel();
            tickerSubscription = null;
          }
          break;
        default:
      }
    });

    on<HostsEventFetched>((event, emit) async {
      emit(HostsStateFetched(alias: event.alias, hosts: event.hosts));
    });
  }

  Future<void> _startFetching() async {
    await _fetchData();

    tickerSubscription ??=
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

    if (sBloc.state.connections[alias]!.state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias]!.client!;

    try {
      final hosts = await client.lqlGetTableHosts(filter: filter);
      add(HostsEventFetched(alias: alias, hosts: hosts));
    } on cmkApi.CheckMkBaseError catch (e) {
      sBloc.add(ConnectionFailed(alias, e));
    }
  }

  void dispose() {
    if (tickerSubscription != null) {
      tickerSubscription!.cancel();
      tickerSubscription = null;
    }
    sBlocSubscription.cancel();
  }
}
