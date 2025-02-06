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
      var hosts = <String, List<cmk_api.TableHostsDto>>{};
      var services = <String, List<cmk_api.TableServicesDto>>{};

      for (var alias in sBloc.state.connections.keys) {
        final connSettings = sBloc.state.connections[alias];

        if (connSettings!.state != SettingsConnectionStateEnum.connected) {
          return;
        }

        final client = connSettings.client!;

        var terms = event.term.split('|');

        try {
          var f1 = <String>[];
          for (var t in terms) {
            f1.add(
                '{"op": "~~", "left": "name", "right": ".*${RegExp.escape(t)}.*"}');
          }
          // Search hosts
          var filter = '{"op": "or", "expr": [${f1.join(', ')}]}';
          print(filter);
          final connHosts = await client.getApiTableHost(filter: [filter]);
          hosts[alias] = connHosts;

          var f2 = <String>[];
          for (var t in terms) {
            f2.add(
                '{"op": "~~", "left": "display_name", "right": ".*${RegExp.escape(t)}.*"}');
          }
          final connServices = await client.getApiTableService(filter: [
            '{"op": "or", "expr": [${f2.join(', ')}]}',
          ]);
          services[alias] = connServices;
        } on cmk_api.NetworkError catch (e) {
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
