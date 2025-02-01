import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/notifications/plugin.dart';
import 'connection_data_state.dart';
import 'connection_data_event.dart';
import '../settings/settings.dart';

import 'package:letscheck/bg_service.dart' as bg_service;

class ConnectionDataBloc
    extends Bloc<ConnectionDataEvent, ConnectionDataState> {
  final SettingsBloc sBloc;

  late StreamSubscription sBlocSubscription;
  StreamSubscription? tickerSubscription;

  ConnectionDataBloc({required this.sBloc})
      : super(ConnectionDataState.init()) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state!) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientFailed:
          try {
            add(UpdateClient(action: state.state!, alias: state.currentAlias));
          } on StateError {
            // Ignore.
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

    on<StartFetching>((event, emit) async {
      await _startFetching();
    });

    on<UpdateClient>((event, emit) async {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientUpdated:
          await _fetchData(event.alias);
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          emit(state.rebuild((b) => b..stats.remove(event.alias)));
        default:
      }
    });

    on<ConnectionData>((event, emit) async {
      emit(state.rebuild((b) => b
        ..stats[event.alias] = event.stats
        ..unhServices[event.alias] = event.unhServices));
    });
  }

  Future<void> _startFetching() async {
    // Update the background service.
    if (Platform.isIOS || Platform.isAndroid) {
      bg_service.sendSettings(sBloc.state);
    }

    // Initial fetch
    for (var alias in sBloc.state.connections.keys) {
      try {
        add(UpdateClient(
            action: SettingsStateEnum.clientUpdated, alias: alias));
      } on StateError {
        // Ignore.
      }
    }

    tickerSubscription ??=
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      for (var alias in sBloc.state.connections.keys) {
        try {
          add(UpdateClient(
              action: SettingsStateEnum.clientUpdated, alias: alias));
        } on StateError {
          // Ignore.
        }
      }
    });
  }

  Future<void> _fetchData(String alias) async {
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
      } on cmk_api.CheckMkBaseError catch (e) {
        sBloc.add(ConnectionFailed(alias, e));
      }
    } on StateError {
      // Ignore.
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
