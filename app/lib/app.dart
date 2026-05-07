import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router/app_router.dart';
import 'core/theme/seed_color_provider.dart';
import 'core/theme/theme_provider.dart';
import 'design_system/design_system.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/auth/presentation/providers/auth_state.dart';

/// Root widget of the application.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider).when(
          data: (v) => v,
          loading: () => ThemeMode.dark,
          error: (_, __) => ThemeMode.dark,
        );
    final seedColor = ref.watch(seedColorProvider);
    final palette = ref.watch(brutalistPaletteProvider);

    BrutalistPalette.update(palette);

    ref
      ..listen(brutalistPaletteProvider, (previous, next) {
        BrutalistPalette.update(next);
      })
      ..listen<AuthState>(authNotifierProvider, (previous, next) {
        // Redireciona pra /login quando o usuário desloga. O notifier já
        // atualiza o authStatusProvider internamente, aqui só tratamos o
        // side-effect de navegação.
        next.maybeWhen(
          unauthenticated: () => goRouter.go('/login'),
          orElse: () {},
        );
      });

    return MaterialApp.router(
      title: 'i-Móveis',
      theme: AppTheme.light.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
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
