import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

sealed class SearchState {
  final String query;
  final Map<String, Set<cmk_api.Host>> hosts;
  final Map<String, Set<cmk_api.Service>> services;
  final String? error;

  const SearchState({
    this.query = '',
    this.hosts = const {},
    this.services = const {},
    this.error,
  });
}

final class SearchInitial extends SearchState {
  const SearchInitial() : super();
}

final class SearchLoading extends SearchState {
  const SearchLoading({required super.query}) : super();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required super.query,
    required super.hosts,
    required super.services,
  });
}

final class SearchError extends SearchState {
  const SearchError({
    required super.query,
    required super.error,
  });
}