import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/hosts/hosts_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/widget/hosts_list_widget.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/screen/slim/base_slim_screen.dart';

class HostsScreen extends ConsumerStatefulWidget {
  final String site;
  final String filter;

  HostsScreen({required this.site, required this.filter});

  @override
  HostsScreenState createState() => HostsScreenState(
        site: site,
        filter: filter,
      );
}

class HostsScreenState extends ConsumerState<HostsScreen>
    with BaseSlimScreenState {
  final String site;
  final String filter;
  late final SiteAndFilterParams params;

  HostsScreenState({required this.site, required this.filter}) {
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
    params = SiteAndFilterParams(site: site, filter: myFilters);
  }

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Hosts';
    switch (filter) {
      case 'all':
        title = "$site Hosts";
        break;
      default:
        title = "$site Hosts $filter";
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final hosts = ref.watch(hostsProvider(params));

    if (hosts is HostsLoaded) {
      return Column(
        children: [
          SiteStatsWidget(site: site),
          Expanded(
              child: HostsListWidget(
            alias: site,
            hosts: hosts.hosts,
            listKey: PageStorageKey('hosts_screen_$site'),
          )),
        ],
      );
    } else {
      return Column(
        children: [
          SiteStatsWidget(site: site),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }
  }
}
