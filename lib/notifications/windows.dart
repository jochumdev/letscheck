import 'package:flutter_local_notifications/flutter_local_notifications.dart';

WindowsInitializationSettings initializationSettings =
    WindowsInitializationSettings(
  appName: 'Letscheck',
  appUserModelId: 'io.github.jochumdev.letscheck',
  guid: '7dba2765-0e22-4048-b0f9-80ab10eba346',
  iconPath: WindowsImage.getAssetUri('assets/icons/letscheck.png').path,
);
