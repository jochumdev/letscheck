import 'package:flutter/material.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class ServiceScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeService,
      uri: "/conn/{alias}/host/{hostname}/services/{service}",
      lastArgOptional: false,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => ServiceScreen(),
          ));

  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = ServiceScreen.route.extractNamedArgs(context);
    var title = "Service";
    if (!groups.containsKey("alias") ||
        !groups.containsKey("hostname") ||
        !groups.containsKey("service")) {
      Navigator.of(context)
          .pushReplacementNamed(GlobalRouter().buildUri(routeNotFound));
    }

    var serviceName = groups["service"];
    if (serviceName.length > 25) {
      serviceName = serviceName.substring(0, 25);
    }
    title = "${groups["alias"]} Service $serviceName";

    return BaseSlimScreenSettings(title, showMenu: false, showSearch: false);
  }

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: Text("Service Screen"),
          ),
        ),
      ],
    );
  }
}
