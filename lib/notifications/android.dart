import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannelId = "dev.jochum.letscheck.high";

const AndroidInitializationSettings initializationSettings =
    AndroidInitializationSettings('notification_icon');

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  notificationChannelId, // id
  'LetsCheck', // title
  description: 'Notifications for letscheck.', // description
  importance: Importance.high, // importance must be at low or higher level
);
