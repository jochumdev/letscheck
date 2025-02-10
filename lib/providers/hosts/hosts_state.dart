import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

sealed class HostsState {
  final List<cmk_api.Host> hosts;
  final Exception? error;

  const HostsState({
    this.hosts = const [],
    this.error,
  });
}

final class HostsInitial extends HostsState {
  const HostsInitial() : super();
}

final class HostsLoaded extends HostsState {
  const HostsLoaded({required super.hosts});
}

final class HostsError extends HostsState {
  const HostsError({
    required super.error,
    super.hosts = const [],
  });
}
