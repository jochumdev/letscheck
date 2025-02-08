import 'dart:async';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'hosts_state.dart';

class HostsNotifier extends StateNotifier<HostsState> {
  final Ref ref;
  final SiteAndFilterParams params;
  Timer? _refreshTimer;

  HostsNotifier(this.ref, this.params)
      : super(const HostsInitial()) {
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

    final connection = ref.watch(connectionProvider(params.site));
    if (connection is! ConnectionLoaded) {
      state = const HostsError(error: 'Client not initialized');
      return;
    }

    final client = connection.client;

    try {
      final hosts = await client.getApiHosts(filter: params.filter);

      if (!mounted) return;

      state = HostsLoaded(hosts: hosts);
    } on cmk_api.NetworkError catch (e) {
      if (!mounted) return;
      state = HostsError(
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
