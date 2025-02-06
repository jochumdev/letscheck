import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_slim_screen.dart';
import '../../widget/center_loading_widget.dart';
import '../../widget/site_stats_widget.dart';
import '../../widget/services_list_widget.dart';
import '../../widget/tab_controller_listener.dart';
import '../../bloc/settings/settings.dart';
import '../../bloc/connection_data/connection_data.dart';
import '../../bloc/comments/comments.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with BaseSlimScreenState {
  @override
  Future<void> refreshAction(context) async {
    final sBloc = BlocProvider.of<SettingsBloc>(context);
    final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
    cBloc.add(UpdateClient(
        action: SettingsStateEnum.clientUpdated,
        alias: sBloc.state.currentAlias));
  }

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('Home', showSettings: true);
  }

  @override
  Widget content(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    return BlocBuilder<ConnectionDataBloc, ConnectionDataState>(
        builder: (context, state) {
      return BlocBuilder<CommentsBloc, CommentsState>(
          builder: (cContext, cState) {
        if (sBloc.state.connections.length > 1) {
          return DefaultTabController(
            length: sBloc.state.connections.length,
            child: TabControllerListener(
                onTabSelected: (int index) {
                  sBloc.add(
                    SettingsSetCurrentAlias(
                        sBloc.state.connections.keys.elementAt(index)),
                  );
                },
                child: TabBarView(
                  children: sBloc.state.connections.keys.map((alias) {
                    if (state.unhServices.containsKey(alias)) {
                      commentsFetchForServices(
                          context: context,
                          alias: alias,
                          services: state.unhServices[alias]!.toList());
                    }

                    return Column(
                      children: [
                        SiteStatsWidget(alias: alias, state: state),
                        state.unhServices.containsKey(alias)
                            ? Expanded(
                                child: ServicesListWidget(
                                    alias: alias,
                                    services: state.unhServices[alias]!.toList()))
                            : Expanded(child: CenterLoadingWidget()),
                        TabPageSelector(),
                      ],
                    );
                  }).toList(),
                )),
          );
        } else if (sBloc.state.connections.length == 1) {
          final alias = sBloc.state.connections.keys.first;

          sBloc.add(
            SettingsSetCurrentAlias(alias),
          );

          return Column(
            children: [
              SiteStatsWidget(alias: alias, state: state),
              state.unhServices.containsKey(alias)
                  ? Expanded(
                      child: ServicesListWidget(
                          alias: alias, services: state.unhServices[alias]!.toList()))
                  : Expanded(child: CenterLoadingWidget()),
            ],
          );
        }

        return Container();
      });
    });
  }
}
