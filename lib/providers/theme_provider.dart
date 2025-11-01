import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDarkMode => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // Optional: expose setter if needed in future
  void setDarkMode(bool v) {
    _isDark = v;
    notifyListeners();
  }
}