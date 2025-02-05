import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';

class ServiceScreen extends StatefulWidget {
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

class ServiceScreenState extends State<ServiceScreen> with BaseSlimScreenState {
  final String alias;
  final String hostname;
  final String service;

  ServiceScreenState(
      {required this.alias, required this.hostname, required this.service});
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
    final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
    return Column(
      children: [
        SiteStatsWidget(alias: alias, state: cBloc.state),
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
