import 'package:flutter/material.dart';

class TabControllerListener extends StatefulWidget {
  final void Function(int index)? onTabSelected;
  final Widget child;

  const TabControllerListener(
      {super.key, required this.onTabSelected, required this.child});

  @override
  TabControllerListenerState createState() => TabControllerListenerState();
}

class TabControllerListenerState extends State<TabControllerListener> {
  late final void Function() _listener;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabController = DefaultTabController.of(context);
      _listener = () {
        final onTabSelected = widget.onTabSelected;
        if (onTabSelected != null) {
          onTabSelected(tabController.index);
        }
      };
      tabController.addListener(_listener);
    });
  }

  @override
  void didChangeDependencies() {
    _tabController = DefaultTabController.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController!.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
