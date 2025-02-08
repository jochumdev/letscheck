import 'package:go_router/go_router.dart';

import 'package:letscheck/screen/slim/settings_languages_screen.dart';
import 'package:letscheck/screen/slim/home_screen.dart';
import 'package:letscheck/screen/slim/settings_screen.dart';
import 'package:letscheck/screen/slim/settings_connection_screen.dart';
import 'package:letscheck/screen/slim/not_found_screen.dart';
import 'package:letscheck/screen/slim/hosts_screen.dart';
import 'package:letscheck/screen/slim/services_screen.dart';
import 'package:letscheck/screen/slim/host_screen.dart';
import 'package:letscheck/screen/slim/service_screen.dart';

List<RouteBase> slimRoutes() {
  return [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/:alias/host/:hostname',
      builder: (context, state) => HostScreen(
        site: state.pathParameters['alias']!,
        hostname: state.pathParameters['hostname']!,
      ),
    ),
    GoRoute(
      path: '/:alias/hosts/:filter',
      builder: (context, state) => HostsScreen(
        site: state.pathParameters['alias']!,
        filter: state.pathParameters['filter']!,
      ),
    ),
    GoRoute(
      path: '/error/404',
      builder: (context, state) => NotFoundScreen(),
    ),
    GoRoute(
      path: '/:alias/host/:hostname/services/:service',
      builder: (context, state) => ServiceScreen(
        site: state.pathParameters['alias']!,
        hostname: state.pathParameters['hostname']!,
        service: state.pathParameters['service']!,
      ),
    ),
    GoRoute(
      path: '/:alias/services/:filter',
      builder: (context, state) => ServicesScreen(
        site: state.pathParameters['alias']!,
        filter: state.pathParameters['filter']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/connection/:alias',
      builder: (context, state) => SettingsConnectionScreen(
        site: state.pathParameters['alias']!,
      ),
    ),
    GoRoute(
      path: '/settings/languages',
      builder: (context, state) => SettingsLanguagesScreen(),
    ),
  ];
}
