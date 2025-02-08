import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

sealed class ServicesState {
  final List<cmk_api.Service> services;
  final String? error;

  const ServicesState({
    this.services = const [],
    this.error,
  });
}

final class ServicesInitial extends ServicesState {
  const ServicesInitial() : super();
}

final class ServicesLoading extends ServicesState {
  const ServicesLoading({super.services});
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
