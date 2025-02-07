import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

sealed class SearchState {
  const SearchState();
}

final class SearchStateUninitialized extends SearchState {
  const SearchStateUninitialized();
}

final class SearchStateLoaded extends SearchState {
  final Map<String, List<cmk_api.Host>> hosts;
  final Map<String, List<cmk_api.Service>> services;

  const SearchStateLoaded({
    required this.hosts,
    required this.services,
  });
}
