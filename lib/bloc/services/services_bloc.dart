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
        case SettingsStateEnum.clientUpdated:
        case SettingsStateEnum.clientFailed:
          if (state.currentAlias == alias) {
            try {
              add(ServicesEventStartFetching());
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

    on<ServicesEventFetch>((event, emit) async {
      if (!sBloc.state.connections.containsKey(alias)) {
        return;
      }

      if (sBloc.state.connections[alias]!.state !=
          SettingsConnectionStateEnum.connected) {
        return;
      }

      try {
        final client = sBloc.state.connections[alias]!.client!;
        final services = await client.getApiServices(filter: filter);
        try {
          add(ServicesEventFetched(services: services));
        } on StateError {
          // Ignore.
        }
      } on cmk_api.NetworkError {
        // Ignore network errors
      }
    });

    on<ServicesEventFetched>((event, emit) async {
      emit(ServicesStateFetched(alias: alias, services: event.services));
    });

    on<ServicesEventStartFetching>((event, emit) async {
      // Ticker fetch
      try {
        add(ServicesEventFetch());
      } on StateError {
        // Ignore.
      }
      await _startFetching();
    });

    on<ServicesUpdate>((event, emit) async {
      switch (event.action) {
        case SettingsStateEnum.clientConnected:
      // Ticker fetch
      try {
        add(ServicesEventFetch());
      } on StateError {
        // Ignore.
      }
          break;
        case SettingsStateEnum.clientFailed:
        case SettingsStateEnum.clientDeleted:
          await tickerSubscription?.cancel();
          break;
        default:
      }
    });
  }

  Future<void> _startFetching() async {
    await tickerSubscription?.cancel();
    tickerSubscription =
        Stream.periodic(Duration(seconds: sBloc.state.refreshSeconds))
            .listen((state) async {
      // Ticker fetch
      try {
        add(ServicesEventFetch());
      } on StateError {
        // Ignore.
      }
    });
  }

  void dispose() {
    if (tickerSubscription != null) {
      tickerSubscription!.cancel();
      tickerSubscription = null;
    }
    sBlocSubscription.cancel();
  }
}
