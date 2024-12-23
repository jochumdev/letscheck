import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_slim_screen.dart';
import '../../bloc/services/services.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../global_router.dart';
import '../../widget/services_grouped_card_widget.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/host_card_widget.dart';

class HostScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeHost,
      uri: '/conn/{alias}/host/{hostname}',
      lastArgOptional: false,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => HostScreen(),
          ));

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
    title = "${groups["alias"]} Host $hostname";

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
                filter: ["Filter: host_name = ${groups["hostname"]}"],
                sBloc: sBloc)
              ..add(ServicesStartFetching()),
          ),
          BlocProvider<HostsBloc>(
            create: (context) => HostsBloc(
                alias: groups['alias']!,
                filter: ["Filter: name = ${groups["hostname"]}"],
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
                return Column(children: [
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
                ]);
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
