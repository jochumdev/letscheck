import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../bloc/settings/settings.dart';
import 'base_slim_screen.dart';
import 'settings_languages_screen.dart';
import '../../global_router.dart';
import 'slim_router.dart';

class SettingsScreen extends BaseSlimScreen {
  static final route = buildRoute(
      key: routeSettings,
      uri: "/settings",
      route: (context) => MaterialPageRoute(
            settings: context,
            builder: (context) => SettingsScreen(),
          ));

  BaseSlimScreenSettings setup(BuildContext context) {
    return BaseSlimScreenSettings("Settings",
        showMenu: false, showSettings: false, showSearch: false);
  }

  @override
  Function leadingButtonAction(context) {
    return () async {
      Navigator.of(context).pop();
    };
  }

  Widget content(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      final sBloc = BlocProvider.of<SettingsBloc>(context);

      List<Widget> connectionTiles = [];
      for (var connName in state.connections.keys) {
        var conn = state.connections[connName];

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
                buildArgs: {"name": connName}));
          },
        ));
      }

      // connectionTiles.add();

      return SettingsList(
        backgroundColor: Theme.of(context).backgroundColor,
        sections: [
          CustomSection(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Connections',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
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
          CustomSection(
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
            title: 'Common',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SettingsLanguagesScreen()));
                },
              ),
              SettingsTile.switchTile(
                title: 'Dark Mode',
                leading: Icon(Icons.design_services),
                switchValue: !state.isLightMode,
                onToggle: (context) =>
                    sBloc.add(ThemeChanged(!state.isLightMode)),
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                leading: Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
              SettingsTile(
                title: 'Refresh Time',
                subtitle: '${sBloc.state.refreshSeconds} Seconds',
                leading: Icon(Icons.refresh),
                onTap: () async {
                  var dialogResult = await showDialog<int>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      var result = sBloc.state.refreshSeconds;
                      var numPicker = new NumberPicker.integer(
                        initialValue: result,
                        minValue: kDebugMode ? 10 : 60,
                        maxValue: 3600,
                        step: kDebugMode ? 10 : 60,
                        onChanged: (num) {
                          result = num;
                        },
                      );

                      return AlertDialog(
                        title: Text('Set Refresh Time in Seconds'),
                        content: numPicker,
                        actions: <Widget>[
                          RaisedButton(
                            color: Theme.of(context).errorColor,
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(null);
                            },
                          ),
                          RaisedButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop(result);
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
            title: 'Misc',
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                SizedBox(
                  height: 22,
                ),
                Text(
                  'Version: v0.0.2',
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
