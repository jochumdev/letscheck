import 'dart:async';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection/connection_util.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/services/connectivity_service.dart';
import 'package:retry/retry.dart';

import 'connection_state.dart';

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  final Ref ref;
  final String site;
  Timer? _refreshTimer;
  Timer? _retryTimer;

  ConnectionNotifier(this.ref, this.site) : super(const ConnectionInitial()) {
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

  cmk_api.Client? _getClient({bool errorClient = false}) {
    cmk_api.Client? nc;
    if (state is ConnectionLoaded) {
      nc = (state as ConnectionLoaded).client;
    } else if (errorClient && state is ConnectionError) {
      nc = (state as ConnectionError).client;
    }
    return nc;
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    final settings = ref.read(settingsProvider);

    if (settings.connections[site] == null) {
      state = ConnectionError(message: 'No such site');
      return;
    }

    final connection = settings.connections[site]!;

    var client = _getClient();
    client ??= cmk_api.Client(
      cmk_api.ClientSettings(
        baseUrl: connection.baseUrl,
        site: connection.site,
        username: connection.username,
        secret: connection.password,
        validateSsl: connection.insecure,
      ),
    );

    if (connection.wifiOnly && !await ConnectivityService.isOnWifi()) {
      state = ConnectionError(message: 'Not on WiFi, this connection is wifi only', client: client);
      _startRetry();
      return;
    }

    try {
      final stats = await client.getApiStatsTacticalOverview();
      final unhServices = await client.getApiServices(
        filter: ['{"op": "!=", "left": "state", "right": "0"}']);

      if (!mounted) return;

      if (state is ConnectionLoaded) {
        state = ConnectionLoaded(
          client: client,
          stats: stats,
          unhServices: unhServices,
          comments: (state as ConnectionLoaded).comments,
        );
      } else {
        state = ConnectionLoaded(
          client: client,
          stats: stats,
          unhServices: unhServices,
          comments: const {},
        );

        final ids = getCommentIdsToFetch(state: state as ConnectionLoaded, site: site, services: unhServices);
        if (ids.isNotEmpty) {
          fetchComments(ids);
        }
      }
    } on cmk_api.NetworkError catch (e) {
      state = ConnectionError(message: e.message, client: client, error: e);
      _startRetry();
      return;
    }
  }

  void _startRetry() {
    if (!mounted) return;

    _refreshTimer?.cancel();

    _retryTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        if (await _retry()) {
          // Retry worked.
          if (!mounted) return;

          _retryTimer?.cancel();

          if (_refreshTimer != null) {
            _startRefreshTimer();
          }
        }
      },
    );
  }

  Future<bool> _retry() async {
    return await retry(
      () async {
        final client = _getClient(errorClient: true);
        if (client == null) return false;

        final settings = ref.read(settingsProvider);
        if (settings.connections[site] == null) return false;

        final connection = settings.connections[site]!;
        final onWifi = await ConnectivityService.isOnWifi();
        if (connection.wifiOnly && !onWifi) {
          return true;
        }

        return !await client.testConnection();
      },
      retryIf: (e) {
        if (e is cmk_api.NetworkError) {
          return true;
        }
        return false;
      },
    );
  }

  void _startRefreshTimer() {
    if (!mounted) return;

    _refreshTimer?.cancel();

    final settings = ref.read(settingsProvider);
    if (settings.refreshSeconds > 0) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: settings.refreshSeconds),
        (_) => _fetchData(),
      );
    }
  }

  Future<void> refresh() async {
    await _fetchData();
  }

  Future<void> fetchComments(Set<int> ids) async {
    if (state is! ConnectionLoaded) return;

    final client = (state as ConnectionLoaded).client;

    try {
      final filter = ids.map((id) => '{"op": "=", "left": "id", "right": "$id"}').toList();
      final comments = await client.getApiComments(filter: filter);
      
      // Create a new map with existing comments
      var result = Map<int, cmk_api.Comment>.from((state as ConnectionLoaded).comments);
      // Add or update new comments
      for (var comment in comments) {
        result[comment.id] = comment;
      }

      state = (state as ConnectionLoaded).copyWith(comments: result);
    } on cmk_api.NetworkError catch (e) {
      state = ConnectionError(message: e.message, client: client, error: e);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
