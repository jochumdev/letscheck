import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

abstract class ServicesState extends Equatable {}

class ServicesStateUninitialized extends ServicesState {
  @override
  List<Object> get props => [];
}

class ServicesStateFetched extends ServicesState {
  final String alias;
  final BuiltList<cmkApi.LqlTableServicesDto> services;

  ServicesStateFetched({required this.alias, required this.services});

  @override
  List<Object> get props => [alias, services];

  @override
  String toString() => "Services Fetched for '$alias'";
}
