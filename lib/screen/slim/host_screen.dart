import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/hosts/hosts_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/providers/services/services_state.dart';
import 'package:letscheck/providers/services/services_util.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/widget/services_grouped_card_widget.dart';
import 'package:letscheck/widget/host_card_widget.dart';

import 'package:letscheck/screen/slim/base_slim_screen.dart';

class HostScreen extends ConsumerStatefulWidget {
  final String site;
  final String hostname;

  HostScreen({required this.site, required this.hostname});

  @override
  HostScreenState createState() => HostScreenState(
        site: site,
        hostname: hostname,
      );
}

class HostScreenState extends ConsumerState<HostScreen> with BaseSlimScreenState {
  final String site;
  final String hostname;

  late final AliasAndFilterParams hostParams;
  late final AliasAndFilterParams serviceParams;

  HostScreenState({required this.site, required this.hostname}) {
    hostParams = AliasAndFilterParams(alias: site, filter: ['{"op": "=", "left": "name", "right": "$hostname"}']);
    serviceParams = AliasAndFilterParams(alias: site, filter: ['{"op": "=", "left": "host_name", "right": "$hostname"}']);
  }

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Host';
    var myHostname = hostname;
    if (myHostname.length > 25) {
      myHostname = myHostname.substring(0, 25);
    }
    title = "Host $myHostname";

    return BaseSlimScreenSettings(title, showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    final hosts = ref.watch(hostsProvider(hostParams));
    final services = ref.watch(servicesProvider(serviceParams));

    if (hosts is! HostsLoaded || services is! ServicesLoaded) {
      return Container();
    }

    final groupedServices = servicesGroupByHostname(services: services.services);

    return Column(
      children: [
        SiteStatsWidget(site: site),
        Expanded(
            child: Column(children: [
          HostCardWidget(site: site, host: hosts.hosts[0]),
          Expanded(
              child: ListView(children: [
            ServicesGroupedCardWidget(
              site: site,
              groupName: hostname,
              services: groupedServices[hostname]!,
              showGroupHeader: false,
            )
          ]))
        ])),
      ],
    );
  }
}
