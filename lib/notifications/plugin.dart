import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:checkmk_api/checkmk_api.dart' as cmk_api;
import 'package:mutex/mutex.dart';
import 'android.dart' as android;

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.data,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final Map<String, dynamic>? data;
}

String? selectedNotificationPayload;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

int notificationId = 0;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

Future<bool> grantNotificationPermission() async {
  var notificationsEnabled = true;

  if (Platform.isAndroid) {
    notificationsEnabled = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    if (!notificationsEnabled) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      notificationsEnabled = grantedNotificationPermission ?? false;

      if (notificationsEnabled) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(android.channel);
      }
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      android.notificationChannelId,
      'LetsCheck high', // title
      description: 'Checkmk notifications over LetsCheck.', // description
      importance: Importance.high, // importance must be at low or higher level
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  return notificationsEnabled;
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
      android.notificationChannelId, 'LetsCheck',
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

  const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    macOS: macOSNotificationDetails,
    iOS: iosNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    notificationId++,
    title,
    body,
    notificationDetails,
    payload: '/$conn/host/${log.hostName}/services/${log.displayName}',
  );
}

var _notificationsLock = Mutex();
var knownNotifications = <String, Map<String, DateTime>>{};

Future<void> sendNotificationsForConnection(
    {required String conn,
    required cmk_api.Client client,
    required int refreshSeconds}) async {
  try {
    await _notificationsLock.acquire();

    if (!knownNotifications.containsKey(conn)) {
      knownNotifications[conn] = {};
    }
    var aliasKnown = knownNotifications[conn]!;

    final events = await client.getViewEvents(fromSecs: refreshSeconds);
    print(
        "Found ${events.length} notifications for $conn within $refreshSeconds seconds");

    for (var event in events) {
      final key =
          '${event.hostName}-${event.displayName}-${event.time.millisecondsSinceEpoch}';
      if (!aliasKnown.containsKey(key)) {
        sendLogNotification(conn: conn, log: event);
        aliasKnown[key] = event.time;
      }
    }

    var toOld = DateTime.now().toUtc().subtract(
          Duration(seconds: refreshSeconds),
        );
    var toRemove = [];
    for (var key in aliasKnown.keys) {
      if (aliasKnown[key]!.isBefore(toOld)) {
        toRemove.add(key);
      }
    }
    aliasKnown.removeWhere((key, item) => toRemove.contains(key));
  } on cmk_api.BaseException {
    // Ignore.
  } finally {
    _notificationsLock.release();
  }
}
