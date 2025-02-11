import 'package:flutter/material.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/providers/services/services_state.dart';
import 'package:letscheck/widget/services_list_widget.dart';
import 'package:letscheck/widget/site_stats_widget.dart';

import 'package:letscheck/screen/slim/slim_layout.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  final String alias;
  final String filter;

  ServicesScreen({required this.alias, required this.filter});

  @override
  ServicesScreenState createState() => ServicesScreenState(
        alias: alias,
        filter: filter,
      );
}

class ServicesScreenState extends ConsumerState<ServicesScreen> {
  final String alias;
  final String filter;
  late AliasAndFilterParams params;

  ServicesScreenState({required this.alias, required this.filter}) {
    var myFilters = <String>[];
    switch (filter) {
      case 'problems':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateWarn}"}');
        break;
      case 'unhandled':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateCritical}"}');
        break;
      case 'stale':
        myFilters.add(
            '{"op": "=", "left": "state", "right": "${cmk_api.svcStateUnknown}"}');
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

  SlimLayoutSettings settings() {
    var title = 'Services';
    switch (filter) {
      case 'all':
        title = "Services";
        break;
      default:
        title = "Services $filter";
    }

    return SlimLayoutSettings(title, showMenu: false);
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider(params));

    if (services is ServicesLoaded) {
      return SlimLayout(
        layoutSettings: settings(),
        child: Column(
          children: [
            SiteStatsWidget(alias: alias),
            Expanded(
              child: ServicesListWidget(
                alias: alias,
                services: services.services,
                listKey: PageStorageKey('services_screen_$alias'),
              ),
            ),
          ],
        ),
      );
    } else {
      return SlimLayout(
        layoutSettings: settings(),
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
