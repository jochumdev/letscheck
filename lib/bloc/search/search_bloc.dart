import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../settings/settings.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SettingsBloc sBloc;

  SearchBloc({required this.sBloc}) : super(const SearchStateUninitialized()) {
    on<SearchTerm>((event, emit) async {
      var hosts = <String, List<cmk_api.Host>>{};
      var services = <String, List<cmk_api.Service>>{};

      for (var alias in sBloc.state.connections.keys) {
        final connSettings = sBloc.state.connections[alias]!;
        if (connSettings.state != SettingsConnectionStateEnum.connected) {
          continue;
        }

        final client = connSettings.client!;
        try {
          final hostsResult = await client.getApiHosts(
              filter: ['{"op": "~", "left": "name", "right": "${event.term}"}']);
          final servicesResult = await client.getApiServices(
              filter: ['{"op": "~", "left": "description", "right": "${event.term}"}']);

          hosts[alias] = hostsResult;
          services[alias] = servicesResult;
        } on cmk_api.NetworkError catch (e) {
          sBloc.add(ConnectionFailed(alias, e));
        }
      }

      emit(SearchStateLoaded(hosts: hosts, services: services));
    });
  }
}
