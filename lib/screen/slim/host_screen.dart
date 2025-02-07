import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import '../../bloc/services/services.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../widget/services_grouped_card_widget.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/host_card_widget.dart';

class HostScreen extends StatefulWidget {
  final String alias;
  final String hostname;

  HostScreen({required this.alias, required this.hostname});

  @override
  HostScreenState createState() => HostScreenState(
        alias: alias,
        hostname: hostname,
      );
}

class HostScreenState extends State<HostScreen> with BaseSlimScreenState {
  final String alias;
  final String hostname;

  HostScreenState({required this.alias, required this.hostname});

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
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    return MultiBlocProvider(
        providers: [
          BlocProvider<ServicesBloc>(
            create: (context) => ServicesBloc(
                alias: alias,
                filter: [
                  '{"op": "=", "left": "host_name", "right": "$hostname"}'
                ],
                sBloc: sBloc)
              ..add(ServicesEventStartFetching()),
          ),
          BlocProvider<HostsBloc>(
            create: (context) => HostsBloc(
                alias: alias,
                filter: ['{"op": "=", "left": "name", "right": "$hostname"}'],
                sBloc: sBloc)
              ..add(HostsEventFetch()),
          )
        ],
        child: BlocBuilder<HostsBloc, HostsState>(builder: (hcontext, hstate) {
          if (hstate is HostsStateFetched) {
            return BlocBuilder<ServicesBloc, ServicesState>(
                builder: (context, state) {
              if (state is ServicesStateFetched) {
                final groupedServices =
                    servicesGroupByHostname(services: state.services);
                final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
                return Column(
                  children: [
                    SiteStatsWidget(alias: alias, state: cBloc.state),
                    Expanded(
                        child: Column(children: [
                      HostCardWidget(alias: alias, host: hstate.hosts[0]),
                      Expanded(
                          child: ListView(children: [
                        ServicesGroupedCardWidget(
                          alias: alias,
                          groupName: hostname,
                          services: groupedServices[hostname]!,
                          showGroupHeader: false,
                        )
                      ]))
                    ])),
                  ],
                );
              } else {
                return CenterLoadingWidget();
              }
            });
          } else {
            return CenterLoadingWidget();
          }
        }));
  }
}
