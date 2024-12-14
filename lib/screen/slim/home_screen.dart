import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_slim_screen.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/site_stats_widget.dart';
import '../../widget/services_list_widget.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/connection_data/connection_data.dart';
import '../../bloc/comments/comments.dart';
import '../../global_router.dart';

class HomeScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeHome,
      uri: '/',
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => HomeScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('Home', showSettings: true);
  }

  @override
  Widget content(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    return BlocBuilder<CommentsBloc, CommentsState>(
        builder: (cContext, cState) {
      return BlocBuilder<ConnectionDataBloc, ConnectionDataState>(
          builder: (context, state) {
        if (sBloc.state.connections.length > 1) {
          return DefaultTabController(
              length: sBloc.state.connections.length,
              child: TabBarView(
                children: sBloc.state.connections.keys.map((alias) {
                  if (state.unhServices.containsKey(alias)) {
                    commentsFetchForServices(
                        context: context,
                        alias: alias,
                        services: state.unhServices[alias]!);
                  }

                  return Column(
                    children: [
                      SiteStatsWidget(alias: alias, state: state),
                      state.unhServices.containsKey(alias)
                          ? Expanded(
                              child: ServicesListWidget(
                                  alias: alias,
                                  services: state.unhServices[alias]!))
                          : Expanded(child: CenterLoadingWidget()),
                      TabPageSelector(),
                    ],
                  );
                }).toList(),
              ));
        } else if (sBloc.state.connections.length == 1) {
          final alias = sBloc.state.connections.keys.toList()[0];
          return Column(
            children: [
              SiteStatsWidget(alias: alias, state: state),
              state.unhServices.containsKey(alias)
                  ? Expanded(
                      child: ServicesListWidget(
                          alias: alias, services: state.unhServices[alias]!))
                  : Expanded(child: CenterLoadingWidget()),
            ],
          );
        }

        return Container();
      });
    });
  }
}
