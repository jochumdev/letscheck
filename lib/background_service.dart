import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show BackgroundIsolateBinaryMessenger;

// ignore: depend_on_referenced_packages
import 'package:flutter_background_service_platform_interface/flutter_background_service_platform_interface.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:letscheck/providers/settings/settings_state.dart';
import 'package:mutex/mutex.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import 'package:letscheck/services/connectivity_service.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications/android.dart' as notifications_android;
import 'notifications/darwin.dart' as notifications_darwin;
import 'notifications/linux.dart' as notifications_linux;
import 'notifications/windows.dart' as notifications_windows;
import 'notifications/plugin.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MethodCall {
  final String method;
  final Map<String, dynamic>? args;

  MethodCall(this.method, this.args);
}

class WorkerService extends ServiceInstance {
  final SendPort _sendPort;
  late final ReceivePort _receivePort;

  final StreamController<MethodCall?> _controller =
      StreamController.broadcast(sync: true);

  WorkerService._(this._sendPort) {
    _receivePort = ReceivePort();
    _sendPort.send(_receivePort.sendPort);

    _receivePort.listen((message) {
      if (message is MethodCall) {
        _controller.add(message);
      }
    });
  }

  @override
  void invoke(String method, [Map<String, dynamic>? args]) {
    _sendPort.send(MethodCall(method, args));
  }

  @override
  Stream<Map<String, dynamic>?> on(String method) {
    return _controller.stream
        .where((event) => event?.method == method)
        .asyncMap((event) => event?.args ?? {});
  }

  @override
  Future<void> stopSelf() async {
    _receivePort.close();
  }
}

class IsolateBackgroundService implements Observable {
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  bool _closed = false;

  final StreamController<MethodCall?> _controller =
      StreamController.broadcast(sync: true);

  static IsolateBackgroundService instance = IsolateBackgroundService._();

  IsolateBackgroundService._();

  @override
  void invoke(String method, [Map<String, dynamic>? args]) async {
    if (_closed) throw StateError('Closed');

    _sendPort!.send(MethodCall(method, args));
  }

  @override
  Stream<Map<String, dynamic>?> on(String method) {
    return _controller.stream
        .where((event) => event?.method == method)
        .asyncMap((event) => event?.args ?? {});
  }

  Future<void> spawn(Future<void> Function(ServiceInstance) onStart) async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn<
              (
                SendPort,
                RootIsolateToken,
                Future<void> Function(ServiceInstance)
              )>(
          entrypoint, (initPort.sendPort, RootIsolateToken.instance!, onStart));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    _receivePort = receivePort;
    _sendPort = sendPort;

    _receivePort!.listen((message) {
      if (message is! MethodCall) return;

      _controller.add(message);
    });
  }

  @pragma('vm:entry-point')
  static void entrypoint(
      (
        SendPort,
        RootIsolateToken,
        Future<void> Function(ServiceInstance)
      ) args) async {
    final ws = WorkerService._(args.$1);
    BackgroundIsolateBinaryMessenger.ensureInitialized(args.$2);

    await args.$3(ws);
  }

  void stop() {
    if (_closed) return;

    invoke('shutdown');
    _receivePort!.close();

    _closed = true;
  }
}

class Notifier {
  final Mutex mutex = Mutex();

  ServiceInstance? _service;
  Timer? timer;
  var refreshSeconds = 60;
  var clients = <String, cmk_api.Client>{};
  var cSettings = <String, SettingsStateConnection>{};
  var cLastFetch = <String, DateTime>{};

  var knownNotifications = <String, Map<String, DateTime>>{};

  static Notifier instance = Notifier._internal();

  Notifier._internal();

  void setServiceAndListen(ServiceInstance service) {
    _service = service;

    service.on('notifier:start').listen((_) async {
      await _start();
    });

    service.on('notifier:stop').listen((_) async {
      await _stop();
    });

    service.on('notifier:settings').listen((settings) async {
      await _settings(settings);
    });
  }

  void _log(String message) {
    _service?.invoke('log', <String, dynamic>{'message': message});
  }

  Future<void> sendLogNotification({
    required String conn,
    required cmk_api.Log log,
  }) async {
    var title = '${log.hostName} : ${log.displayName}';
    var body = log.pluginOutput;

    switch (log.state) {
      case cmk_api.svcStateOk:
        title = 'OK: $title';
        break;
      case cmk_api.svcStateWarn:
        title = 'WARN: $title';
        break;
      case cmk_api.svcStateCritical:
        title = 'CRIT: $title';
        break;
      default:
        title = 'UNKN: $title';
    }

    const androidNotificationDetails = AndroidNotificationDetails(
        notifications_android.notificationChannelId, 'LetsCheck',
        channelDescription: 'Notifications for letscheck',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker');

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const DarwinNotificationDetails macOSNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    WindowsNotificationDetails windowsNotificationDetails =
        WindowsNotificationDetails(
          images: [], // WindowsImage(WindowsImage.getAssetUri('assets/icons/letscheck.png'), altText: 'LetsCheck')
    );

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      macOS: macOSNotificationDetails,
      iOS: iosNotificationDetails,
      windows: windowsNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId++,
      title,
      body,
      notificationDetails,
      payload: '/$conn/host/${log.hostName}/services/${log.displayName}',
    );
  }

