import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // default dark

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // updates all screens
  }

  void setTheme(String theme) {
    _themeMode = theme.toLowerCase() == "dark" ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
