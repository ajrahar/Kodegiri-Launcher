import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Fungsi untuk menyimpan data String ke SharedPreferences
  static Future<void> saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.saveString('username', 'john_doe');

  // Fungsi untuk menyimpan data int ke SharedPreferences
  static Future<void> saveInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.saveInt('age', 30);

  // Fungsi untuk menyimpan data bool ke SharedPreferences
  static Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.saveBool('isMale', true);

  // Fungsi untuk menyimpan data double ke SharedPreferences
  static Future<void> saveDouble(String key, double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.saveDouble('weight', 75.5);

  // Fungsi untuk mengambil data String dari SharedPreferences
  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.getString('username');

  // Fungsi untuk mengambil data int dari SharedPreferences
  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.getInt('age');

  // Fungsi untuk mengambil data bool dari SharedPreferences
  static Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.getBool('isMale');

  // Fungsi untuk mengambil data double dari SharedPreferences
  static Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // Fungsi untuk menghapus data berdasarkan key dari SharedPreferences
  static Future<void> removeData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  // Contoh penggunaan : await SharedPreferencesHelper.removeData('username');


  // Fungsi untuk menghapus semua data dari SharedPreferences
  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // Contoh penggunaan : await SharedPreferencesHelper.clearData();
}
