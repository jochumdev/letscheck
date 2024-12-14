import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

abstract class SearchEvent extends Equatable {}

class SearchTerm extends SearchEvent {
  final String term;

  SearchTerm({required this.term});

  @override
  List<Object> get props => [term];

  @override
  String toString() => "Search '$term'";
}

class SearchTermResult extends SearchEvent {
  final BuiltMap<String, BuiltList<cmkApi.LqlTableHostsDto>> hosts;
  final BuiltMap<String, BuiltList<cmkApi.LqlTableServicesDto>> services;

  SearchTermResult({required this.hosts, required this.services});

  @override
  List<Object> get props => [hosts, services];

  @override
  String toString() => 'Search term result';
}
