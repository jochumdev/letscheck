import 'dart:async';
import 'dart:io' show Platform, Directory;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/javascript/javascript.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:window_manager/window_manager.dart';

import 'package:tray_manager/tray_manager.dart';
// ignore: implementation_imports
import 'package:tray_manager/src/helpers/sandbox.dart' show runningInSandbox;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications/android.dart' as notifications_android;
import 'notifications/darwin.dart' as notifications_darwin;
import 'notifications/linux.dart' as notifications_linux;
import 'notifications/windows.dart' as notifications_windows;
import 'notifications/plugin.dart';

import 'theme_data.dart';
import 'background_service.dart' as bg_service;

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

  if (!kIsWeb) {
    await _configureLocalTimeZone();
  }

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize window manager if not web
  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    await windowManager.ensureInitialized();
    // await windowManager.setPreventClose(true);
  }

  await initializeDateFormatting(Intl.defaultLocale);

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

  final talker =
      Talker(logger: TalkerLogger(formatter: ColoredLoggerFormatter()));

  final jsRuntime = await initJavascriptRuntime();

  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
            settings: TalkerRiverpodLoggerSettings(
              enabled: true,
              printProviderAdded: true,
              printProviderUpdated: false,
              printProviderDisposed: true,
              printProviderFailed: true,
            ),
            talker: talker),
      ],
      overrides: [
        talkerProvider.overrideWithValue(talker),
        sharedPreferencesProvider.overrideWithValue(prefs),
        javascriptRuntimeProvider.overrideWithValue(jsRuntime),
        packageInfoProvider.overrideWithValue(packageInfo),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with TrayListener {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      trayManager.addListener(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = ref.watch(settingsProvider.select((s) => s.isLightMode));
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'LetsCheck',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,
    );
  }

  @override
  void dispose() {
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
    } else if (menuItem.key == 'hide_window') {
      await windowManager.hide();
    } else if (menuItem.key == 'exit_app') {
      await windowManager.destroy();
    }
  }
}
