import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_slim_screen.dart';

class NotFoundScreen extends ConsumerStatefulWidget {
  @override
  NotFoundScreenState createState() => NotFoundScreenState();
}

class NotFoundScreenState extends ConsumerState<NotFoundScreen>
    with BaseSlimScreenState {
  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('404 Not found',
        showMenu: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Page not found!'),
      ),
    );
  }
}
