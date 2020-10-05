import 'package:flutter/material.dart';
import 'base_slim_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../global_router.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/hosts/hosts.dart';
import '../../widget/hosts_list_widget.dart';
import '../../widget/center_loading_widget.dart';

class HostsScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeHosts,
      uri: "/conn/{alias}/hosts/{filter}",
      lastArgOptional: true,
      route: (context) => MaterialPageRoute(
        settings: context,
        builder: (context) => HostsScreen(),
      ));

  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = HostsScreen.route.extractNamedArgs(context);
    var title = "Hosts";
    if (groups.containsKey("alias")) {
      if (groups.containsKey("filter")) {
        switch (groups["filter"]) {
          case "all":
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

  Widget content(BuildContext context) {
    final groups = HostsScreen.route.extractNamedArgs(context);
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    List<String> filter = [];
    switch (groups["filter"]) {
      case "problems":
        filter.add("hosts_problems");
        break;
      case "unhandled":
        filter.add("hosts_unhandled");
        break;
      case "stale":
        filter.add("hosts_stale");
        break;
      default:
    }

    return BlocProvider<HostsBloc>(
        create: (context) => HostsBloc(
            alias: groups["alias"],
            filter: filter,
            sBloc: sBloc)
          ..add(HostsStartFetching()),
        child:
        BlocBuilder<HostsBloc, HostsState>(builder: (context, state) {
          if (state is HostsStateFetched) {
            return HostsListWidget(
                alias: groups["alias"], hosts: state.hosts);
          } else {
            return CenterLoadingWidget();
          }
        }));
  }
}
