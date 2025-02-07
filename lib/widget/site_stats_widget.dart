import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import 'package:go_router/go_router.dart';

import '../bloc/connection_data/connection_data.dart';
import '../bloc/settings/settings.dart';
import 'site_stats_number_widget.dart';

class SiteStatsWidget extends StatelessWidget {
  final String alias;
  final ConnectionDataState state;

  SiteStatsWidget({required this.alias, required this.state});

  @override
  Widget build(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);
    final conn = sBloc.state.connections[alias]!;

    var hasFilters = false;
    for (var f in conn.filters.values) {
      if (f) {
        hasFilters = true;
        break;
      }
    }

    Widget statsWidget = Container();

    if (state.stats[alias] != null &&
        conn.state == SettingsConnectionStateEnum.connected) {
      final stats = state.stats[alias]!;
      statsWidget = Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SiteStatsNumberWidget(
              caption: 'Hosts',
              num: stats.hosts.all,
              valueColor: Colors.white,
              onTap: () {
                context.push('/conn/$alias/hosts/all');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Warning',
              num: stats.hosts.warn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/conn/$alias/hosts/problems');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Critical',
              num: stats.hosts.crit,
              valueColor: Colors.red,
              onTap: () {
                context.push('/conn/$alias/hosts/unhandled');
              },
            ),
            SizedBox(
              width: 54,
            ),
          ]),
          SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SiteStatsNumberWidget(
              caption: 'Services',
              num: stats.services.all,
              valueColor: Colors.white,
              onTap: () {
                context.push('/conn/$alias/services/all');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Warning',
              num: stats.services.warn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/conn/$alias/services/problems');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Critical',
              num: stats.services.crit,
              valueColor: Colors.red,
              onTap: () {
                context.push('/conn/$alias/services/unhandled');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Unknown',
              num: stats.services.unkn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/conn/$alias/services/stale');
              },
            ),
          ]),
        ]),
      );
    }

    var titleColor = Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(211, 227, 253, 1)
        : Color.fromRGBO(11, 87, 208, 1);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/settings/connection/$alias');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      alias,
                      style: TextStyle(color: titleColor),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.push('/error/404');
                      },
                      tooltip: hasFilters ? 'Edit' : 'Edit, no filters yet',
                      icon: Icon(Icons.filter_list,
                          size: 14,
                          color: hasFilters ? Colors.yellow : Colors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push('/settings/connection/$alias');
                      },
                      tooltip: 'Edit connection Details',
                      icon: Icon(Icons.settings_input_component,
                          size: 14,
                          color: conn.state !=
                                  SettingsConnectionStateEnum.connected
                              ? Colors.red
                              : Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            statsWidget,
          ],
        ),
      ),
    );
  }
}
