import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'base_slim_screen.dart';

class NotFoundScreen extends StatefulWidget {
  static final route = GoRoute(
    path: '/error/404',
    builder: (context, state) => NotFoundScreen(),
  );

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
