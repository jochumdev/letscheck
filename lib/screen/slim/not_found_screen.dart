import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'slim_layout.dart';

class NotFoundScreen extends ConsumerStatefulWidget {
  @override
  NotFoundScreenState createState() => NotFoundScreenState();
}

class NotFoundScreenState extends ConsumerState<NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    return SlimLayout(
      layoutSettings: SlimLayoutSettings('404 Not found',
          showMenu: false, showSearch: false),
      child: Center(
        child: Text('Page not found!'),
      ),
    );
  }
}
