import 'dart:async';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letscheck/bloc/settings/settings.dart';
import 'package:letscheck/bloc/connection_data/connection_data_event.dart';
import 'package:letscheck/bloc/connection_data/connection_data_state.dart';

class ConnectionDataBloc extends Bloc<ConnectionDataEvent, ConnectionDataState> {
  final SettingsBloc sBloc;
  StreamSubscription? sBlocSubscription;
  StreamSubscription? tickerSubscription;

  ConnectionDataBloc({required this.sBloc}) : super(const ConnectionDataStateImpl(stats: {}, unhServices: {})) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          await _fetchData();
          break;
        default:
      }
    });

    on<ConnectionDataStartFetching>((event, emit) async {
      await _fetchData();
      await _startFetching();
    });

    on<ConnectionDataUpdate>((event, emit) async {
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

    on<ConnectionData>((event, emit) async {
      if (state is! ConnectionDataStateImpl) {
        emit(ConnectionDataStateImpl(
          stats: {event.alias: event.stats},
          unhServices: {event.alias: event.unhServices},
        ));
      } else {
        final currentState = state as ConnectionDataStateImpl;
        final stats = Map<String, cmk_api.StatsTacticalOverview>.from(currentState.stats);
        final unhServices = Map<String, List<cmk_api.Service>>.from(currentState.unhServices);
        
        stats[event.alias] = event.stats;
        unhServices[event.alias] = event.unhServices;

        emit(ConnectionDataStateImpl(
          stats: stats,
          unhServices: unhServices,
        ));
      }
    });
  }

  Future<void> _startFetching() async {
    await tickerSubscription?.cancel();
    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    for (var alias in sBloc.state.connections.keys) {
      if (sBloc.state.connections[alias]!.state !=
          SettingsConnectionStateEnum.connected) {
        continue;
      }

      final client = sBloc.state.connections[alias]!.client!;

      try {
        final stats = await client.getApiStatsTacticalOverview();
        final services = await client.getApiServices(
            filter: ['{"op": "!=", "left": "state", "right": "0"}']);

        add(ConnectionData(
            alias: alias, stats: stats, unhServices: services));
      } on cmk_api.NetworkError catch (e) {
        sBloc.add(ConnectionFailed(alias, e));
      }
    }
  }

  void dispose() {
    sBlocSubscription?.cancel();
    tickerSubscription?.cancel();
  }
}
