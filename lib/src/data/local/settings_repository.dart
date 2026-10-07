import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Persists lightweight user preferences (currently the theme mode).
class SettingsRepository {
  SettingsRepository(this._box);

  static const String boxName = 'settings';
  static const String _themeKey = 'themeMode';

  final Box<String> _box;

  ThemeMode loadThemeMode() {
    return switch (_box.get(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _box.put(_themeKey, mode.name);
}
