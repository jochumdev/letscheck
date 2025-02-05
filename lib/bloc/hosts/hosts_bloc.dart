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
      switch (state.state!) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientFailed:
          if (state.currentAlias == alias) {
            try {
              add(HostsUpdate(action: state.state!));
            } on StateError {
              // Ignore.
            }
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
      await _fetchData();
      await _startFetching();
    });

    on<HostsUpdate>((event, emit) async {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
          await _fetchData();
          break;
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          await tickerSubscription?.cancel();
          break;
        default:
      }
    });

    on<HostsEventFetched>((event, emit) async {
      emit(HostsStateFetched(alias: event.alias, hosts: event.hosts));
    });
  }

  Future<void> _startFetching() async {
    await tickerSubscription?.cancel();
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

    if (sBloc.state.connections[alias]!.state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias]!.client!;

    try {
      try {
        final hosts = await client.getApiTableHost(filter: filter);
        add(HostsEventFetched(alias: alias, hosts: hosts));
      } on cmk_api.CheckMkBaseError catch (e) {
        sBloc.add(ConnectionFailed(alias, e));
      }
    } on StateError {
      // Ignore.
    }
  }

  void dispose() {
    tickerSubscription?.cancel();
    sBlocSubscription.cancel();
  }
}
