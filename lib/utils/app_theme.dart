import 'package:flutter/material.dart';

class AppTheme {
  // Minimal neutral palette with a soft accent
  static const Color _accent = Color(0xFF2B6CB0); // soft indigo
  static const Color _bg = Color(0xFFF7F7F9);
  static const Color _surface = Colors.white;
  static const Color _muted = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _accent, brightness: Brightness.light),
      scaffoldBackgroundColor: _bg,
      primaryColor: _accent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _surface,
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.black54),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFE6EEF8),
        disabledColor: Color(0xFFE6EEF8),
        selectedColor: _accent,
        secondarySelectedColor: _accent,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: TextStyle(color: Colors.black87),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.light,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: const TextStyle(fontSize: 15, color: Colors.black87),
        bodyMedium: const TextStyle(fontSize: 14, color: _muted),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _accent, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      primaryColor: _accent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF071027),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.white70),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF071027),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF071027),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
