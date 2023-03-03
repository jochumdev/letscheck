import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
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
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_js/flutter_js.dart';

/// layout.
const double ultraWideLayoutThreshold = 1920;

const double wideLayoutThreshold = 1200;

Future<JavascriptRuntime> initJavascriptRuntime() async {
  var javascriptRuntime = getJavascriptRuntime();
  if (kDebugMode) {
    javascriptRuntime.onMessage('ConsoleLog2', (args) {
      print('ConsoleLog2 (Dart Side): $args');
      return json.encode(args);
    });
  }

  try {
    String luxonJS = await rootBundle.loadString("assets/js/luxon.min.js");
    javascriptRuntime.evaluate("var window = global = globalThis;");

    await javascriptRuntime.evaluateAsync(luxonJS + "");
    javascriptRuntime.evaluate("const DateTime = luxon.DateTime;");
  } on PlatformException catch (e) {
    print('Failed to init js engine: ${e.details}');
  }

  return javascriptRuntime;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

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

  var mediaWidth = MediaQueryData.fromWindow(window).size.width;
  mediaWidth >= ultraWideLayoutThreshold
      ? registerSlimRoutes() // UltraWide
      : mediaWidth > wideLayoutThreshold
          ? registerSlimRoutes() // Wide
          : registerSlimRoutes(); // Slim

  final sBloc = SettingsBloc();
  final hdBloc = ConnectionDataBloc(sBloc: sBloc);

  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: packageInfo),
        RepositoryProvider.value(value: javascriptRuntime),
      ],
      child: MultiBlocProvider(providers: [
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

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      BlocProvider.of<ConnectionDataBloc>(context);

      return MaterialApp(
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
