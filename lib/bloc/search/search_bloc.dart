import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SettingsBloc sBloc;

  SearchBloc({required this.sBloc}) : super(SearchStateUninitialized()) {
    on<SearchTerm>((event, emit) async {
      var hosts = <String, BuiltList<cmk_api.TableHostsDto>>{};
      var services = <String, BuiltList<cmk_api.TableServicesDto>>{};

      for (var alias in sBloc.state.connections.keys) {
        final connSettings = sBloc.state.connections[alias];

        if (connSettings!.state != SettingsConnectionStateEnum.connected) {
          return;
        }

        final client = connSettings.client!;

        var term = RegExp.escape(event.term);

        try {
          // Search hosts
          final connHosts = await client.getApiTableHost(filter: [
            '{"op": "or", "expr": [{"op": "~~", "left": "name", "right": ".*$term.*"}, {"op": "~~", "left": "address", "right": ".*$term.*"}]}',
          ]);
          hosts[alias] = connHosts;
          final connServices = await client.getApiTableService(filter: [
            '{"op": "or", "expr": [{"op": "~~", "left": "display_name", "right": ".*$term.*"}, {"op": "~~", "left": "description", "right": ".*$term.*"}]}',
          ]);
          services[alias] = connServices;
        } on cmk_api.CheckMkBaseError catch (e) {
          // Silently ignore these errors
          if (kDebugMode) {
            print(e);
          }
        }
      }

      add(SearchTermResult(
          hosts: BuiltMap(hosts), services: BuiltMap(services)));
    });

    on<SearchTermResult>((event, emit) async {
      emit(SearchStateFetched(hosts: event.hosts, services: event.services));
    });
  }
}
