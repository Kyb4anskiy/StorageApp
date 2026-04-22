import 'package:flutter/material.dart';

class MainTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF42D67B),
      brightness: Brightness.light,
      primary: const Color(0xFF42D67B),
      secondary: const Color(0xFF2EBE63),
    ),

    scaffoldBackgroundColor: const Color(0xFFF6FBF7),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF42D67B),
      foregroundColor: Color(0xFF000000),
      elevation: 0,
      centerTitle: false,
    ),

    cardColor: Colors.white,
    dividerColor: Color(0xFFD5E2D9),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
          color: Color(0xFF000000),
          fontSize: 18,
          fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
          color: Color(0xFF000000),
          fontSize: 16),
      bodyMedium: TextStyle(
          color: Color(0xFF000000),
          fontSize: 14),
      labelLarge: TextStyle(
          color: Color(0xFF42D67B),
          fontSize: 16),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB8C9BD)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42D67B),
        foregroundColor: const Color(0xFF000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE8F3EC),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      labelStyle: const TextStyle(color: Color(0xFF000000)),
    ),

  );
}
