import 'dart:async';
import 'dart:io' show Platform;

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/notifications/plugin.dart';
import 'connection_data_state.dart';
import 'connection_data_event.dart';
import '../settings/settings.dart';

class ConnectionDataBloc
    extends Bloc<ConnectionDataEvent, ConnectionDataState> {
  final SettingsBloc sBloc;
  final Set<String> aliases = {};

  late StreamSubscription sBlocSubscription;
  StreamSubscription? tickerSubscription;

  ConnectionDataBloc({required this.sBloc})
      : super(ConnectionDataState.init()) {
    for (final alias in sBloc.state.connections.keys) {
      aliases.add(alias);
    }

    sBlocSubscription = sBloc.stream.listen((state) async {
      for (final alias in sBloc.state.connections.keys) {
        switch (state.state!) {
          case SettingsStateEnum.clientConnected:
          case SettingsStateEnum.clientFailed:
            try {
              add(UpdateClient(action: state.state!, alias: alias));
            } on StateError {
              // Ignore.
            }
            break;
          case SettingsStateEnum.updatedRefreshSeconds:
            await _startFetching();
            break;
          case SettingsStateEnum.clientDeleted:
            aliases.remove(alias);
            tickerSubscription?.cancel();
            break;
          default:
        }
      }
    });

    on<StartFetching>((event, emit) async {
      await _fetchData();
      await _startFetching();
    });

    on<UpdateClient>((event, emit) async {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
          await _fetchDataForAlias(event.alias);
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          emit(state.rebuild((b) => b..stats.remove(event.alias)));
        default:
      }
    });

    on<ConnectionData>((event, emit) async {
      emit(state.rebuild((b) => b
        ..stats[event.alias] = event.stats
        ..unhServices[event.alias] = BuiltList<cmk_api.TableServicesDto>.from(event.unhServices)));
    });
  }

  Future<void> _startFetching() async {
    tickerSubscription?.cancel();
    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    for (final alias in aliases) {
      await _fetchDataForAlias(alias);
    }
  }

  Future<void> _fetchDataForAlias(String alias) async {
    if (!sBloc.state.connections.containsKey(alias)) {
      return;
    }

    if (sBloc.state.connections[alias]!.state !=
        SettingsConnectionStateEnum.connected) {
      return;
    }

    final client = sBloc.state.connections[alias]!.client!;

    // Send Notifications if not on mobile. Mobile uses as background service.
    if (!kIsWeb &&
        !Platform.isIOS &&
        !Platform.isAndroid &&
        sBloc.state.connections[alias]!.notifications) {
      await sendNotificationsForConnection(
        conn: alias,
        client: client,
        refreshSeconds: sBloc.state.refreshSeconds,
      );
    }

    try {
      try {
        final stats = await client.getApiStatsTacticalOverview();
        final unhServices = await client.getApiTableService(filter: [
          '{"op": ">", "left": "state", "right": "${cmk_api.svcStateOk}"}'
        ]);

        add(ConnectionData(
            alias: alias, stats: stats, unhServices: unhServices));
      } on cmk_api.NetworkError catch (e) {
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
