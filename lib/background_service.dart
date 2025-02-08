import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:letscheck/providers/settings/settings_state.dart';
import 'package:letscheck/services/connectivity_service.dart';
import 'package:mutex/mutex.dart';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/notifications/plugin.dart';
import 'package:letscheck/notifications/android.dart' as android;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initialize() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    android.notificationChannelId, // id
    'LetsCheck', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at least 'low'
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
      isForegroundMode: kDebugMode,
      autoStartOnBoot: true,
      notificationChannelId: android.notificationChannelId,
      initialNotificationContent: "Fetching notifications",
      foregroundServiceNotificationId: 1234,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

Mutex? mutex = Mutex();
Timer? timer;

var refreshSeconds = 60;
var clients = <String, cmk_api.Client>{};
var enabled = <String, bool>{};
var wifiOnly = <String, bool>{};

void _fetchAndRunNotificiations(Timer? timer) async {
  try {
    mutex!.acquire();

    for (final alias in clients.keys) {
      if (enabled[alias]!) {
        if (clients.containsKey(alias)) {
          if (wifiOnly[alias]! && !await ConnectivityService.isOnWifi()) {
            continue;
          }

          final client = clients[alias]!;

          sendNotificationsForConnection(
            conn: alias,
            client: client,
            refreshSeconds: refreshSeconds,
          );
        }
      }
    }
  } finally {
    mutex!.release();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on('start').listen((event) async {
    try {
      mutex ??= Mutex();
      mutex!.acquire();

      // Cancel old timer.
      timer?.cancel();

      // Create new timer.
      timer = Timer.periodic(
        Duration(seconds: refreshSeconds),
        _fetchAndRunNotificiations,
      );
    } finally {
      mutex!.release();
    }
  });

  service.on('stop').listen((event) async {
    try {
      mutex!.acquire();

      // Cancel the timer.
      timer?.cancel();
    } finally {
      mutex!.release();
    }
  });

  service.on('settings').listen((settings) async {
    // Ignore invalid settings.
    if (settings == null) {
      return;
    }

    try {
      mutex!.acquire();

      // read settings.
      var recreate = false;
      if (settings.containsKey("refresh_seconds")) {
        recreate = refreshSeconds != settings["refresh_seconds"];
        refreshSeconds = settings["refresh_seconds"];
      }
      if (settings.containsKey('connections')) {
        for (final alias in settings['connections'].keys) {
          final cSettings = settings['connections'][alias]!;

          enabled[alias] = cSettings['enabled'];
          wifiOnly[alias] = cSettings['wifi_only'];

          if (enabled[alias]!) {
            var client = cmk_api.Client(
              cmk_api.ClientSettings(
                baseUrl: cSettings['url'],
                site: cSettings['site'],
                username: cSettings['username'],
                secret: cSettings['password'],
                validateSsl: !cSettings['insecure'],
              ),
            );

            clients[cSettings['site']] = client;
          }
        }
      }

      if (recreate) {
        // Cancel old timer.
        timer?.cancel();

        // Fetch now, the timer fetches then again later.
        _fetchAndRunNotificiations(timer);

        // Create new timer.
        timer = Timer.periodic(
          Duration(seconds: refreshSeconds),
          _fetchAndRunNotificiations,
        );
      }
    } finally {
      mutex!.release();
    }
  });
}

void sendSettings(SettingsState state) async {
  Map<String, dynamic> settings = {};
  settings['connections'] = <String, Map<String, dynamic>>{};

  settings['refresh_seconds'] = state.refreshSeconds;

  for (final alias in state.connections.keys) {
    final conn = state.connections[alias]!;

    Map<String, dynamic> cSettings = {};

    cSettings['site'] = conn.site;
    cSettings['url'] = conn.baseUrl;
    cSettings['username'] = conn.username;
    cSettings['password'] = conn.password;
    cSettings['insecure'] = conn.insecure;
    cSettings['enabled'] = conn.sendNotifications;
    cSettings['wifi_only'] = conn.wifiOnly;

    settings['connections'][alias] = cSettings;
  }

  FlutterBackgroundService().invoke('settings', settings);
}

void start() {
  FlutterBackgroundService().invoke('start');
}

void stop() {
  FlutterBackgroundService().invoke('stop');
}
