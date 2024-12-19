import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';
part 'theme_state.dart';

enum AppTheme { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, AppTheme> {
  ThemeBloc() : super(AppTheme.system) {
    on<InitialThemeEvent>((event, emit) async {
      final String savedTheme = await getSavedTheme();
      emit(AppTheme.values.firstWhere((e) => e.toString() == savedTheme,
          orElse: () => AppTheme.system));
    });

    on<SwitchThemeEvent>((event, emit) {
      final newTheme = event.theme;
      emit(newTheme);
      saveTheme(newTheme);
    });
  }

  Future<String> getSavedTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("selected_theme") ?? AppTheme.system.toString();
  }

  Future<void> saveTheme(AppTheme theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("selected_theme", theme.toString());
  }
}
