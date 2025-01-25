import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letscheck/bloc/connection_data/connection_data.dart';
import 'package:letscheck/widget/center_loading_widget.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class ServiceScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeService,
      uri: '/conn/{alias}/host/{hostname}/services/{service}',
      lastArgOptional: false,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => ServiceScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = ServiceScreen.route.extractNamedArgs(context);
    var title = 'Service';
    if (!groups.containsKey('alias') ||
        !groups.containsKey('hostname') ||
        !groups.containsKey('service')) {
      Navigator.of(context)
          .pushReplacementNamed(GlobalRouter().buildUri(routeNotFound));
    }

    var serviceName = groups['service']!;
    if (serviceName.length > 25) {
      serviceName = serviceName.substring(0, 25);
    }
    title = "${groups["alias"]} Service $serviceName";

    return BaseSlimScreenSettings(title, showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    final groups = ServiceScreen.route.extractNamedArgs(context);
    final cBloc = BlocProvider.of<ConnectionDataBloc>(context);
    return Column(
      children: [
        SiteStatsWidget(alias: groups['alias']!, state: cBloc.state),
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
