import 'package:flutter/material.dart';

class ChangeThemeProvider extends ChangeNotifier {
  ThemeMode? currentThemeMode;

  changeThemeMode(int index) {
    if (index == 0) {
      currentThemeMode = ThemeMode.light;
    } else if (index == 1) {
      currentThemeMode = ThemeMode.dark;
    } else {
      currentThemeMode = ThemeMode.system;
    }
    notifyListeners();
  }
}
