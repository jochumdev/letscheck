import 'dart:ui';
import 'dart:async';
import 'dart:io' show Platform, Directory;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'bloc/settings/settings.dart';
import 'bloc/connection_data/connection_data.dart';
import 'bloc/search/search.dart';
import 'bloc/comments/comments.dart';
import 'theme_data.dart';
import 'screen/slim/slim_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:window_manager/window_manager.dart';

import 'package:tray_manager/tray_manager.dart';
// ignore: implementation_imports
import 'package:tray_manager/src/helpers/sandbox.dart' show runningInSandbox;

import 'package:letscheck/javascript/javascript.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications/android.dart' as notifications_android;
import 'notifications/darwin.dart' as notifications_darwin;
import 'notifications/linux.dart' as notifications_linux;
import 'notifications/windows.dart' as notifications_windows;
import 'notifications/plugin.dart';

import 'bg_service.dart' as bg_service;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialized in the `main` function
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

const MethodChannel platform = MethodChannel('jochum.dev/letscheck');

const String portName = 'notification_send_port';

/// layout.
const double ultraWideLayoutThreshold = 1920;

const double wideLayoutThreshold = 1200;

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<String> getAppConfigDirectory() async {
  if (Platform.isLinux) {
    var path = "";
    if (Platform.environment.containsKey("XDG_CONFIG_HOME")) {
      var xdgConfigHome = Platform.environment["XDG_CONFIG_HOME"]!;
      path = "$xdgConfigHome/letscheck";
    } else {
      var documents = (await getApplicationDocumentsDirectory()).path;
      path = "$documents/letscheck";
    }
    await Directory(path).create(recursive: true);
    return path;
  }

  return (await getApplicationDocumentsDirectory()).path;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    final fontsLicense = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], fontsLicense);
  });

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    await windowManager.ensureInitialized();
  }

  await _configureLocalTimeZone();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            await getAppConfigDirectory(),
          ),
  );

  await initializeDateFormatting(Intl.defaultLocale);

  final sBloc = SettingsBloc();
  final hdBloc = ConnectionDataBloc(sBloc: sBloc);

  if (!kIsWeb) {
    final initializationSettings = InitializationSettings(
      android: notifications_android.initializationSettings,
      iOS: notifications_darwin.initializationSettings,
      macOS: notifications_darwin.initializationSettings,
      linux: notifications_linux.initializationSettings,
      windows: notifications_windows.initializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
    );
    await grantNotificationPermission();
  }

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 1000),
      center: false,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle:
          Platform.isWindows ? TitleBarStyle.normal : TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/letscheck.ico'
          : Platform.isLinux && runningInSandbox()
              ? 'io.github.jochumdev.letscheck'
              : 'assets/icons/letscheck.png',
    );
    await trayManager.setTitle("LetsCheck");

    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await bg_service.initialize();
    bg_service.start();
  }

  final javascriptRuntime = await initJavascriptRuntime();

  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: await PackageInfo.fromPlatform()),
        RepositoryProvider.value(value: javascriptRuntime),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<SettingsBloc>.value(value: sBloc..add(AppStarted())),
        BlocProvider<ConnectionDataBloc>.value(
            value: hdBloc..add(ConnectionDataStartFetching())),
        BlocProvider<SearchBloc>(create: (context) => SearchBloc(sBloc: sBloc)),
        BlocProvider<CommentsBloc>(
            create: (context) => CommentsBloc(sBloc: sBloc)),
      ], child: App())));
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with TrayListener {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    trayManager.addListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaWidth =
        MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
            .size
            .width;
    final routes = mediaWidth >= ultraWideLayoutThreshold
        ? slimRoutes() // UltraWide
        : mediaWidth > wideLayoutThreshold
            ? slimRoutes() // Wide
            : slimRoutes(); // Slim

    final router = GoRouter(
      routes: routes,
      debugLogDiagnostics: true,
      redirect: (context, state) async {
        if (context.read<SettingsBloc>().state.connections.isEmpty) {
          return '/settings/connection/+';
        }
        return null;
      },
    );

    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      BlocProvider.of<ConnectionDataBloc>(context);

      return MaterialApp.router(
        routerConfig: router,
        // navigatorObservers: <NavigatorObserver>[observer],
        debugShowCheckedModeBanner: false,
        title: 'LetsCheck',
        theme: state.isLightMode ? buildLightTheme() : buildDarkTheme(),
      );
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.focus();
        break;
      case 'exit_app':
        await windowManager.destroy();
        break;
      default:
      // no action.
    }
  }
}
