import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/params.dart';
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
  List<AliasAndFilterParams>? _params;

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings('Home',
        showRefresh: true,
        showSettings: true);
  }

  @override
  Widget content(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Initialize params if needed
    if (_params == null) {
      _params = settings.connections
          .map((c) => AliasAndFilterParams(alias: c.alias, filter: []))
          .toList(growable: false);

      if (settings.connections.length == 1) {
        ref
            .read(settingsProvider.notifier)
            .setCurrentSite(settings.connections.first.alias);
      }
    }

    if (_params!.isEmpty) {
      return const Center(child: Text('No connections configured'));
    }

    return DefaultTabController(
      length: _params!.length,
      child: TabControllerListener(
        onTabSelected: (int index) {
          ref.read(settingsProvider.notifier).setCurrentSite(
                _params![index].alias,
              );
        },
        child: TabBarView(
          children: _params!.map((params) {
            final alias = params.alias;
            final connectionData = ref.watch(connectionDataProvider(alias));
            return switch (connectionData) {
              ConnectionDataInitial() => Container(),
              ConnectionDataLoaded(unhServices: final unhServices) => Column(
                  children: [
                    SiteStatsWidget(
                      site: alias,
                    ),
                    Expanded(
                        child: ServicesListWidget(
                      alias: alias,
                      services: unhServices.toList(),
                      listKey: PageStorageKey('home_services_$alias'),
                    )),
                    const TabPageSelector(),
                  ],
                ),
              ConnectionDataError(error: final error) => Column(
                  children: [
                    SiteStatsWidget(
                      site: alias,
                    ),
                    Expanded(child: Center(child: Text('$error!'))),
                    const TabPageSelector(),
                  ],
                ),
            };
          }).toList(),
        ),
      ),
    );
  }
}
