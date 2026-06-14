import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'enums.dart';

abstract class ToastService {
  static showToast({
    BuildContext? context,
    Duration? displayDuration,
    ToastType toastType = ToastType.failed,
    String? title,
    required String message,
  }) {
    Color backgroundColor;
    switch (toastType) {
      case ToastType.success:
        backgroundColor = Colors.green;
        break;
      case ToastType.failed:
        backgroundColor = Colors.red;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: displayDuration?.inSeconds ?? 5,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
