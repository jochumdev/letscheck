import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/screen/slim/slim_layout.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  SlimLayoutSettings layoutSettings() {
    return SlimLayoutSettings(
      'Settings',
      showMenu: false,
      showSettings: false,
      showSearch: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final packageInfo = ref.read(packageInfoProvider);

    var connectionTiles = <Widget>[];
    for (final cSettings in settings.connections) {
      final clientState = ref.watch(clientStateProvider(cSettings.alias));

      connectionTiles.add(ListTile(
        title: Text(cSettings.alias),
        subtitle: Text(cSettings.baseUrl),
        leading: Icon(Icons.settings_input_component,
            color: clientState.value == cmk_api.ConnectionState.connected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error),
        trailing: IconButton(
            onPressed: () => settingsNotifier.deleteConnection(cSettings),
            icon: Icon(Icons.delete, color: Colors.red)),
        onTap: () {
          context.push(
              '/settings/connection/${Uri.encodeComponent(cSettings.alias)}');
        },
      ));
    }

    var titleColor = Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(211, 227, 253, 1)
        : Color.fromRGBO(11, 87, 208, 1);

    return SlimLayout(
      layoutSettings: layoutSettings(),
      child: SettingsList(
        sections: [
          CustomSettingsSection(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connections',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: titleColor),
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
                ],
              ),
            ),
          ),
          CustomSettingsSection(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  color: titleColor,
                  iconSize: 32,
                  onPressed: () => context.push('/settings/connection/+'),
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
                  context.push('/settings/languages');
                },
              ),
              SettingsTile.switchTile(
                title: Text('Dark Mode'),
                leading: Icon(Icons.design_services),
                initialValue: !settings.isLightMode,
                onToggle: (context) =>
                    settingsNotifier.setTheme(!settings.isLightMode),
              ),
              SettingsTile.navigation(
                title: Text('Refresh Time'),
                trailing: Text('${settings.refreshSeconds} Seconds'),
                leading: Icon(Icons.refresh),
                onPressed: (ctx) async {
                  final controller = TextEditingController(
                    text: settings.refreshSeconds.toString(),
                  );

                  final result = await showModalBottomSheet<int>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Refresh Interval',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Seconds',
                                  helperText:
                                      'Enter a value between 10 and 3600 seconds',
                                ),
                                onSubmitted: (text) {
                                  final value = int.tryParse(text);
                                  if (value != null &&
                                      value >= 10 &&
                                      value <= 3600) {
                                    Navigator.pop(context, value);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      final value =
                                          int.tryParse(controller.text);
                                      if (value != null &&
                                          value >= 10 &&
                                          value <= 3600) {
                                        Navigator.pop(context, value);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (result != null) {
                    await settingsNotifier.updateRefreshSeconds(result);
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
          SettingsSection(
            title: Text('Debug'),
            tiles: [
              SettingsTile(
                title: Text('Logs'),
                leading: Icon(Icons.list),
                onPressed: (ctx) async {
                  context.push('/logs');
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
      ),
    );
  }
}
