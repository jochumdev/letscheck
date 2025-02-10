import 'dart:async';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/connection_data/connection_data_util.dart';
import 'package:letscheck/providers/providers.dart';

class ConnectionDataNotifier extends StateNotifier<ConnectionDataState> {
  final Ref ref;
  final String alias;
  Timer? _refreshTimer;
  late ProviderSubscription<AsyncValue<cmk_api.ConnectionState?>> _connectionStateSubscription;

  ConnectionDataNotifier(this.ref, this.alias)
      : super(const ConnectionDataInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to client state changes
    _connectionStateSubscription = ref.listen(clientStateProvider(alias), (previous, next) async {
      print('${alias}: ${next.value}');
      if (next.value == cmk_api.ConnectionState.connected) {
        _startRefreshTimer();
        await _fetchData();
      } else {
        final client = ref.read(clientProvider(alias));
        _refreshTimer?.cancel();
        state = ConnectionDataError(error: client.error());
      }
    });

    // Initial fetch
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    final client = ref.read(clientProvider(alias));
    final clientState = ref.read(clientStateProvider(alias));

    if (clientState.value != cmk_api.ConnectionState.connected) {
      if (!mounted) return;
      state = ConnectionDataError(error: client.error());
      return;
    }

    try {
      final stats = await client.getApiStatsTacticalOverview();
      final unhServices = await client.getApiServices(
        filter: ['{"op": "!=", "left": "state", "right": "0"}']);

      if (!mounted) return;

      if (state is ConnectionDataLoaded) {
        state = ConnectionDataLoaded(
          stats: stats,
          unhServices: unhServices,
          comments: (state as ConnectionDataLoaded).comments,
        );
      } else {
        state = ConnectionDataLoaded(
          stats: stats,
          unhServices: unhServices,
          comments: const {},
        );

        final ids = getCommentIdsToFetch(state: state as ConnectionDataLoaded, site: alias, services: unhServices);
        if (ids.isNotEmpty) {
          fetchComments(ids);
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;
      state = ConnectionDataError(error: e);
    }
  }

  Future<void> fetchComments(Set<int> ids) async {
    if (state is! ConnectionDataLoaded) return;

    final client = ref.read(clientProvider(alias));

    try {
      final filter = ids.map((id) => '{"op": "=", "left": "id", "right": "$id"}').toList();
      final comments = await client.getApiComments(filter: filter);
      
      if (!mounted) return;

      // Create a new map with existing comments
      var result = Map<int, cmk_api.Comment>.from((state as ConnectionDataLoaded).comments);
      // Add or update new comments
      for (var comment in comments) {
        result[comment.id] = comment;
      }

      state = (state as ConnectionDataLoaded).copyWith(comments: result);
    } on Exception catch (e) {
      if (!mounted) return;
      state = ConnectionDataError(error: e);
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    final settings = ref.read(settingsProvider);
    if (settings.refreshSeconds > 0) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: settings.refreshSeconds),
        (_) => _fetchData(),
      );
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription.close();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
