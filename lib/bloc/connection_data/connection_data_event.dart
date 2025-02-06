import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';

abstract class ConnectionDataEvent extends Equatable {}

class StartFetching extends ConnectionDataEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Start fetching';
}

class UpdateClient extends ConnectionDataEvent {
  final SettingsStateEnum action;
  final String alias;

  UpdateClient({required this.action, required this.alias});

  @override
  List<Object> get props => [action, alias];

  @override
  String toString() => "Update Client, action '$action' alias '$alias'";
}

class ConnectionData extends ConnectionDataEvent {
  final String alias;
  final cmk_api.StatsTacticalOverviewDto stats;

  final List<cmk_api.TableServicesDto> unhServices;

  ConnectionData(
      {required this.alias, required this.stats, required this.unhServices});

  @override
  List<Object> get props => [alias, stats];

  @override
  String toString() => "New view tactical_overview stats for '$alias'";
}
