import 'dart:async';
import 'package:mutex/mutex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'connection_data_state.dart';
import 'connection_data_event.dart';
import '../settings/settings.dart';
import 'package:letscheck/notifications/plugin.dart';

class ConnectionDataBloc
    extends Bloc<ConnectionDataEvent, ConnectionDataState> {
  final SettingsBloc sBloc;

  Map<String, Map<String, DateTime>> knownNotifications = {};
  late StreamSubscription sBlocSubscription;
  StreamSubscription? tickerSubscription;

  final knownNotificationsLock = Mutex();

  ConnectionDataBloc({required this.sBloc})
      : super(ConnectionDataState.init()) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state!) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
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

    //
    // Start: Notifications
    //
    if (sBloc.state.connections[alias]!.notifications) {
      try {
        await knownNotificationsLock.acquire();

        if (!knownNotifications.containsKey(alias)) {
          knownNotifications[alias] = {};
        }
        var aliasKnown = knownNotifications[alias]!;

        final events = await client.lqlGetTableLogs(filter: [
          'Filter: time > ${((DateTime.now().millisecondsSinceEpoch / 1000).round() - sBloc.state.refreshSeconds)}',
          'Filter: state > ${cmk_api.svcStateOk}',
        ], columns: [
          'current_host_name',
          'current_service_display_name',
          'state',
          'plugin_output',
          'time'
        ]);

        for (var event in events) {
          final key =
              '${event.hostName}-${event.displayName}-${event.time.millisecondsSinceEpoch}';
          if (!aliasKnown.containsKey(key)) {
            sendLogNotification(conn: alias, log: event);
            aliasKnown[key] = event.time;
          }
        }

        var toOld = DateTime.now().subtract(
          Duration(seconds: sBloc.state.refreshSeconds),
        );
        var toRemove = [];
        for (var key in aliasKnown.keys) {
          if (aliasKnown[key]!.isBefore(toOld)) {
            toRemove.add(key);
          }
        }
        aliasKnown.removeWhere((key, item) => toRemove.contains(key));
      } on cmk_api.CheckMkBaseError {
        // Ignore.
      } finally {
        knownNotificationsLock.release();
      }
    }
    //
    // End: Notifications
    //

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
