import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'theme_notifier.dart';

/// Provider for the current ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.themeMode;
});

/// Provider for checking if dark mode is currently active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  if (themeMode == ThemeMode.system) {
    return platformBrightness == Brightness.dark;
  }

  return themeMode == ThemeMode.dark;
});

/// Provider for getting the current ThemeData
final currentThemeProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
});