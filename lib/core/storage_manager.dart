import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static SharedPreferences? _instance;

  static Future<SharedPreferences> initShareReference() async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static void saveData(String key, dynamic value) {
    if (value is int) {
      _instance?.setInt(key, value);
    } else if (value is String) {
      _instance?.setString(key, value);
    } else if (value is bool) {
      _instance?.setBool(key, value);
    } else {
      debugPrint('Invalid Type');
    }
  }

  static dynamic readData(String key) {
    dynamic obj = _instance?.get(key);
    return obj;
  }

  static Future<bool> deleteData(String key) async {
    return await _instance?.remove(key) ?? false;
  }

  static void saveJsonData(String key, dynamic value) {
    var valueJson = jsonEncode(value);
    _instance?.setString(key, valueJson);
  }

  static dynamic readJsonData(String key) {
    dynamic obj = _instance?.get(key);
    return obj != null ? jsonDecode(obj) : null;
  }
}
