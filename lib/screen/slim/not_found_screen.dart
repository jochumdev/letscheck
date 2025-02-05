import 'package:flutter/material.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class NotFoundScreen extends StatefulWidget {
  static final route = buildRoute(
      key: routeNotFound,
      uri: '/pages/not_found',
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => NotFoundScreen(),
          ));

  @override
  NotFoundScreenState createState() => NotFoundScreenState();
}

class NotFoundScreenState extends State<NotFoundScreen>
    with BaseSlimScreenState {
  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('404 Not found',
        showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    print(ModalRoute.of(context)!.settings.name);
    return Container(
      child: Center(
        child: Text('Page not found!'),
      ),
    );
  }
}
