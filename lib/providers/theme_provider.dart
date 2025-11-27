import 'package:flutter/material.dart';

enum AppTheme { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.system;

  AppTheme get currentTheme => _currentTheme;

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
