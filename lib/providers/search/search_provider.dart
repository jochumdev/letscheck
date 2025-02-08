import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/providers/providers.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;

  SearchNotifier(this.ref) : super(const SearchInitial());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchInitial();
      return;
    }

    if (state is SearchLoading) return;

    state = SearchLoading(query: query);

    final settings = ref.read(settingsProvider);

    var hosts = <String, List<cmk_api.Host>>{};
    var services = <String, List<cmk_api.Service>>{};

    for (var site in settings.connections.keys) {
      final connection = ref.watch(connectionProvider(site));

      if (connection is! ConnectionLoaded) continue;

      final client = connection.client;
      try {
        final hostsResult = await client.getApiHosts(
            filter: ['{"op": "~", "left": "name", "right": "$query"}']);
        final servicesResult = await client.getApiServices(
            filter: ['{"op": "~", "left": "description", "right": "$query"}']);

        hosts[site] = hostsResult;
        services[site] = servicesResult;
      } on cmk_api.NetworkError {
        // Ignore.
      }
    }

    if (!mounted) return;

    state = SearchLoaded(
      query: query,
      hosts: hosts,
      services: services,
    );
  }
}
