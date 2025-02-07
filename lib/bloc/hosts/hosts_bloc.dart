import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
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
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          try {
            add(HostsEventFetch());
          } on StateError {
            // Ignore.
          }
          break;
        case SettingsStateEnum.updatedRefreshSeconds:
          await _startFetching();
          break;
        case SettingsStateEnum.clientDeleted:
          await tickerSubscription?.cancel();
          break;
        default:
      }
    });

    on<HostsStartFetching>((event, emit) async {
      try {
        add(HostsEventFetch());
      } on StateError {
        // Ignore.
      }
      await _startFetching();
    });

    on<HostsEventFetch>((event, emit) async {
      if (!sBloc.state.connections.containsKey(alias)) {
        return;
      }

      if (sBloc.state.connections[alias]!.state !=
          SettingsConnectionStateEnum.connected) {
        return;
      }

      try {
        final client = sBloc.state.connections[alias]!.client!;
        final hosts = await client.getApiHosts(filter: filter);
        add(HostsEventFetched(hosts: hosts));
      } on cmk_api.NetworkError catch (e) {
        sBloc.add(ConnectionFailed(alias, e));
      }
    });

    on<HostsEventFetched>((event, emit) async {
      emit(HostsStateFetched(alias: alias, hosts: event.hosts));
    });
  }

  Future<void> _startFetching() async {
    await tickerSubscription?.cancel();
    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      add(HostsEventFetch());
    });
  }

  void dispose() {
    tickerSubscription?.cancel();
    sBlocSubscription.cancel();
  }
}
