import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {  
  static Future<void> saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> saveInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> saveDouble(String key, double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> removeData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
