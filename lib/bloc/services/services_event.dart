import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import '../settings/settings.dart';

abstract class ServicesEvent extends Equatable {}

class ServicesStartFetching extends ServicesEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Start fetching';
}

class ServicesEventFetched extends ServicesEvent {
  final String alias;
  final BuiltList<cmkApi.LqlTableServicesDto> services;

  ServicesEventFetched({required this.alias, required this.services});

  @override
  List<Object> get props => [alias, services];

  @override
  String toString() => "Services Fetched for '$alias'";
}

class ServicesUpdate extends ServicesEvent {
  final SettingsStateEnum action;

  ServicesUpdate({required this.action});

  @override
  List<Object> get props => [action];

  @override
  String toString() => "ServicesUpdate Client, action '$action'";
}
