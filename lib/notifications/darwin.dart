import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'plugin.dart';

final List<DarwinNotificationCategory> notificationCategories =
    <DarwinNotificationCategory>[

  DarwinNotificationCategory(
    darwinNotificationCategoryPlain,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain('id_1', 'Show'),

    ],
    options: <DarwinNotificationCategoryOption>{
      DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
    },
  )
];

final DarwinInitializationSettings initializationSettings =
    DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
  notificationCategories: notificationCategories,
);
