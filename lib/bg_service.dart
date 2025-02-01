import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/bloc/settings/settings.dart';
import 'package:letscheck/notifications/plugin.dart';

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
      isForegroundMode: false,
      autoStartOnBoot: true,
      notificationChannelId: "io.github.jochumdev.letscheck.high",
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  // https://github.com/ekasetiawans/flutter_background_service/issues/375#issuecomment-1874879210
  // DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // https://github.com/ekasetiawans/flutter_background_service/issues/375#issuecomment-1874879210
  // DartPluginRegistrant.ensureInitialized();

  var refreshSeconds = 300;
  Map<String, cmk_api.Client> clients = {};
  Map<String, bool> enabled = {};

  Timer? timer;

  service.on('settings').listen((settings) async {
    // Ignore invalid settings.
    if (settings == null) {
      return;
    }

    // Cancel old timer.
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }

    // read settings.
    if (settings.containsKey("refresh_seconds")) {
      refreshSeconds = settings["refresh_seconds"];
    }
    if (settings.containsKey('clients')) {
      for (var cSettings
          in (settings['clients'] as Map<String, dynamic>).values) {
        enabled[cSettings['site']] = cSettings['enabled'];

        var client = cmk_api.Client(
          cmk_api.ClientSettings(
            baseUrl: cSettings['base_url'],
            site: cSettings['site'],
            username: cSettings['username'],
            secret: cSettings['secret'],
            validateSsl: cSettings['validate_ssl'],
          ),
        );

        if (enabled[cSettings['site']]!) {
          try {
            await client.testConnection();
            clients[cSettings['site']] = client;
          } on cmk_api.CheckMkBaseError {
            // Ignore.
          }
        }
      }
    }

    // Once before timer.
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

    timer = Timer.periodic(Duration(seconds: refreshSeconds), (timer) async {
      // In timer.
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
    });
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
