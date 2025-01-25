import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'services_state.dart';
import 'services_event.dart';
import '../settings/settings.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final String alias;
  final List<String> filter;
  final SettingsBloc sBloc;

  late StreamSubscription sBlocSubscription;
  StreamSubscription? tickerSubscription;

  ServicesBloc({required this.alias, required this.filter, required this.sBloc})
      : super(ServicesStateUninitialized()) {
    sBlocSubscription = sBloc.stream.listen((state) async {
      switch (state.state) {
        case SettingsStateEnum.clientConnected:
        case SettingsStateEnum.clientDeleted:
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          if (state.currentAlias == alias) {
            try {
              add(ServicesUpdate(action: state.state!));
            } on StateError {
              // Ignore.
            }
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

    on<ServicesStartFetching>((event, emit) async {
      await _startFetching();
    });

    on<ServicesUpdate>((event, emit) async {
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

    on<ServicesEventFetched>((event, emit) async {
      emit(ServicesStateFetched(alias: event.alias, services: event.services));
    });
  }

  Future<void> _startFetching() async {
    try {
      add(ServicesUpdate(action: sBloc.state.state!));
    } on StateError {
      // Ignore.
    }

    tickerSubscription ??=
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      try {
        add(ServicesUpdate(action: sBloc.state.state!));
      } on StateError {
        // Ignore.
      }
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
        final services = await client.getApiTableService(filter: filter);
        add(ServicesEventFetched(alias: alias, services: services));
      } on cmk_api.CheckMkBaseError catch (e) {
        sBloc.add(ConnectionFailed(alias, e));
      }
    } on StateError {
      // Ignore
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
