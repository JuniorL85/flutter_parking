part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

class InitialThemeEvent extends ThemeEvent {}

class SwitchThemeEvent extends ThemeEvent {
  final AppTheme theme;

  SwitchThemeEvent({required this.theme});
}
