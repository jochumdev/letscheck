import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../form/connection_form/connection_form.dart';
import '../../bloc/settings/settings.dart';
import 'base_slim_screen.dart';
import '../../global_router.dart';

class SettingsConnectionScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeSettingsConnection,
      uri: '/settings/connection/{name}',
      lastArgOptional: true,
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => SettingsConnectionScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    final groups = SettingsConnectionScreen.route.extractNamedArgs(context);
    var title = 'Add Connection';
    if (groups.containsKey('name')) {
      title = "Connection: ${groups["name"]}";
    }

    return BaseSlimScreenSettings(title,
        showMenu: false, showSettings: false, showSearch: false);
  }

  @override
  Widget content(BuildContext context) {
    final groups = SettingsConnectionScreen.route.extractNamedArgs(context);

    final sBloc = BlocProvider.of<SettingsBloc>(context);

    if (groups.containsKey('name')) {
      var alias = groups['name']!;

      return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: BlocProvider(
            create: (context) => ConnectionFormBloc(
                  settingsBloc: sBloc,
                  connectionAlias: alias,
                  connection: sBloc.state.connections[alias]!,
                  isEditing: true,
                ),
            child: ConnectionFormWidget(alias: alias)),
      );
    }

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: BlocProvider(
          create: (context) => ConnectionFormBloc(
                settingsBloc: sBloc,
              ),
          child: ConnectionFormWidget()),
    );
  }
}
