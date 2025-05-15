import 'package:flutter/material.dart';

// Theme state class
class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}