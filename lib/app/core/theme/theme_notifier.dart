// lib/app/core/theme/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_theme.dart';
import 'theme_state.dart';

// StateNotifier for theme management using Hive
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeBoxName = 'theme_box';
  static const String _themeKey = 'theme_mode';
  late Box _themeBox;

  ThemeNotifier() : super(const ThemeState()) {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    // Open the box
    _themeBox = await Hive.openBox(_themeBoxName);

    // Load the theme
    final themeString = _themeBox.get(_themeKey, defaultValue: AppTheme.systemThemeKey) as String;
    final themeMode = _getThemeModeFromString(themeString);

    // Update state with the loaded theme
    state = state.copyWith(themeMode: themeMode);
  }

  // Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case AppTheme.lightThemeKey:
        return ThemeMode.light;
      case AppTheme.darkThemeKey:
        return ThemeMode.dark;
      case AppTheme.systemThemeKey:
      default:
        return ThemeMode.system;
    }
  }

  // Convert ThemeMode to string
  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppTheme.lightThemeKey;
      case ThemeMode.dark:
        return AppTheme.darkThemeKey;
      case ThemeMode.system:
      default:
        return AppTheme.systemThemeKey;
    }
  }

  // Save theme mode to Hive
  Future<void> _saveThemePrefs(ThemeMode mode) async {
    await _themeBox.put(_themeKey, _getThemeModeString(mode));
  }

  // Public methods to change theme
  Future<void> setLightMode() async {
    state = state.copyWith(themeMode: ThemeMode.light);
    await _saveThemePrefs(ThemeMode.light);
  }

  Future<void> setDarkMode() async {
    state = state.copyWith(themeMode: ThemeMode.dark);
    await _saveThemePrefs(ThemeMode.dark);
  }

  Future<void> setSystemMode() async {
    state = state.copyWith(themeMode: ThemeMode.system);
    await _saveThemePrefs(ThemeMode.system);
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }
}

// Create a provider for the theme notifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});