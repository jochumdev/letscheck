import 'dart:async';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/providers/connection/connection_util.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'services_state.dart';

class ServicesNotifier extends StateNotifier<ServicesState> {
  final Ref ref;
  final SiteAndFilterParams params;
  Timer? _refreshTimer;

  ServicesNotifier(this.ref, this.params) : super(const ServicesInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to settings changes
    ref.listen(settingsProvider, (previous, next) {
      if (next.refreshSeconds != previous?.refreshSeconds) {
        _startRefreshTimer();
      }
    });

    await _fetchData();
    _startRefreshTimer();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    if (state is ServicesLoading) return;

    final connection = ref.read(connectionProvider(params.site));
    if (connection is! ConnectionLoaded) {
      state = const ServicesError(error: 'Client not initialized');
      return;
    }

    final client = connection.client;

    state = ServicesLoading(
      services: state.services,
    );

    try {
      final services = await client.getApiServices(filter: params.filter);

      if (!mounted) return;

      final ids = getCommentIdsToFetch(state: connection, site: params.site, services: services);
      if (ids.isNotEmpty) {
        ref.read(connectionProvider(params.site).notifier).fetchComments(ids);
      }

      if (!mounted) return;

      state = ServicesLoaded(services: services);
    } on cmk_api.NetworkError catch (e) {
      if (!mounted) return;
      state = ServicesError(
        error: e.toString(),
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
    _refreshTimer?.cancel();
    super.dispose();
  }
}
