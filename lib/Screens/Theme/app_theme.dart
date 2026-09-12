import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0F1524),
    primaryColor: Color(0xFF6366F1),
    cardColor: Color(0xFF1B2235),
    appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0F1524), foregroundColor: Colors.white),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.deepPurple,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  );
}
