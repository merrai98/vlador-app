import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'fcm_service.dart';

class LocalNotificationService {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(AppConstants.nativeNotificationIcon);

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    tz.initializeTimeZones();
    tz.initializeDatabase([]);
  }

  /// Creates and displays a local notification.
  static Future<void> createNotification(String title, int id, String message,
      {String? payload}) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        id.toString(),
        AppConstants.channelName,
        channelDescription: AppConstants.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.primary,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      message,
      notificationDetails,
      payload: payload,
    );
  }

  /// handle when app is minimized or in foreground
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      Map<String, dynamic> payloadMap = json.decode(payload);
      RemoteMessage? remoteMessage = RemoteMessage(
        data: {},
        notification: RemoteNotification(
          body: payloadMap[AppConstants.body],
        ),
      );
      handelOnMessageOpenedApp(remoteMessage);
    }
  }
}
