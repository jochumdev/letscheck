import 'package:flutter/material.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class NotFoundScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeNotFound,
      uri: "/pages/not_found",
      route: (context) => MaterialPageRoute(
        settings: context,
        builder: (context) => NotFoundScreen(),
      ));

  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings("404 Not found");
  }

  Widget content(BuildContext context) {
    print(ModalRoute.of(context).settings.name);
    return Container(
      child: Center(
        child: Text("Page not found!"),
      ),
    );
  }
}