  Future<void> sendNotificationsForConnection(
      {required String alias,
      required cmk_api.Client client,
      required DateTime lastFetch}) async {
    try {
      if (!knownNotifications.containsKey(alias)) {
        knownNotifications[alias] = {};
      }
      var aliasKnown = knownNotifications[alias]!;

      final secs = ((DateTime.now().toUtc().millisecondsSinceEpoch -
                  lastFetch.millisecondsSinceEpoch) /
              1000)
          .round();
      final events = await client.getViewEvents(fromSecs: secs);

      _log(
          "Found ${events.length} notifications for $alias within $secs seconds");

      for (var event in events) {
        final key = '${event.hostName}-${event.displayName}';
        if (!aliasKnown.containsKey(key)) {
          sendLogNotification(conn: alias, log: event);
          aliasKnown[key] = event.time.toUtc();
        }
      }

      var toRemove = [];
      for (final key in aliasKnown.keys) {
        if (aliasKnown[key]!.isAfter(lastFetch)) {
          toRemove.add(key);
        }
      }
      aliasKnown.removeWhere((key, item) => toRemove.contains(key));
    } on Object {
      // Ignore.
    }
  }

  Future<void> _fetchAndRunNotifications() async {
    await mutex.protect(() async {
      for (final alias in clients.keys) {
        if (cSettings.containsKey(alias) &&
            cSettings[alias]!.sendNotifications) {
          if (clients.containsKey(alias)) {
            if (cSettings[alias]!.wifiOnly &&
                await ConnectivityService.isMobile()) {
              continue;
            }

            final client = clients[alias]!;

            await sendNotificationsForConnection(
                alias: alias, client: client, lastFetch: cLastFetch[alias]!);

            cLastFetch[alias] = DateTime.now().toUtc();
          }
        }
      }
    });
  }

  Future<void> _start() async {
    // Cancel old timer.
    timer?.cancel();

    _log("Notifier: creating a timer with $refreshSeconds seconds");

    // Create new timer.
    timer = Timer.periodic(
      Duration(seconds: refreshSeconds),
      (_) async => await _fetchAndRunNotifications(),
    );
  }

  Future<void> _stop() async {
    // Cancel the timer.
    timer?.cancel();

    _log("Notifier stopped");
  }

  Future<void> _settings(Map<String, dynamic>? settings) async {
    if (settings == null) return;

    // await mutex.protect(() async {
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
      await _fetchAndRunNotifications();

      _log("Creating a timer with $refreshSeconds seconds");

      // Create new timer.
      timer = Timer.periodic(
        Duration(seconds: refreshSeconds),
        (timer) async => await _fetchAndRunNotifications(),
      );
    }
    // });

    _log("Notifier got settings");
  }
}

Future<void> initialize(Talker talker) async {
  Observable service;

  if (kIsWeb) return;

  if (Platform.isAndroid || Platform.isIOS) {
    final fservice = FlutterBackgroundService();
    await fservice.configure(
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
        notificationChannelId: notifications_android.notificationChannelId,
        initialNotificationContent: "Fetching notifications",
        foregroundServiceNotificationId: 1234,
      ),
    );

    fservice.startService();

    service = fservice;
  } else {
    await IsolateBackgroundService.instance.spawn(onStart);
    service = IsolateBackgroundService.instance;
  }

  service.on('log').listen((event) {
    if (event == null) return;

    talker.info(event['message']);
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  if (!kIsWeb) {
    final initializationSettings = InitializationSettings(
      android: notifications_android.initializationSettings,
      iOS: notifications_darwin.initializationSettings,
      macOS: notifications_darwin.initializationSettings,
      linux: notifications_linux.initializationSettings,
      windows: notifications_windows.initializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Notifier.instance.setServiceAndListen(service);
}

void sendSettings(SettingsState state) async {
  if (kIsWeb) return;

  Map<String, dynamic> settings = {};
  settings['refresh_seconds'] = state.refreshSeconds;
  settings['connections'] =
      List<Map<String, dynamic>>.from(state.connections.map((c) => c.toJson()));

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterBackgroundService().invoke('notifier:settings', settings);
  } else {
    IsolateBackgroundService.instance.invoke('notifier:settings', settings);
  }
}

void start() {
  if (kIsWeb) return;

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterBackgroundService().invoke('notifier:start', {});
  } else {
    IsolateBackgroundService.instance.invoke('notifier:start', {});
  }
}

void stop() {
  if (kIsWeb) return;

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterBackgroundService().invoke('notifier:stop', {});
  } else {
    IsolateBackgroundService.instance.invoke('notifier:stop', {});
  }
}
