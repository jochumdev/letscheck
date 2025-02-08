import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/screen/slim/base_slim_screen.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  final String site;
  final String hostname;
  final String service;

  ServiceScreen({
    required this.site,
    required this.hostname,
    required this.service,
  });

  @override
  ServiceScreenState createState() => ServiceScreenState(
        site: site,
        hostname: hostname,
        service: service,
      );
}

class ServiceScreenState extends ConsumerState<ServiceScreen> with BaseSlimScreenState {
  final String site;
  final String hostname;
  final String service;

  ServiceScreenState(
      {required this.site, required this.hostname, required this.service});
  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Service';

    var serviceName = service;
    if (serviceName.length > 25) {
      serviceName = serviceName.substring(0, 25);
    }
    title = "Service $serviceName";

    return BaseSlimScreenSettings(title, showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    return Column(
      children: [
        SiteStatsWidget(site: site),
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
    );
  }
}
