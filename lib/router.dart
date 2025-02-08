import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/screen/slim/slim_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final empty = ref.watch(settingsProvider.select((s) => s.connections.isEmpty));
  ref.keepAlive(); // Keep the router instance alive between rebuilds
  
  return GoRouter(
    routes: slimRoutes(),
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Redirect to add connection if no connections exist
      if (empty) {
        return '/settings/connection/+';
      }
      return null;
    },
  );
});
