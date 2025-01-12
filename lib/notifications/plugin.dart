import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:check_mk_api/check_mk_api.dart' as cmk_api;
import 'package:letscheck/global_router.dart';

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

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

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
    }
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

Future<void> sendServiceNotification({
  required String conn,
  required cmk_api.LqlTableServicesDto svcOld,
  required cmk_api.LqlTableServicesDto svcNew,
}) async {
  if (svcOld.state == svcNew.state) {
    return;
  }

  var title = '';
  var body = '';
  if (svcNew.state == cmk_api.svcStateUp &&
      svcOld.state != cmk_api.svcStateUp) {
    title = 'Up: Service ${svcNew.hostName} : ${svcNew.displayName}';
    body = 'Service ${svcNew.displayName} from host ${svcNew.hostName} is up.';
  } else if (svcNew.state != cmk_api.svcStateUp &&
      svcOld.state == cmk_api.svcStateUp) {
    title = 'Down: Service ${svcNew.hostName} : ${svcNew.displayName}';
    body =
        'Service ${svcNew.displayName} from host ${svcNew.hostName} is down.';
  } else {
    title =
        'Change: Service ${svcNew.hostName} : ${svcNew.displayName} (${svcOld.state} -> ${svcNew.state})';
    body =
        'Service ${svcNew.displayName} from host ${svcNew.hostName} changed.';
  }

  const androidNotificationDetails = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      icon: 'app_icon',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
      notificationId++, title, body, notificationDetails,
      payload: GlobalRouter().buildUri(routeService, buildArgs: {
        'alias': conn,
        'hostname': svcNew.hostName,
        'service': svcNew.displayName!
      }));
}

Future<void> sendHostNotification({
  required String conn,
  required cmk_api.LqlTableHostsDto hostOld,
  required cmk_api.LqlTableHostsDto hostNew,
}) async {
  if (hostOld.state == hostNew.state) {
    return;
  }

  var title = '';
  var body = '';
  if (hostNew.state == cmk_api.svcStateUp &&
      hostOld.state != cmk_api.svcStateUp) {
    title = 'Up: Host ${hostNew.displayName}';
    body = 'Host ${hostNew.displayName} is up.';
  } else if (hostNew.state != cmk_api.svcStateUp &&
      hostOld.state == cmk_api.svcStateUp) {
    title = 'Down: Host ${hostNew.displayName}';
    body = 'Host ${hostNew.displayName} is down.';
  } else {
    title =
        'Change: Host ${hostNew.displayName} (${hostOld.state} -> ${hostNew.state})';
    body = 'Host ${hostNew.displayName} changed.';
  }

  const androidNotificationDetails = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      icon: 'app_icon',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
      notificationId++, title, body, notificationDetails,
      payload: GlobalRouter().buildUri(routeHost,
          buildArgs: {'alias': conn, 'hostname': hostNew.displayName!}));
}
