import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

abstract class HostsState extends Equatable {}

class HostsStateUninitialized extends HostsState {
  @override
  List<Object> get props => [];
}

class HostsStateFetched extends HostsState {
  final String alias;
  final BuiltList<cmk_api.TableHostsDto> hosts;

  HostsStateFetched({required this.alias, required this.hosts});

  @override
  List<Object> get props => [alias, hosts];

  @override
  String toString() => "Hosts Fetched for '$alias'";
}
