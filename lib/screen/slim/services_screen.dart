import 'package:flutter/material.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/providers/services/services_state.dart';
import 'package:letscheck/widget/services_list_widget.dart';
import 'package:letscheck/widget/site_stats_widget.dart';

import 'package:letscheck/screen/slim/base_slim_screen.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  final String site;
  final String filter;

  ServicesScreen({required this.site, required this.filter});

  @override
  ServicesScreenState createState() => ServicesScreenState(
        site: site,
        filter: filter,
      );
}

class ServicesScreenState extends ConsumerState<ServicesScreen>
    with BaseSlimScreenState {
  final String site;
  final String filter;
  late AliasAndFilterParams params;

  ServicesScreenState({required this.site, required this.filter}) {
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

    params = AliasAndFilterParams(alias: site, filter: myFilters);
  }

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Services';
    switch (filter) {
      case 'all':
        title = "Services";
        break;
      default:
        title = "Services $filter";
    }

    return BaseSlimScreenSettings(title, showMenu: false);
  }

  @override
  Widget content(BuildContext context) {
    final services = ref.watch(servicesProvider(params));

    if (services is ServicesLoaded) {
      return Column(
        children: [
          SiteStatsWidget(site: site),
          Expanded(
            child: ServicesListWidget(
              alias: site,
              services: services.services,
              listKey: PageStorageKey('services_screen_$site'),
            ),
          ),
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