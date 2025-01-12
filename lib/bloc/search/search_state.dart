import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

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
  final BuiltMap<String, BuiltList<cmk_api.LqlTableHostsDto>> hosts;
  final BuiltMap<String, BuiltList<cmk_api.LqlTableServicesDto>> services;

  SearchStateFetched({required this.hosts, required this.services});

  @override
  List<Object> get props => [hosts, services];

  @override
  String toString() => 'Search fetched';
}
