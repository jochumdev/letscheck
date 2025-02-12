import 'dart:async';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'hosts_state.dart';

class HostsNotifier extends StateNotifier<HostsState> {
  final Ref ref;
  final AliasAndFilterParams params;
  Timer? _refreshTimer;
  late ProviderSubscription<AsyncValue<cmk_api.ConnectionState?>>
      _connectionStateSubscription;

  HostsNotifier(this.ref, this.params) : super(const HostsInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to client state changes
    _connectionStateSubscription =
        ref.listen(clientStateProvider(params.alias), (previous, next) async {
      if (next.hasValue && next.value == cmk_api.ConnectionState.connected) {
        _startRefreshTimer();
        await _fetchData();
      } else {
        final client = await ref.read(clientProvider(params.alias).future);
        _refreshTimer?.cancel();
        state = HostsError(error: client.error());
      }
    });

    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    final client = await ref.read(clientProvider(params.alias).future);
    final clientState = ref.read(clientStateProvider(params.alias));

    if (clientState.value != cmk_api.ConnectionState.connected) {
      if (!mounted) return;
      state = HostsError(error: client.error());
      return;
    }

    try {
      final hosts = await client.getApiHosts(filter: params.filter);

      if (!mounted) return;

      state = HostsLoaded(hosts: hosts);
    } on Exception catch (e) {
      if (!mounted) return;
      state = HostsError(
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
