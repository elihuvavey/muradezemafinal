import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  DarkModeProvider() {
    _loadDarkModePreference();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveDarkModePreference();
    notifyListeners();
  }

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Color get primaryColor => _isDarkMode ?  Colors.black : Colors.orange;

  Color get backgroundColor => _isDarkMode ? Colors.black : Colors.white;

  Color get textColor => _isDarkMode ? Colors.white : Colors.black;

  Color get iconColor => _isDarkMode ? Colors.white70 : Colors.black38;
}
