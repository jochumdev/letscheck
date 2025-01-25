import 'package:flutter/material.dart';
import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import '../../global_router.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../widget/hosts_list_widget.dart';
import '../../widget/center_loading_widget.dart';

class HostsScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeHosts,
      uri: '/conn/{alias}/hosts/{filter}',
      lastArgOptional: true,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => HostsScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = HostsScreen.route.extractNamedArgs(context);
    var title = 'Hosts';
    if (groups.containsKey('alias')) {
      if (groups.containsKey('filter')) {
        switch (groups['filter']) {
          case 'all':
            title = "${groups["alias"]} Hosts";
            break;
          default:
            title = "${groups["alias"]} Hosts ${groups["filter"]}";
        }
      } else {
        title = "${groups["alias"]} Hosts";
      }
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final groups = HostsScreen.route.extractNamedArgs(context);
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    var filter = <String>[];
    switch (groups['filter']) {
      case 'problems':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStateDown}"}');
        break;
      case 'unhandled':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStateUnreachable}"}');
        break;
      case 'stale':
        filter.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.hostStatePending}"}');
        break;
      case 'all':
        break;
      default:
        if (groups['filter'] != null) {
          filter.add(groups['filter']!);
        }
    }

    return BlocProvider<HostsBloc>(
      create: (context) =>
          HostsBloc(alias: groups['alias']!, filter: filter, sBloc: sBloc)
            ..add(HostsStartFetching()),
      child: BlocBuilder<HostsBloc, HostsState>(
        builder: (context, state) {
          final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
          if (state is HostsStateFetched) {
            return Column(
              children: [
                SiteStatsWidget(alias: groups['alias']!, state: cBloc.state),
                Expanded(
                    child: HostsListWidget(
                        alias: groups['alias']!, hosts: state.hosts)),
              ],
            );
          } else {
            return Column(
              children: [
                SiteStatsWidget(alias: groups['alias']!, state: cBloc.state),
                Expanded(child: CenterLoadingWidget()),
              ],
            );
          }
        },
      ),
    );
  }
}
