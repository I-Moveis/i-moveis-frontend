import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/seed_color_provider.dart';
import 'design_system/design_system.dart';
import 'design_system/theme/app_theme.dart';

/// Root widget of the application.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final seedColor = ref.watch(seedColorProvider);
    final palette = ref.watch(brutalistPaletteProvider);

    // Sync static bridge with dynamic provider
    BrutalistPalette.update(palette);

    ref.listen(brutalistPaletteProvider, (previous, next) {
      BrutalistPalette.update(next);
    });

    return MaterialApp.router(
      title: 'i-Móveis',
      theme: AppTheme.light.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: AppTheme.dark.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
