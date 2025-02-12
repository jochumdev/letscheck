import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:letscheck/form/connection_form/connection_form.dart';

import 'package:letscheck/screen/slim/slim_layout.dart';

class SettingsConnectionScreen extends ConsumerStatefulWidget {
  final String alias;

  SettingsConnectionScreen({required this.alias});

  @override
  SettingsConnectionScreenState createState() => SettingsConnectionScreenState(
        alias: alias,
      );
}

class SettingsConnectionScreenState
    extends ConsumerState<SettingsConnectionScreen> {
  final String alias;

  SettingsConnectionScreenState({required this.alias});

  SlimLayoutSettings settings() {
    var title = 'Add Connection';
    if (alias != '+') {
      title = "Connection: $alias";
    }

    return SlimLayoutSettings(
      title,
      showLeading: alias != '+',
      showMenu: false,
      showSettings: false,
      showSearch: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlimLayout(
      layoutSettings: settings(),
      child: SettingsList(
        sections: [
          CustomSettingsSection(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConnectionForm(alias: alias)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
