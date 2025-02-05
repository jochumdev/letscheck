import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import '../../bloc/services/services.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../global_router.dart';
import '../../widget/services_grouped_card_widget.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/host_card_widget.dart';

class HostScreen extends StatefulWidget {
  static final route = buildRoute(
      key: routeHost,
      uri: '/conn/{alias}/host/{hostname}',
      lastArgOptional: false,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => HostScreen(),
          ));

  @override
  HostScreenState createState() => HostScreenState();
}

class HostScreenState extends State<HostScreen> with BaseSlimScreenState {
  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = HostScreen.route.extractNamedArgs(context);
    var title = 'Host';
    if (!groups.containsKey('alias') || !groups.containsKey('hostname')) {
      Navigator.of(context)
          .pushReplacementNamed(GlobalRouter().buildUri(routeNotFound));
    }

    var hostname = groups['hostname']!;
    if (hostname.length > 25) {
      hostname = hostname.substring(0, 25);
    }
    title = "Host $hostname";

    return BaseSlimScreenSettings(title, showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    final groups = HostScreen.route.extractNamedArgs(context);
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    return MultiBlocProvider(
        providers: [
          BlocProvider<ServicesBloc>(
            create: (context) => ServicesBloc(
                alias: groups['alias']!,
                filter: [
                  '{"op": "=", "left": "host_name", "right": "${groups["hostname"]}"}'
                ],
                sBloc: sBloc)
              ..add(ServicesStartFetching()),
          ),
          BlocProvider<HostsBloc>(
            create: (context) => HostsBloc(
                alias: groups['alias']!,
                filter: [
                  '{"op": "=", "left": "name", "right": "${groups["hostname"]}"}'
                ],
                sBloc: sBloc)
              ..add(HostsStartFetching()),
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
                    SiteStatsWidget(
                        alias: groups['alias']!, state: cBloc.state),
                    Expanded(
                        child: Column(children: [
                      HostCardWidget(
                          alias: groups['alias']!, host: hstate.hosts[0]),
                      Expanded(
                          child: ListView(children: [
                        ServicesGroupedCardWidget(
                          alias: groups['alias']!,
                          groupName: groups['hostname']!,
                          services: groupedServices[groups['hostname']!]!,
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
