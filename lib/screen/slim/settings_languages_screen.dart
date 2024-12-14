import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsLanguagesScreen extends StatefulWidget {
  @override
  _SettingsLanguagesScreen createState() => _SettingsLanguagesScreen();
}

class _SettingsLanguagesScreen extends State<SettingsLanguagesScreen> {
  int languageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Languages')),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: Text('English'),
              trailing: trailingWidget(0),
              onPressed: (ctx) {
                changeLanguage(0);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (languageIndex == index)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  void changeLanguage(int index) {
    setState(() {
      languageIndex = index;
    });
  }
}
