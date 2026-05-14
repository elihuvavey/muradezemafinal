import 'package:hive/hive.dart';

class HivePrefs {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('preferences');
  }

  static Future<void> saveInt(String key, int value) async {
    await _box.put(key, value);
  }

  static int? getInt(String key, {int? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveDouble(String key, double value) async {
    await _box.put(key, value);
  }

  static double? getDouble(String key, {double? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? getString(String key, {String? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    await _box.put(key, value);
  }

  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    final value = _box.get(key, defaultValue: defaultValue);
    if (value == null) return null;
    return List<String>.from(value);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _box.put(key, value);
  }

  static bool? getBool(String key, {bool? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> remove(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}