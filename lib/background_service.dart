import 'dart:async';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:letscheck/providers/settings/settings_state.dart';
import 'package:mutex/mutex.dart';
import 'package:dio/dio.dart';

import 'package:letscheck/services/connectivity_service.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:letscheck/notifications/plugin.dart';
import 'package:letscheck/notifications/android.dart' as android;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MethodCall {
  final String method;
  final Map<String, dynamic>? args;

  MethodCall(this.method, this.args);
}

class SameThreadService implements ServiceInstance {
  static SameThreadService instance = SameThreadService._internal();
  final StreamController<MethodCall?> _controller =
      StreamController.broadcast(sync: true);

  SameThreadService._internal();

  Future<void> configure(
      {required dynamic Function(ServiceInstance service) onStart}) async {
    await onStart(instance);
  }

  @override
  void invoke(String method, [Map<String, dynamic>? args]) {
    _controller.add(MethodCall(method, args));
  }

  @override
  Stream<Map<String, dynamic>?> on(String method) {
    return _controller.stream
        .where((event) => event?.method == method)
        .asyncMap((event) => event?.args);
  }

  @override
  Future<void> stopSelf() async {}
}

Future<void> initialize() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
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

    service.startService();
  } else {
    final service = SameThreadService.instance;
    await service.configure(onStart: onStart);
  }
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
var cSettings = <String, SettingsStateConnection>{};
var cLastFetch = <String, DateTime>{};

Future<void> _fetchAndRunNotificiations() async {
  try {
    mutex!.acquire();

    for (final alias in clients.keys) {
      if (cSettings.containsKey(alias) && cSettings[alias]!.sendNotifications) {
        if (clients.containsKey(alias)) {
          if (cSettings[alias]!.wifiOnly &&
              await ConnectivityService.isMobile()) {
            continue;
          }

          final client = clients[alias]!;

          await sendNotificationsForConnection(
            alias: alias,
            client: client,
            lastFetch: cLastFetch[alias]!,
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
        (_) async => await _fetchAndRunNotificiations(),
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
        // Clear old values.
        clients = {};
        cSettings = {};

        for (final jsonConnectionSettings in settings['connections']) {
          final s = SettingsStateConnection.fromJson(jsonConnectionSettings);

          if (s.sendNotifications && !s.paused) {
            var client = cmk_api.Client(
              () => Dio(),
              cmk_api.ClientSettings(
                baseUrl: s.baseUrl,
                site: s.site,
                username: s.username,
                secret: s.password,
                insecure: !s.insecure,
              ),
              requireConnect: false,
            );

            clients[s.alias] = client;
            cSettings[s.alias] = s;
            cLastFetch[s.alias] =
                DateTime.now().subtract(Duration(seconds: refreshSeconds));
          }
        }
      }

      if (recreate) {
        // Cancel old timer.
        timer?.cancel();

        // Fetch now, the timer fetches then again later.
        await _fetchAndRunNotificiations();

        // Create new timer.
        timer = Timer.periodic(
          Duration(seconds: refreshSeconds),
          (_) async => await _fetchAndRunNotificiations(),
        );
      }
    } finally {
      mutex!.release();
    }
  });
}

void sendSettings(SettingsState state) async {
  Map<String, dynamic> settings = {};
  settings['refresh_seconds'] = state.refreshSeconds;
  settings['connections'] =
      List<Map<String, dynamic>>.from(state.connections.map((c) => c.toJson()));

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterBackgroundService().invoke('settings', settings);
  } else {
    SameThreadService.instance.invoke('settings', settings);
  }
}

void start() {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterBackgroundService().invoke('start');
  } else {
    SameThreadService.instance.invoke('start');
  }
}

void stop() {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterBackgroundService().invoke('stop');
  } else {
    SameThreadService.instance.invoke('stop');
  }
}
