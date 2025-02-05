import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mutex/mutex.dart';

import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/bloc/settings/settings.dart';
import 'package:letscheck/notifications/plugin.dart';
import 'package:letscheck/notifications/android.dart' as android;

Future<void> initialize() async {
  final service = FlutterBackgroundService();
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

void _fetchAndRunNotificiations(Timer? timer) async {
  try {
    mutex!.acquire();

    for (var alias in clients.keys) {
      if (enabled[alias]!) {
        if (clients.containsKey(alias)) {
          var client = clients[alias]!;

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
      if (settings.containsKey('clients')) {
        for (var cSettings
            in (settings['clients'] as Map<String, dynamic>).values) {
          enabled[cSettings['site']] = cSettings['enabled'];

          if (enabled[cSettings['site']]!) {
            var client = cmk_api.Client(
              cmk_api.ClientSettings(
                baseUrl: cSettings['base_url'],
                site: cSettings['site'],
                username: cSettings['username'],
                secret: cSettings['secret'],
                validateSsl: cSettings['validate_ssl'],
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
  settings['clients'] = <String, Map<String, dynamic>>{};

  settings['refresh_seconds'] = state.refreshSeconds;

  for (var conn in state.connections.values) {
    Map<String, dynamic> cSettings = {};

    cSettings['base_url'] = conn.baseUrl;
    cSettings['site'] = conn.site;
    cSettings['username'] = conn.username;
    cSettings['secret'] = conn.secret;
    cSettings['validate_ssl'] = conn.validateSsl;
    cSettings['enabled'] = conn.notifications;

    settings['clients'][conn.site] = cSettings;
  }

  FlutterBackgroundService().invoke('settings', settings);
}

void start() {
  FlutterBackgroundService().invoke('start');
}

void stop() {
  FlutterBackgroundService().invoke('stop');
}
