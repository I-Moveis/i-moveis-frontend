import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that holds and toggles the current [ThemeMode].
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  // Notifier state is the getter; a paired getter would shadow it.
  // ignore: use_setters_to_change_properties
  void setMode(ThemeMode mode) => state = mode;
}

/// Provider for the app's theme mode.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
