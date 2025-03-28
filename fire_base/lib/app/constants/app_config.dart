const String APP_NAME = 'LinguaNova';
const String HTTPS_URL="https://10.0.62.204:5041";

/*
* import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/dark_mode_colors.dart';

class ColorThemeState with ChangeNotifier {
  final ThemeData _lightMode = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(primary: Colors.black),
  );

  final ThemeData _darkMode = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: DarkModeColors.BACKGROUND_COLOR,
    primaryColor: DarkModeColors.INFO_CONTAINERS_COLOR,
    colorScheme: const ColorScheme.dark(primary: Colors.white),
  );

  // final ThemeData _selectedThemeData = ThemeData(
  //   brightness: Brightness.dark,
  //   useMaterial3: false,
  //   scaffoldBackgroundColor: DarkModeColors.BACKGROUND_COLOR,
  //   primaryColor: DarkModeColors.INFO_CONTAINERS_COLOR,
  //   colorScheme: const ColorScheme.dark(primary: Colors.white),
  // );

  bool _isDark = true;

  bool get isDark => _isDark;

  Future<void> switchTheme(bool selected) async {
    _isDark = selected;
    await saveThemeToSharedPref(selected);
    notifyListeners();
  }

  ThemeData get selectedThemeData => isDark ? _darkMode : _lightMode;

  Future<void> saveThemeToSharedPref(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("themeData", value);
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool("themeData")!;
  }
}
*/