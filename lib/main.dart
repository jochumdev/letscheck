import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'global_router.dart';
import 'bloc/settings/settings.dart';
import 'bloc/connection_data/connection_data.dart';
import 'bloc/search/search.dart';
import 'theme_data.dart';
import 'screen/slim/slim_router.dart';
import 'package:flutter_bloc_monitor/flutter_bloc_monitor.dart';

/// layout.
const double ultraWideLayoutThreshold = 1920;

const double wideLayoutThreshold = 1200;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Bloc.observer = FlutterBlocMonitorDelegate(
      onEventFunc: (bloc, event) => print(event),
      onTransitionFunc: (bloc, transition) => print(transition),
      onErrorFunc: (bloc, error, stacktrace) => print(error),
    );

    HydratedBloc.storage = await HydratedStorage.build();
  } else {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
  }

  var mediaWidth = MediaQueryData.fromWindow(window).size.width;
  mediaWidth >= ultraWideLayoutThreshold
      ? registerSlimRoutes() // UltraWide
      : mediaWidth > wideLayoutThreshold
          ? registerSlimRoutes() // Wide
          : registerSlimRoutes(); // Slim

  final sBloc = new SettingsBloc();
  final hdBloc = new ConnectionDataBloc(sBloc: sBloc);

  runApp(MultiBlocProvider(providers: [
    BlocProvider<SettingsBloc>.value(value: sBloc..add(AppStarted())),
    BlocProvider<ConnectionDataBloc>.value(value: hdBloc..add(StartFetching())),
    BlocProvider<SearchBloc>(create: (context) => SearchBloc(sBloc: sBloc)),
  ], child: App()));
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      BlocProvider.of<ConnectionDataBloc>(context);

      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Check_MK',
        theme: state.isLightMode ? buildLightTheme() : buildDarkTheme(),
        onGenerateRoute: (routeContext) =>
            GlobalRouter().generateRoute(routeContext),
      );
    });
  }
}
