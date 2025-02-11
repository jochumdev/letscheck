import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

import 'package:letscheck/widget/site_stats_widget.dart';
import '../../providers/providers.dart';
import '../../widget/custom_search_delegate.dart';

class BaseSlimScreenSettings {
  final String title;
  final bool showRefresh;
  final bool showSettings;
  final bool showMenu;
  final bool showLeading;
  final bool showSearch;
  final bool showLogs;

  BaseSlimScreenSettings(this.title,
      {this.showRefresh = false,
      this.showSettings = true,
      this.showMenu = true,
      this.showLeading = true,
      this.showSearch = true,
      this.showLogs = true});
}

mixin BaseSlimScreenState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<void> leadingButtonAction(BuildContext context) async {
    context.pop();
  }

  Future<void> refreshAction(BuildContext context) async {
    final connectionNames = ref.read(
        settingsProvider.select((s) => s.connections.map((c) => c.alias)));
    for (final site in connectionNames) {
      final client = ref.read(clientProvider(site));
      if (client.requestedConnectionState != cmk_api.ConnectionState.paused) {
        await client.connect();
      }
    }
  }

  Widget content(BuildContext context) {
    return Container();
  }

  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings("invalid");
  }

  @override
  Widget build(BuildContext context) {
    // Fix portrait mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mySettings = setup(context);

    final settings = ref.watch(settingsProvider);

    var drawer = Drawer(
      child: Builder(builder: (context) {
        return ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: false,
            itemCount: settings.connections.length,
            itemBuilder: (context, index) {
              return SiteStatsWidget(site: settings.connections[index].alias)
                  .build(context, ref);
            });
      }),
    );

    Widget leading;
    if (mySettings.showMenu) {
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

    var actions = <Widget>[];
    if (mySettings.showLogs) {
      actions.add(IconButton(
        icon: Icon(Icons.list),
        tooltip: "Logs",
        onPressed: () async {
          context.push('/logs');
        },
      ));
    }

    if (mySettings.showRefresh) {
      actions.add(IconButton(
        icon: Icon(Icons.refresh),
        tooltip: "Refresh",
        onPressed: () async {
          await refreshAction(context);
        },
      ));
    }

    if (mySettings.showSettings) {
      actions.add(IconButton(
        icon: Icon(Icons.settings),
        tooltip: "Settings",
        onPressed: () {
          context.push('/settings');
        },
      ));
    }

    if (mySettings.showSearch) {
      actions.add(IconButton(
        icon: Icon(Icons.search),
        tooltip: "Search",
        onPressed: () {
          showSearch(context: context, delegate: CustomSearchDelegate());
        },
      ));
    }

    final talker = ref.read(talkerProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer,
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing:
            mySettings.showLeading ? NavigationToolbar.kMiddleSpacing : 0.0,
        title: Text(mySettings.title),
        leading: mySettings.showLeading ? leading : null,
        actions: actions,
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshAction(context),
        child: TalkerWrapper(
          talker: talker,
          options: const TalkerWrapperOptions(
            enableErrorAlerts: true,
          ),
          child: content(context),
        ),
      ),
    );
  }
}
