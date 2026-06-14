import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/user_model.dart';
import '../constants/preferences_keys.dart';

class SharedPreferencesService {
  final SharedPreferences prefs;

  SharedPreferencesService({required this.prefs});

  Future<void> saveData<T>(String key, T value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  Future<void> saveUser(UserModel user) async {
    await prefs.setString(PreferencesKeys.user, user.toRawJson());
  }

  UserModel? getUser() {
    String? userRaw = prefs.getString(PreferencesKeys.user);
    if (userRaw != null) {
      return UserModel.fromRawJson(userRaw);
    }
    return null;
  }

  Future<void> removeData(String key) async {
    await prefs.remove(key);
  }

  Future<void> logout() async {
    await prefs.remove(PreferencesKeys.accountId);
    await prefs.remove(PreferencesKeys.token);
    await prefs.remove(PreferencesKeys.user);
  }

  T? getData<T>(String key) {
    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    }
    return null;
  }
}
