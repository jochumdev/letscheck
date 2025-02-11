import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/hosts/hosts_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/widget/hosts_list_widget.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:letscheck/screen/slim/slim_layout.dart';

class HostsScreen extends ConsumerStatefulWidget {
  final String alias;
  final String filter;

  HostsScreen({required this.alias, required this.filter});

  @override
  HostsScreenState createState() => HostsScreenState(
        alias: alias,
        filter: filter,
      );
}

class HostsScreenState extends ConsumerState<HostsScreen> {
  final String alias;
  final String filter;
  late final AliasAndFilterParams params;

  HostsScreenState({required this.alias, required this.filter}) {
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
    params = AliasAndFilterParams(alias: alias, filter: myFilters);
  }

  SlimLayoutSettings setup() {
    var title = 'Hosts';
    switch (filter) {
      case 'all':
        title = "Hosts";
        break;
      default:
        title = "Hosts $filter";
    }

    return SlimLayoutSettings(title, showMenu: false);
  }

  @override
  Widget build(BuildContext context) {
    final hosts = ref.watch(hostsProvider(params));

    if (hosts is HostsLoaded) {
      return SlimLayout(
        layoutSettings: setup(),
        child: Column(
          children: [
            SiteStatsWidget(alias: alias),
            Expanded(
                child: HostsListWidget(
              alias: alias,
              hosts: hosts.hosts,
              listKey: PageStorageKey('hosts_screen_$alias'),
            )),
          ],
        ),
      );
    } else {
      return SlimLayout(
        layoutSettings: setup(),
        child: Column(
          children: [
            SiteStatsWidget(alias: alias),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }
  }
}
