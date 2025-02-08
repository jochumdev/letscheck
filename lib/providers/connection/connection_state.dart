import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

sealed class ConnectionState {
  const ConnectionState();
}

final class ConnectionInitial extends ConnectionState {
  const ConnectionInitial();
}

final class ConnectionLoaded extends ConnectionState {
  final cmk_api.Client client;
  final cmk_api.StatsTacticalOverview stats;
  final List<cmk_api.Service> unhServices;
  final Map<int, cmk_api.Comment> comments;

  const ConnectionLoaded({
    required this.client,
    required this.stats,
    required this.unhServices,
    required this.comments,
  });

  ConnectionLoaded copyWith({
    cmk_api.Client? client,
    cmk_api.StatsTacticalOverview? stats,
    List<cmk_api.Service>? unhServices,
    Map<int, cmk_api.Comment>? comments,
  }) {
    return ConnectionLoaded(
      client: client ?? this.client,
      stats: stats ?? this.stats,
      unhServices: unhServices ?? this.unhServices,
      comments: comments ?? this.comments,
    );
  }
}

final class ConnectionError extends ConnectionState {
  final String message;
  final cmk_api.Client? client;
  final cmk_api.NetworkError? error;

  const ConnectionError({
    required this.message,
    this.client,
    this.error,
  });
}
