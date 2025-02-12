import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/providers.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;

  SearchNotifier(this.ref) : super(const SearchInitial());

  Future<void> search(String query) async {
    if (!mounted) return;

    if (query.isEmpty) {
      state = const SearchInitial();
      return;
    }

    if (state is SearchLoading) return;

    state = SearchLoading(query: query);

    final settings = ref.read(settingsProvider);

    var hosts = <String, Set<cmk_api.Host>>{};
    var services = <String, Set<cmk_api.Service>>{};

    final querySplit = query.split('|');

    for (final part in querySplit) {
      if (part.isEmpty) continue;

      for (var alias in settings.connections.map((c) => c.alias)) {
        final client = await ref.read(clientProvider(alias).future);
        final clientState = ref.read(clientStateProvider(alias));

        if (!mounted) return;

        if (clientState.value != cmk_api.ConnectionState.connected) {
          continue;
        }

        try {
          final hostsResult = await client.getApiHosts(
              filter: ['{"op": "~~", "left": "name", "right": "$part"}']);
          final servicesResult = await client.getApiServices(filter: [
            '{"op": "~~", "left": "description", "right": "$part"}'
          ]);

          if (hosts.containsKey(alias)) {
            hosts[alias]!.addAll(hostsResult);
          } else {
            hosts[alias] = hostsResult.toSet();
          }
          if (services.containsKey(alias)) {
            services[alias]!.addAll(servicesResult);
          } else {
            services[alias] = servicesResult.toSet();
          }
        } on cmk_api.NetworkException {
          // Ignore.
        }
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
