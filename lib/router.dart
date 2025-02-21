import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/screen/slim/slim_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);
  final connections = settings.connections;
  final noConnection = connections.isEmpty;
  ref.keepAlive(); // Keep the router instance alive between rebuilds

  final talker = ref.read(talkerProvider);

  return GoRouter(
    observers: [TalkerRouteObserver(talker)],
    routes: slimRoutes(),
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Redirect to add connection if no connections exist
      if (noConnection) {
        return '/settings/connection/+';
      } else if (state.uri.toString() == '/') {
        if (settings.currentAlias.isEmpty) {
          return '/conn/${connections.first.alias}';
        } else {
          return '/conn/${settings.currentAlias}';
        }
      }
      return null;
    },
  );
});
