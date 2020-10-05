import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../form/connection_form/connection_form.dart';
import '../../bloc/settings/settings.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class SettingsConnectionScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeSettingsConnection,
      uri: "/settings/connection/{name}",
      lastArgOptional: true,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => SettingsConnectionScreen(),
          ));

  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = SettingsConnectionScreen.route.extractNamedArgs(context);
    String title = "Add Connection";
    if (groups.containsKey("name")) {
      title = "Connection: ${groups["name"]}";
    }

    return BaseSlimScreenSettings(title,
        showMenu: false, showSettings: false, showSearch: false);
  }

  Widget content(BuildContext context) {
    final groups = SettingsConnectionScreen.route.extractNamedArgs(context);

    if (!groups.containsKey("name")) {
      return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: BlocProvider(
            create: (context) => ConnectionFormBloc(
                  settingsBloc: BlocProvider.of<SettingsBloc>(context),
                ),
            child: ConnectionFormWidget()),
      );
    }

    var alias = groups["name"];
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: BlocProvider(
          create: (context) => ConnectionFormBloc(
                settingsBloc: BlocProvider.of<SettingsBloc>(context),
                connectionAlias: alias,
                connection: sBloc.state.connections[alias],
                isEditing: true,
              ),
          child: ConnectionFormWidget(alias: alias)),
    );
  }
}
