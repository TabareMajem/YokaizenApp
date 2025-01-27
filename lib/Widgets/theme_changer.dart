import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  static const String _themeModeKey = 'theme_mode';

  ThemeProvider() {
    _loadThemeMode();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void _loadThemeMode() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int themeModeValue = prefs.getInt(_themeModeKey) ?? 0;
    // themeMode = ThemeMode.values[themeModeValue];
    notifyListeners();
  }

  void _saveThemeMode(ThemeMode mode) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setInt(_themeModeKey, mode.index);
  }

  void toggleThemeMode(bool isOn) {
    themeMode = isOn ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode(themeMode);
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: const Color(0xff191919),
      primaryColor: const Color(0xff191919),
      colorScheme: const ColorScheme.dark());

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: const Color(0xffF3F3F3),
      primaryColor: const Color(0xff191919),
      colorScheme: const ColorScheme.light());
}
