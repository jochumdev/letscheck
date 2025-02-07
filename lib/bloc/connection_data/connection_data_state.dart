import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

sealed class ConnectionDataState {
  final Map<String, cmk_api.StatsTacticalOverview> stats;
  final Map<String, List<cmk_api.Service>> unhServices;

  const ConnectionDataState({required this.stats, required this.unhServices});
}

final class ConnectionDataStateImpl extends ConnectionDataState {
  const ConnectionDataStateImpl({
    required super.stats,
    required super.unhServices,
  });
}
