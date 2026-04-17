import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    return saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggle() async {
    final current = state.when(
      data: (v) => v,
      loading: () => ThemeMode.dark,
      error: (_, __) => ThemeMode.dark,
    );
    await _persist(
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  // Notifier state is the getter; a paired getter would shadow AsyncValue.
  // ignore: use_setters_to_change_properties
  Future<void> setMode(ThemeMode mode) async => _persist(mode);

  Future<void> _persist(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kThemeKey, mode == ThemeMode.light ? 'light' : 'dark');
  }
}

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
