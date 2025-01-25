import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../bloc/settings/settings.dart';
import 'base_slim_screen.dart';
import 'settings_languages_screen.dart';
import '../../global_router.dart';
import 'slim_router.dart';

class SettingsScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeSettings,
      uri: '/settings',
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => SettingsScreen(),
          ));

  @override
  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings(
      'Settings',
      showRefresh: false,
      showMenu: false,
      showSettings: false,
      showSearch: false,
    );
  }

  @override
  Widget content(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      final sBloc = BlocProvider.of<SettingsBloc>(context);
      final packageInfo = RepositoryProvider.of<PackageInfo>(context);

      var connectionTiles = <Widget>[];
      for (var connName in state.connections.keys) {
        var conn = state.connections[connName]!;

        connectionTiles.add(ListTile(
          title: Text(connName),
          subtitle: Text(conn.baseUrl),
          leading: Icon(Icons.settings_input_component,
              color: conn.state == SettingsConnectionStateEnum.connected
                  ? Colors.green
                  : Colors.red),
          onTap: () {
            Navigator.of(context).pushNamed(GlobalRouter().buildUri(
                routeSettingsConnection,
                buildArgs: {'name': connName}));
          },
        ));
      }

      // connectionTiles.add();

      return SettingsList(
        sections: [
          CustomSettingsSection(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Connections',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: connectionTiles.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    return connectionTiles[index];
                  },
                ),
              ])),
          CustomSettingsSection(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  onPressed: () => Navigator.of(context).pushNamed(
                      GlobalRouter().buildUri(routeSettingsConnection)),
                ),
              ],
            ),
          ),
          SettingsSection(
            title: Text('Common'),
            tiles: [
              SettingsTile(
                title: Text('Language'),
                trailing: Text('English'),
                leading: Icon(Icons.language),
                onPressed: (ctx) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SettingsLanguagesScreen()));
                },
              ),
              SettingsTile.switchTile(
                title: Text('Dark Mode'),
                leading: Icon(Icons.design_services),
                initialValue: !state.isLightMode,
                onToggle: (context) =>
                    sBloc.add(ThemeChanged(!state.isLightMode)),
              ),
              SettingsTile(
                title: Text('Refresh Time'),
                trailing: Text('${sBloc.state.refreshSeconds} Seconds'),
                leading: Icon(Icons.refresh),
                onPressed: (ctx) async {
                  var dialogResult = await showDialog<int>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      var numPicker = NumberPicker(
                        value: sBloc.state.refreshSeconds,
                        minValue: kDebugMode ? 10 : 60,
                        maxValue: 3600,
                        step: kDebugMode ? 10 : 60,
                        onChanged: (value) {
                          sBloc.add(UpdateRefresh(value));
                        },
                      );

                      return AlertDialog(
                        title: Text('Set Refresh Time in Seconds'),
                        content: numPicker,
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error),
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(null);
                            },
                          ),
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(sBloc.state.refreshSeconds);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (dialogResult != null) {
                    sBloc.add(UpdateRefresh(dialogResult));
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Misc'),
            tiles: [
              SettingsTile(
                  title: Text('Terms of Service'),
                  leading: Icon(Icons.description)),
              SettingsTile(
                title: Text('Open source licenses'),
                leading: Icon(Icons.collections_bookmark),
                onPressed: (ctx) async {
                  showLicensePage(context: ctx);
                },
              ),
            ],
          ),
          CustomSettingsSection(
            child: Column(
              children: [
                SizedBox(
                  height: 22,
                ),
                Text(
                  'Version: v${packageInfo.version} (${packageInfo.buildNumber})',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
