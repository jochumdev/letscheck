import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: implementation_imports
import 'package:tray_manager/src/helpers/sandbox.dart' show runningInSandbox;

final LinuxInitializationSettings initializationSettings =
    LinuxInitializationSettings(
  defaultActionName: 'Open notification',
  defaultIcon: Platform.isLinux && runningInSandbox()
      ? ThemeLinuxIcon('io.github.jochumdev.letscheck')
      : AssetsLinuxIcon('assets/icons/letscheck.png'),
);
