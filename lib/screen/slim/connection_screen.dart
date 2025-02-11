import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/screen/slim/slim_layout.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/widget/services_list_widget.dart';
import 'package:letscheck/providers/providers.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  final String alias;

  const ConnectionScreen({super.key, required this.alias});

  @override
  ConsumerState<ConnectionScreen> createState() => ConnectionScreenState();
}

class ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  SlimLayoutSettings layoutSettings() {
    return SlimLayoutSettings('${widget.alias}', showSettings: true);
  }

  @override
  Widget build(BuildContext context) {
    final connectionData = ref.watch(connectionDataProvider(widget.alias));

    return SlimLayout(
      layoutSettings: layoutSettings(),
      child: switch (connectionData) {
        ConnectionDataInitial() => Container(),
        ConnectionDataLoaded(unhServices: final unhServices) => Column(
            children: [
              SiteStatsWidget(
                alias: widget.alias,
              ),
              Expanded(
                  child: ServicesListWidget(
                alias: widget.alias,
                services: unhServices.toList(),
              )),
            ],
          ),
        ConnectionDataError(error: final error) => Column(
            children: [
              SiteStatsWidget(
                alias: widget.alias,
              ),
              Expanded(child: Center(child: Text('$error!'))),
            ],
          ),
      },
    );
  }
}
