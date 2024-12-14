import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;

abstract class SearchState extends Equatable {}

class SearchStateUninitialized extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchStateLoading extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchStateFetched extends SearchState {
  final BuiltMap<String, BuiltList<cmkApi.LqlTableHostsDto>> hosts;
  final BuiltMap<String, BuiltList<cmkApi.LqlTableServicesDto>> services;

  SearchStateFetched({required this.hosts, required this.services});

  @override
  List<Object> get props => [hosts, services];

  @override
  String toString() => 'Search fetched';
}
