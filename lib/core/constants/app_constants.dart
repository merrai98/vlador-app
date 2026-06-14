import 'package:flutter/widgets.dart';

abstract class AppConstants {
  static final navigatorKey = GlobalKey<NavigatorState>();

  ///Path
  static const String translationsFolderPath = 'assets/translations';
  static const String mainFont = "Poppins-Regular";
  static const String nativeNotificationIcon = "@mipmap/ic_notification";
  static const String channelName = "channel name";
  static const String channelDescription = "channel description";
  static const String body = "Body";
  static const String en = "en";
  static const String ar = "ar";
}
