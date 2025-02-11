import 'dart:async';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/connection_data/connection_data_util.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'services_state.dart';

class ServicesNotifier extends StateNotifier<ServicesState> {
  final Ref ref;
  final AliasAndFilterParams params;
  Timer? _refreshTimer;
  late ProviderSubscription<AsyncValue<cmk_api.ConnectionState?>>
      _connectionStateSubscription;

  ServicesNotifier(this.ref, this.params) : super(const ServicesInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to client state changes
    _connectionStateSubscription =
        ref.listen(clientStateProvider(params.alias), (previous, next) {
      if (next.hasValue && next.value == cmk_api.ConnectionState.connected) {
        _startRefreshTimer();
        _fetchData();
      } else {
        final client = ref.read(clientProvider(params.alias));
        _refreshTimer?.cancel();
        state = ServicesError(error: client.error());
      }
    });

    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    final client = ref.read(clientProvider(params.alias));
    final clientState = ref.read(clientStateProvider(params.alias));

    if (clientState.value != cmk_api.ConnectionState.connected) {
      if (!mounted) return;
      state = ServicesError(error: client.error());
      return;
    }

    try {
      final services = await client.getApiServices(filter: params.filter);

      if (!mounted) return;

      final connectionData = ref.read(connectionDataProvider(params.alias));
      if (connectionData is ConnectionDataLoaded) {
        final ids = getCommentIdsToFetch(
            state: connectionData, alias: params.alias, services: services);
        if (ids.isNotEmpty) {
          ref
              .read(connectionDataProvider(params.alias).notifier)
              .fetchComments(ids);
        }
      }

      if (!mounted) return;

      state = ServicesLoaded(services: services);
    } on cmk_api.NetworkException catch (e) {
      if (!mounted) return;
      state = ServicesError(
        error: e,
      );
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    final settings = ref.read(settingsProvider);

    _refreshTimer = Timer.periodic(
      Duration(seconds: settings.refreshSeconds),
      (_) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _connectionStateSubscription.close();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
