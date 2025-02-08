import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/providers/providers.dart';
import 'package:letscheck/screen/slim/base_slim_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen>
    with BaseSlimScreenState {

  @override
  void initState() {
    super.initState();
  }
  
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
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

     return ref.watch(packageInfoProvider).when(
        data: (packageInfo) {
          var connectionTiles = <Widget>[];
          for (final site in settings.connections.keys) {
            final conn = ref.watch(connectionProvider(site));

            connectionTiles.add(ListTile(
              title: Text(site),
              subtitle: Text(settings.connections[site]!.baseUrl),
              leading: Icon(Icons.settings_input_component,
                  color: conn is ConnectionLoaded
                      ? Colors.green
                      : Colors.red),
              trailing: IconButton(onPressed: () => settingsNotifier.deleteConnection(site), icon: Icon(Icons.delete, color: Colors.red)) ,
              onTap: () {
                context.push('/settings/connection/$site');
              },
            ));
          }

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
                      onToggle: (context) => settingsNotifier.setTheme(!settings.isLightMode),
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
                                        helperText: 'Enter a value between 10 and 3600 seconds',
                                      ),
                                      onSubmitted: (text) {
                                        final value = int.tryParse(text);
                                        if (value != null && value >= 10 && value <= 3600) {
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
                                            final value = int.tryParse(controller.text);
                                            if (value != null && value >= 10 && value <= 3600) {
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
        },
        error: (e, _) => Text('Error: $e'),
        loading: () => Center(child: CircularProgressIndicator()),
      );
  }
}
