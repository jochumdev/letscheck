import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmkApi;
import '../settings/settings.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SettingsBloc sBloc;

  SearchBloc(
      {@required this.sBloc})
      : super(SearchStateUninitialized());

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchTerm) {
      await _searchTerm(event.term);
    }
    if (event is SearchTermResult) {
      yield SearchStateFetched(hosts: event.hosts, services: event.services);
    }
  }

  Future<void> _searchTerm(String term) async {
    var hosts = Map<String, BuiltList<cmkApi.LqlTableHostsDto>>();
    var services = Map<String, BuiltList<cmkApi.LqlTableServicesDto>>();

    for (var alias in sBloc.state.connections.keys) {
      final connSettings = sBloc.state.connections[alias];

      if (connSettings.state !=
          SettingsConnectionStateEnum.connected) {
        return;
      }

      final client = connSettings.client;

      if (client == null) {
        // This should never happen
        return;
      }

      term = RegExp.escape(term);

      try {
        // Search hosts
        final connHosts = await client.lqlGetTableHosts(filter: ['Filter: name ~~ .*$term.*', 'Filter: address ~~ .*$term.*', 'Or: 2']);
        hosts[alias] = connHosts;
        final connServices = await client.lqlGetTableServices(filter: ['Filter: description ~~ .*$term.*']);
        services[alias] = connServices;
      } on cmkApi.CheckMkBaseError catch (e) {
        // Silently ignore these errors
        if (kDebugMode) {
          print(e);
        }
      }
    }

    add(SearchTermResult(hosts: BuiltMap(hosts), services: BuiltMap(services)));
  }
}