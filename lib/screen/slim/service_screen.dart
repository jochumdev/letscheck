import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/screen/slim/slim_layout.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  final String alias;
  final String hostname;
  final String service;

  ServiceScreen({
    required this.alias,
    required this.hostname,
    required this.service,
  });

  @override
  ServiceScreenState createState() => ServiceScreenState(
        alias: alias,
        hostname: hostname,
        service: service,
      );
}

class ServiceScreenState extends ConsumerState<ServiceScreen> {
  final String alias;
  final String hostname;
  final String service;

  ServiceScreenState(
      {required this.alias, required this.hostname, required this.service});

  SlimLayoutSettings settings() {
    var title = 'Service';

    var serviceName = service;
    if (serviceName.length > 25) {
      serviceName = serviceName.substring(0, 25);
    }
    title = "Service $serviceName";

    return SlimLayoutSettings(title, showMenu: false, showSearch: false);
  }

  @override
  Widget build(BuildContext context) {
    return SlimLayout(
      layoutSettings: settings(),
      child: Column(
        children: [
          SiteStatsWidget(alias: alias),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 150,
                    height: 80,
                    padding: EdgeInsets.all(12.0),
                    child: Text('Service Screen'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
