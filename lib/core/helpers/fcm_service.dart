import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("onBackgroundMessage notification body: ${message.notification?.body}");
  log("onBackgroundMessage notification title: ${message.notification?.title}");
  log("onBackgroundMessage data: ${message.data}");
}

class FcmService {
  static late BuildContext context;

  static Future<void> fcmInitialize() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  static void fcmSetup() {
    FirebaseMessaging.onMessage.listen(
      (message) {
        if (Platform.isAndroid) {
          createLocalNotification(message);
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        handelOnMessageOpenedApp(message);
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

void handelOnBackground(RemoteMessage message) {}

void handelOnMessageOpenedApp(RemoteMessage message) {}

void handelOnNotificationCardPressed() {}

void createLocalNotification(RemoteMessage message) {
  LocalNotificationService.createNotification(
    message.notification?.title ?? "",
    int.parse("1"),
    message.notification?.body ?? "",
    payload: json.encode(
      {
        ...message.data,
        AppConstants.body: message.notification?.body ?? "",
      },
    ),
  );
}
