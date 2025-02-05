import 'package:flutter/material.dart';

import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;

import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../widget/hosts_list_widget.dart';
import '../../widget/center_loading_widget.dart';

class HostsScreen extends StatefulWidget {
  final String alias;
  final String filter;

  HostsScreen({required this.alias, required this.filter});

  @override
  HostsScreenState createState() => HostsScreenState(
        alias: alias,
        filter: filter,
      );
}

class HostsScreenState extends State<HostsScreen> with BaseSlimScreenState {
  final String alias;
  final String filter;

  HostsScreenState({required this.alias, required this.filter});

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Hosts';
    switch (filter) {
      case 'all':
        title = "$alias Hosts";
        break;
      default:
        title = "$alias Hosts $filter";
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    var myFilters = <String>[];
    switch (filter) {
      case 'problems':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStateDown}"}');
        break;
      case 'unhandled':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStateUnreachable}"}');
        break;
      case 'stale':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStatePending}"}');
        break;
      case 'all':
        break;
      default:
        if (filter.isNotEmpty) {
          myFilters.add(filter);
        }
    }

    return BlocProvider<HostsBloc>(
      create: (context) =>
          HostsBloc(alias: alias, filter: myFilters, sBloc: sBloc)
            ..add(HostsStartFetching()),
      child: BlocBuilder<HostsBloc, HostsState>(
        builder: (context, state) {
          final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
          if (state is HostsStateFetched) {
            return Column(
              children: [
                SiteStatsWidget(alias: alias, state: cBloc.state),
                Expanded(
                    child: HostsListWidget(alias: alias, hosts: state.hosts)),
              ],
            );
          } else {
            return Column(
              children: [
                SiteStatsWidget(alias: alias, state: cBloc.state),
                Expanded(child: CenterLoadingWidget()),
              ],
            );
          }
        },
      ),
    );
  }
}
