import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';

abstract class ServicesEvent extends Equatable {}

class ServicesEventStartFetching extends ServicesEvent {
  ServicesEventStartFetching();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Start fetching';
}


class ServicesEventFetch extends ServicesEvent {
  ServicesEventFetch();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Fetch';
}

class ServicesEventFetched extends ServicesEvent {
  final List<cmk_api.Service> services;

  ServicesEventFetched({required this.services});

  @override
  List<Object> get props => [services];

  @override
  String toString() => "Services Fetched";
}

class ServicesUpdate extends ServicesEvent {
  final SettingsStateEnum action;

  ServicesUpdate({required this.action});

  @override
  List<Object> get props => [action];

  @override
  String toString() => "ServicesUpdate Client, action '$action'";
}
