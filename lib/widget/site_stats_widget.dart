import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/connection_data/connection_data.dart';
import '../bloc/settings/settings.dart';
import '../global_router.dart';
import 'site_stats_number_widget.dart';

class SiteStatsWidget extends StatelessWidget {
  final String alias;
  final ConnectionDataState state;

  SiteStatsWidget({required this.alias, required this.state});

  @override
  Widget build(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);
    final conn = sBloc.state.connections[alias]!;

    if (state.stats[alias] == null ||
        conn.state != SettingsConnectionStateEnum.connected) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                  GlobalRouter().buildUri(routeSettingsConnection, buildArgs: {
                'name': alias,
              }));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(alias,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
                Icon(Icons.settings_input_component,
                    size: 14,
                    color: conn.state == SettingsConnectionStateEnum.connected
                        ? Colors.green
                        : Colors.red),
              ],
            ),
          ),
        ),
      );
    }

    final stats = state.stats[alias]!;

    return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(GlobalRouter()
                        .buildUri(routeSettingsConnection, buildArgs: {
                      'name': alias,
                    }));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(alias,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                      Icon(Icons.settings_input_component,
                          size: 14, color: Colors.green),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SiteStatsNumberWidget(
                            caption: 'Hosts',
                            num: stats.hosts.all,
                            valueColor: Colors.white,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeHosts, buildArgs: {
                                'alias': alias,
                                'filter': 'all'
                              }));
                            },
                          ),
                          SiteStatsNumberWidget(
                            caption: 'Warning',
                            num: stats.hosts.warn,
                            valueColor: Colors.yellow,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeHosts, buildArgs: {
                                'alias': alias,
                                'filter': 'problems'
                              }));
                            },
                          ),
                          SiteStatsNumberWidget(
                            caption: 'Critical',
                            num: stats.hosts.crit,
                            valueColor: Colors.red,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeHosts, buildArgs: {
                                'alias': alias,
                                'filter': 'unhandled'
                              }));
                            },
                          ),
                          SizedBox(
                            width: 50,
                          ),
                        ]),
                    SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SiteStatsNumberWidget(
                            caption: 'Services',
                            num: stats.services.all,
                            valueColor: Colors.white,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeServices, buildArgs: {
                                'alias': alias,
                                'filter': 'all'
                              }));
                            },
                          ),
                          SiteStatsNumberWidget(
                            caption: 'Warning',
                            num: stats.services.warn,
                            valueColor: Colors.yellow,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeServices, buildArgs: {
                                'alias': alias,
                                'filter': 'problems'
                              }));
                            },
                          ),
                          SiteStatsNumberWidget(
                            caption: 'Critical',
                            num: stats.services.crit,
                            valueColor: Colors.red,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeServices, buildArgs: {
                                'alias': alias,
                                'filter': 'unhandled'
                              }));
                            },
                          ),
                          SiteStatsNumberWidget(
                            caption: 'Unknown',
                            num: stats.services.unkn,
                            valueColor: Colors.yellow,
                            onTap: () {
                              Navigator.of(context).pushNamed(GlobalRouter()
                                  .buildUri(routeServices, buildArgs: {
                                'alias': alias,
                                'filter': 'stale'
                              }));
                            },
                          ),
                        ]),
                  ]),
                ),
              ],
            )));
  }
}
