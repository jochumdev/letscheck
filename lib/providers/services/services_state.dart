import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

sealed class ServicesState {
  final List<cmk_api.Service> services;
  final Exception? error;

  const ServicesState({
    this.services = const [],
    this.error,
  });
}

final class ServicesInitial extends ServicesState {
  const ServicesInitial() : super();
}

final class ServicesLoaded extends ServicesState {
  const ServicesLoaded({required super.services});
}

final class ServicesError extends ServicesState {
  const ServicesError({
    required super.error,
    super.services = const [],
  });
}
