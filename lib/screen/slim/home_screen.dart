import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/widget/site_stats_widget.dart';
import 'package:letscheck/widget/services_list_widget.dart';
import 'package:letscheck/widget/tab_controller_listener.dart';
import 'package:letscheck/providers/providers.dart';

import 'package:letscheck/screen/slim/base_slim_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with BaseSlimScreenState {
  @override
  void initState() {
    super.initState();

    // Schedule the state update for after the build
    Future.microtask(() {
      final settings = ref.read(settingsProvider);
      if (settings.connections.length == 1) {
        final alias = settings.connections.keys.first;
        ref.read(settingsProvider.notifier).setCurrentSite(alias);
      }
    });
  }

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('Home', showRefresh: !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows), showSettings: true);
  }

  @override
  Widget content(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final connectionData = ref.watch(connectionProvider(settings.currentAlias));

    if (settings.connections.length > 1) {
      return DefaultTabController(
        length: settings.connections.length,
        child: TabControllerListener(
          onTabSelected: (int index) {
            ref.read(settingsProvider.notifier).setCurrentSite(
                  settings.connections.keys.elementAt(index),
                );
          },
          child: TabBarView(
            children: settings.connections.keys.map((site) {
              final connection = ref.watch(connectionProvider(site));
              return switch (connection) {
                ConnectionInitial() => Container(),
                ConnectionLoaded(unhServices: final unhServices) => Column(
                    children: [
                      SiteStatsWidget(
                        site: site,
                      ),
                      Expanded(
                          child: ServicesListWidget(
                        alias: site,
                        services: unhServices.toList(),
                        listKey: PageStorageKey('home_services_$site'),
                      )),
                      const TabPageSelector(),
                    ],
                  ),
                ConnectionError(message: final message, error: final error) =>
                  Column(
                    children: [
                      SiteStatsWidget(
                        site: site,
                      ),
                      Expanded(
                          child: Center(
                              child: Text('$message, error was: $error'))),
                      const TabPageSelector(),
                    ],
                  ),
              };
            }).toList(),
          ),
        ),
      );
    } else if (settings.connections.length == 1) {
      final site = settings.connections.keys.first;

      return switch (connectionData) {
        ConnectionInitial() => Container(),
        ConnectionLoaded(unhServices: final unhServices) => Column(
            children: [
              SiteStatsWidget(
                site: site,
              ),
              Expanded(
                  child: ServicesListWidget(
                alias: site,
                services: unhServices.toList(),
                listKey: PageStorageKey('home_services_$site'),
              )),
            ],
          ),
        ConnectionError(message: final message, error: final error) => Column(
            children: [
              SiteStatsWidget(
                site: site,
              ),
              Expanded(
                  child: Center(child: Text('$message, error was: $error'))),
              const TabPageSelector(),
            ],
          ),
      };
    }

    return Container();
  }
}
