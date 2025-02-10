import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/widget/site_stats_number_widget.dart';

class SiteStatsWidget extends ConsumerWidget {
  final String site;

  SiteStatsWidget({required this.site});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionData = ref.watch(connectionDataProvider(site));

    var hasFilters = false;
    // for (var f in connection.filters.values) {
    //   if (f) {
    //     hasFilters = true;
    //     break;
    //   }
    // }

    Widget statsWidget = Container();

    if (connectionData is ConnectionDataLoaded) {
      final stats = connectionData.stats;
      statsWidget = Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SiteStatsNumberWidget(
              caption: 'Hosts',
              num: stats.hosts.all,
              valueColor: Colors.white,
              onTap: () {
                context.push('/$site/hosts/all');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Warning',
              num: stats.hosts.warn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/$site/hosts/problems');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Critical',
              num: stats.hosts.crit,
              valueColor: Colors.red,
              onTap: () {
                context.push('/$site/hosts/unhandled');
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
                context.push('/$site/services/all');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Warning',
              num: stats.services.warn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/$site/services/problems');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Critical',
              num: stats.services.crit,
              valueColor: Colors.red,
              onTap: () {
                context.push('/$site/services/unhandled');
              },
            ),
            SiteStatsNumberWidget(
              caption: 'Unknown',
              num: stats.services.unkn,
              valueColor: Colors.yellow,
              onTap: () {
                context.push('/$site/services/stale');
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
                    context.push('/settings/connection/$site');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      site,
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
                        context.push('/settings/connection/$site');
                      },
                      tooltip: 'Edit connection Details',
                      icon: Icon(Icons.settings_input_component,
                          size: 14,
                          color: connectionData is ConnectionDataError
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
