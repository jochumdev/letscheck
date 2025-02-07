import 'package:equatable/equatable.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

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
  final Map<String, List<cmk_api.Host>> hosts;
  final Map<String, List<cmk_api.Service>> services;

  SearchTermResult({required this.hosts, required this.services});

  @override
  List<Object> get props => [hosts, services];

  @override
  String toString() => 'Search term result';
}
