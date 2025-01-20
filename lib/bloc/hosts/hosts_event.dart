import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';

abstract class HostsEvent extends Equatable {}

class HostsStartFetching extends HostsEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Start fetching';
}

class HostsEventFetched extends HostsEvent {
  final String alias;
  final BuiltList<cmk_api.TableHostsDto> hosts;

  HostsEventFetched({required this.alias, required this.hosts});

  @override
  List<Object> get props => [alias, hosts];

  @override
  String toString() => "Hosts Fetched for '$alias'";
}

class HostsUpdate extends HostsEvent {
  final SettingsStateEnum action;

  HostsUpdate({required this.action});

  @override
  List<Object> get props => [action];

  @override
  String toString() => "HostsUpdate Client, action '$action'";
}
