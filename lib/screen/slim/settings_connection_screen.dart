import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../form/connection_form/connection_form.dart';
import '../../bloc/settings/settings.dart';
import 'base_slim_screen.dart';

class SettingsConnectionScreen extends StatefulWidget {
  final String alias;

  SettingsConnectionScreen({required this.alias});

  @override
  SettingsConnectionScreenState createState() => SettingsConnectionScreenState(
        alias: alias,
      );
}

class SettingsConnectionScreenState extends State<SettingsConnectionScreen>
    with BaseSlimScreenState {
  final String alias;

  SettingsConnectionScreenState({required this.alias});

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Add Connection';
    if (alias != '+') {
      title = "Connection: $alias";
    }

    return BaseSlimScreenSettings(
      title,
      showLeading: alias != '+',
      showRefresh: false,
      showMenu: false,
      showSettings: false,
      showSearch: false,
    );
  }

  @override
  Widget content(BuildContext context) {
    final sBloc = BlocProvider.of<SettingsBloc>(context);

    if (alias != '+') {
      return BlocProvider(
        create: (context) => ConnectionFormBloc(
          settingsBloc: sBloc,
          connectionAlias: alias,
          connection: sBloc.state.connections[alias]!,
          isEditing: true,
        ),
        child: ConnectionFormWidget(alias: alias),
      );
    }

    return BlocProvider(
      create: (context) => ConnectionFormBloc(
        settingsBloc: sBloc,
      ),
      child: ConnectionFormWidget(),
    );
  }
}
