import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' if (kIsWeb) 'package:web/web.dart' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

import 'package:letscheck/widget/site_stats_widget.dart';
import '../../providers/providers.dart';
import '../../widget/custom_search_delegate.dart';

class SlimLayoutSettings {
  final String title;
  late bool showRefresh;
  final bool showSettings;
  final bool showMenu;
  final bool showLeading;
  final bool showSearch;
  final bool showLogs;

  SlimLayoutSettings(this.title,
      {this.showSettings = true,
      this.showMenu = true,
      this.showLeading = true,
      this.showSearch = true,
      this.showLogs = true}) {
    showRefresh = kIsWeb || Platform.isAndroid || Platform.isIOS;
  }
}

class SlimLayout extends ConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final SlimLayoutSettings layoutSettings;
  final Widget child;

  SlimLayout({super.key, required this.layoutSettings, required this.child});

  Future<void> leadingButtonAction(BuildContext context) async {
    context.pop();
  }

  Future<void> refreshAction(BuildContext context, WidgetRef ref) async {
    final connectionNames = ref.read(
        settingsProvider.select((s) => s.connections.map((c) => c.alias)));
    for (final alias in connectionNames) {
      final client = await ref.read(clientProvider(alias).future);
      if (client.requestedConnectionState != cmk_api.ConnectionState.paused) {
        await client.connect();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fix portrait mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final settings = ref.watch(settingsProvider);

    var widgets = <Widget>[];

    for (var i = 0; i < settings.connections.length; i++) {
      widgets.add(SiteStatsWidget(alias: settings.connections[i].alias)
          .build(context, ref));
      widgets.add(Divider());
    }

    var drawer = Drawer(
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: false,
        children: widgets,
      ),
    );

    Widget leading;
    if (layoutSettings.showMenu) {
      leading = IconButton(
          icon: Icon(Icons.menu),
          tooltip: "Menu",
          onPressed: () {
            if (_scaffoldKey.currentState != null) {
              if (_scaffoldKey.currentState!.isDrawerOpen == false) {
                _scaffoldKey.currentState!.openDrawer();
              } else {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            }
          });
    } else {
      leading = IconButton(
        icon: Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: () async {
          await leadingButtonAction(context);
        },
      );
    }

    final talker = ref.read(talkerProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer,
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
        ),
        // type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        // distance: 70,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () async {
              context.push('/settings');
            },
            child: const Icon(Icons.settings),
          ),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () async {
              await refreshAction(context, ref);
            },
            child: const Icon(Icons.refresh),
          ),
          if (kDebugMode)
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () async {
                context.push('/logs');
              },
              child: const Icon(Icons.list),
            ),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () =>
                showSearch(context: context, delegate: CustomSearchDelegate()),
            child: const Icon(Icons.search),
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing:
            layoutSettings.showLeading ? NavigationToolbar.kMiddleSpacing : 0.0,
        title: Text(layoutSettings.title),
        leading: layoutSettings.showLeading ? leading : null,
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshAction(context, ref),
        child: TalkerWrapper(
          talker: talker,
          options: const TalkerWrapperOptions(
            enableErrorAlerts: true,
          ),
          child: child,
        ),
      ),
    );
  }
}
