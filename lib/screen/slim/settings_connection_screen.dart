import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:letscheck/form/connection_form/connection_form.dart';

import 'package:letscheck/screen/slim/base_slim_screen.dart';

class SettingsConnectionScreen extends ConsumerStatefulWidget {
  final String site;

  SettingsConnectionScreen({required this.site});

  @override
  SettingsConnectionScreenState createState() => SettingsConnectionScreenState(
        site: site,
      );
}

class SettingsConnectionScreenState
    extends ConsumerState<SettingsConnectionScreen> with BaseSlimScreenState {
  final String site;

  SettingsConnectionScreenState({required this.site});

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    var title = 'Add Connection';
    if (site != '+') {
      title = "Connection: $site";
    }

    return BaseSlimScreenSettings(
      title,
      showLeading: site != '+',
      showRefresh: false,
      showMenu: false,
      showSettings: false,
      showSearch: false,
    );
  }

  @override
  Widget content(BuildContext context) {
    var titleColor = Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(211, 227, 253, 1)
        : Color.fromRGBO(11, 87, 208, 1);

    return SettingsList(
      sections: [
        CustomSettingsSection(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site != '+' ? 'Connection: $site' : 'Add Connection',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: titleColor),
                ),
                ConnectionForm(alias: site)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
