import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/home/presentation/pages/main_screen.dart';
import '../../features/home/presentation/pages/sync_screen.dart';
import '../../injection_container.dart';
import '../constants/preferences_keys.dart';
import '../helpers/user_local.dart';
import 'shared_preferences_manger.dart';

Future<bool?>? checkInternetConnection() async {
  try {
    final response = await InternetAddress.lookup('www.google.com');
    if (response.isNotEmpty) {
      return true;
    }
  } on SocketException catch (err) {
    log(err.toString());
    return false;
  }
  return false;
}

Future<void> removeUser() async {
  await sl<SharedPreferencesService>().removeData(PreferencesKeys.user);
  UserLocal.user = null;
}

Future<Widget> navigatorOptions() async {

  final user = sl<SharedPreferencesService>().getUser();
  if (user != null) {
    UserLocal.user = user;
    final lastSync = sl<SharedPreferencesService>().getData<String>(PreferencesKeys.lastSync);

    if (lastSync == null) {
      return const SyncScreen();
    }
    return const MainScreen();
  }
  return const LoginScreen();
}

double toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

Color hexToColor(String? hexString) {
  if (hexString == null || hexString.isEmpty) {
    return Colors.transparent;
  }
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e) {
    return Colors.transparent;
  }
}

DateTime parseDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return DateTime(0);
  
  // Try standard ISO 8601 / yyyy-MM-dd HH:mm:ss
  final parsed = DateTime.tryParse(dateStr);
  if (parsed != null) return parsed;

  // Try common format: DD/MM/YYYY or MM/DD/YYYY
  try {
    final parts = dateStr.split(' ');
    final dateParts = parts[0].split(RegExp(r'[-/]'));
    if (dateParts.length == 3) {
      int year, month, day;
      if (dateParts[0].length == 4) { // yyyy-mm-dd
        year = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        day = int.parse(dateParts[2]);
      } else if (dateParts[2].length == 4) { // dd-mm-yyyy or mm-dd-yyyy
        year = int.parse(dateParts[2]);
        // Defaulting to MM/DD/YYYY based on typical US format seen in placeholders
        // but checking if month > 12 to swap
        int first = int.parse(dateParts[0]);
        int second = int.parse(dateParts[1]);
        if (first > 12) {
          day = first;
          month = second;
        } else {
          month = first;
          day = second;
        }
      } else {
        return DateTime(0);
      }
      
      int hour = 0, minute = 0, second = 0;
      if (parts.length > 1) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
          if (timeParts.length >= 3) {
            second = int.parse(timeParts[2]);
          }
        }
      }
      return DateTime(year, month, day, hour, minute, second);
    }
  } catch (_) {}

  return DateTime(0);
}
