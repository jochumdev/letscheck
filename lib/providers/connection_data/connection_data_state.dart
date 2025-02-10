import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

sealed class ConnectionDataState {
  const ConnectionDataState();
}

final class ConnectionDataInitial extends ConnectionDataState {
  const ConnectionDataInitial() : super();
}

final class ConnectionDataLoaded extends ConnectionDataState {
  final cmk_api.StatsTacticalOverview stats;
  final List<cmk_api.Service> unhServices;
  final Map<int, cmk_api.Comment> comments;

  const ConnectionDataLoaded({required this.stats, required this.unhServices, required this.comments});

  ConnectionDataLoaded copyWith({
    cmk_api.StatsTacticalOverview? stats,
    List<cmk_api.Service>? unhServices,
    Map<int, cmk_api.Comment>? comments,
  }) {
    return ConnectionDataLoaded(
      stats: stats ?? this.stats,
      unhServices: unhServices ?? this.unhServices,
      comments: comments ?? this.comments,
    );
  }
}

final class ConnectionDataError extends ConnectionDataState {
  final Exception error;

  const ConnectionDataError({
    required this.error,
  });
}
