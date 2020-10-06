import '../../global_router.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'settings_connection_screen.dart';
import 'not_found_screen.dart';
import 'hosts_screen.dart';
import 'services_screen.dart';
import 'host_screen.dart';
import 'service_screen.dart';

export '../../global_router.dart';

void registerSlimRoutes() {
  GlobalRouter().add(HomeScreen.route);
  GlobalRouter().add(SplashScreen.route);
  GlobalRouter().add(SettingsScreen.route);
  GlobalRouter().add(SettingsConnectionScreen.route);
  GlobalRouter().add(NotFoundScreen.route);
  GlobalRouter().add(HostsScreen.route);
  GlobalRouter().add(ServicesScreen.route);
  GlobalRouter().add(HostScreen.route);
  GlobalRouter().add(ServiceScreen.route);

  assert(GlobalRouter().validateRoutes());
}