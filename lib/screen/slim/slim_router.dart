import 'package:go_router/go_router.dart';

import 'settings_languages_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'settings_connection_screen.dart';
import 'not_found_screen.dart';
import 'hosts_screen.dart';
import 'services_screen.dart';
import 'host_screen.dart';
import 'service_screen.dart';

List<GoRoute> slimRoutes() {
  return [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
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
      path: '/error/404',
      builder: (context, state) => NotFoundScreen(),
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
    GoRoute(
      path: '/settings/connection/:name',
      builder: (context, state) => SettingsConnectionScreen(
        alias: state.pathParameters['name']!,
      ),
    ),
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => SettingsLanguagesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
  ];
}
