import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:letscheck/bloc/notifications/notifications.dart';
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
import 'package:flutter_js/flutter_js.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications/android.dart' as notifications_android;
import 'notifications/darwin.dart' as notifications_darwin;
import 'notifications/linux.dart' as notifications_linux;
import 'notifications/windows.dart' as notifications_windows;
import 'notifications/plugin.dart';

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

Future<JavascriptRuntime> initJavascriptRuntime() async {
  var javascriptRuntime = getJavascriptRuntime();
  if (kDebugMode) {
    javascriptRuntime.onMessage('ConsoleLog2', (args) {
      print('ConsoleLog2 (Dart Side): $args');
      return json.encode(args);
    });
  }

  try {
    var luxonJS = await rootBundle.loadString('assets/js/luxon.min.js');
    javascriptRuntime.evaluate('var window = global = globalThis;');

    await javascriptRuntime.evaluateAsync(luxonJS);
    javascriptRuntime.evaluate('const DateTime = luxon.DateTime;');
  } on PlatformException catch (e) {
    print('Failed to init js engine: ${e.details}');
  }

  return javascriptRuntime;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  if (kDebugMode) {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
  } else {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
  }

  final javascriptRuntime = await initJavascriptRuntime();

  Intl.defaultLocale = 'de_AT';
  await initializeDateFormatting('de_AT');

  final packageInfo = await PackageInfo.fromPlatform();

  var mediaWidth =
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .size
          .width;
  mediaWidth >= ultraWideLayoutThreshold
      ? registerSlimRoutes() // UltraWide
      : mediaWidth > wideLayoutThreshold
          ? registerSlimRoutes() // Wide
          : registerSlimRoutes(); // Slim

  final sBloc = SettingsBloc();
  final hdBloc = ConnectionDataBloc(sBloc: sBloc);
  final notificationsBloc = NotificationsBloc();

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
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final notificationsEnabled = await grantNotificationPermission();
  var notificationsInit =
      NotificationInit(enabled: notificationsEnabled, payload: '');
  final notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    notificationsInit = NotificationInit(
        enabled: notificationsEnabled,
        payload:
            notificationAppLaunchDetails!.notificationResponse?.payload ?? '');
  }

  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: packageInfo),
        RepositoryProvider.value(value: javascriptRuntime),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<NotificationsBloc>.value(
            value: notificationsBloc..add(notificationsInit)),
        BlocProvider<SettingsBloc>.value(value: sBloc..add(AppStarted())),
        BlocProvider<ConnectionDataBloc>.value(
            value: hdBloc..add(StartFetching())),
        BlocProvider<SearchBloc>(create: (context) => SearchBloc(sBloc: sBloc)),
        BlocProvider<CommentsBloc>(
            create: (context) => CommentsBloc(sBloc: sBloc)),
      ], child: App())));
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      BlocProvider.of<ConnectionDataBloc>(context);

      final notificationsBloc = BlocProvider.of<NotificationsBloc>(context);

      return MaterialApp(
        initialRoute: notificationsBloc.state.route,
        navigatorKey: navigatorKey,
        // navigatorObservers: <NavigatorObserver>[observer],
        debugShowCheckedModeBanner: false,
        title: 'Check_MK',
        theme: state.isLightMode ? buildLightTheme() : buildDarkTheme(),
        onGenerateRoute: (routeContext) =>
            GlobalRouter().generateRoute(routeContext),
      );
    });
  }
}
