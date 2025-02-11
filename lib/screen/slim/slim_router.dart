import 'package:go_router/go_router.dart';

import 'package:letscheck/screen/slim/settings_languages_screen.dart';
import 'package:letscheck/screen/slim/connection_screen.dart';
import 'package:letscheck/screen/slim/settings_screen.dart';
import 'package:letscheck/screen/slim/settings_connection_screen.dart';
import 'package:letscheck/screen/slim/not_found_screen.dart';
import 'package:letscheck/screen/slim/hosts_screen.dart';
import 'package:letscheck/screen/slim/services_screen.dart';
import 'package:letscheck/screen/slim/host_screen.dart';
import 'package:letscheck/screen/slim/service_screen.dart';
import 'package:letscheck/screen/slim/log_screen.dart';

List<RouteBase> slimRoutes() {
  return [
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/connection/:alias',
      builder: (context, state) => SettingsConnectionScreen(
        alias: state.pathParameters['alias']!,
      ),
    ),
    GoRoute(
      path: '/settings/languages',
      builder: (context, state) => SettingsLanguagesScreen(),
    ),
    GoRoute(
      path: '/logs',
      builder: (context, state) => LogScreen(),
    ),
    GoRoute(
      path: '/error/404',
      builder: (context, state) => NotFoundScreen(),
    ),
    GoRoute(
      path: '/conn/:alias',
      builder: (context, state) => ConnectionScreen(
        alias: state.pathParameters['alias']!,
      ),
    ),
    GoRoute(
      path: '/conn/:alias/host/:hostname',
      builder: (context, state) => HostScreen(
        alias: state.pathParameters['alias']!,
        hostname: state.pathParameters['hostname']!,
      ),
    ),
    GoRoute(
      path: '/conn/:alias/hosts/:filter',
      builder: (context, state) => HostsScreen(
        alias: state.pathParameters['alias']!,
        filter: state.pathParameters['filter']!,
      ),
    ),
    GoRoute(
      path: '/conn/:alias/host/:hostname/services/:service',
      builder: (context, state) => ServiceScreen(
        alias: state.pathParameters['alias']!,
        hostname: state.pathParameters['hostname']!,
        service: state.pathParameters['service']!,
      ),
    ),
    GoRoute(
      path: '/conn/:alias/services/:filter',
      builder: (context, state) => ServicesScreen(
        alias: state.pathParameters['alias']!,
        filter: state.pathParameters['filter']!,
      ),
    ),
  ];
}
