import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../global_router.dart';
import '../../bloc/settings/settings.dart';

class SplashScreen extends StatelessWidget {
  static final route = buildRoute(
      key: routeSplash,
      uri: '/pages/splash',
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => SplashScreen(),
          ));

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) {
        return previous.state != current.state;
      },
      listener: (context, state) {
        switch (state.state) {
          case SettingsStateEnum.noConnection:
            Navigator.of(context)
                .pushReplacementNamed(GlobalRouter().buildUri(routeHome));
            Navigator.of(context)
                .pushNamed(GlobalRouter().buildUri(routeSettings));
            Navigator.of(context)
                .pushNamed(GlobalRouter().buildUri(routeSettingsConnection));
            break;
          case SettingsStateEnum.connected:
            Navigator.of(context)
                .pushReplacementNamed(GlobalRouter().buildUri(routeHome));
            break;
          case SettingsStateEnum.failed:
            Navigator.of(context)
                .pushReplacementNamed(GlobalRouter().buildUri(routeHome));
            Navigator.of(context)
                .pushNamed(GlobalRouter().buildUri(routeSettings));
            break;
          default:
        }
      },
      child: Container(
        child: Image.asset('assets/icons/letscheck.png'),
      ),
    );
  }
}
