import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';

abstract class HostsEvent extends Equatable {}

class HostsEventFetch extends HostsEvent {
  HostsEventFetch();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Fetch';
}

class HostsStartFetching extends HostsEvent {
  HostsStartFetching();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Start fetching';
}

class HostsEventFetched extends HostsEvent {
  final List<cmk_api.Host> hosts;

  HostsEventFetched({required this.hosts});

  @override
  List<Object> get props => [hosts];

  @override
  String toString() => "Hosts Fetched";
}

class HostsUpdate extends HostsEvent {
  final SettingsStateEnum action;

  HostsUpdate({required this.action});

  @override
  List<Object> get props => [action];

  @override
  String toString() => "HostsUpdate Client, action '$action'";
}
