import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/settings_repository.dart';
import 'providers.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(this._repository) : super(_repository.loadThemeMode());

  final SettingsRepository _repository;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repository.saveThemeMode(mode);
  }

  Future<void> cycle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(ref.watch(settingsRepositoryProvider)),
);
