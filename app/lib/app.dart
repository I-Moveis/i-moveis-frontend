import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router/app_router.dart';
import 'core/theme/seed_color_provider.dart';
import 'core/theme/theme_provider.dart';
import 'design_system/design_system.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/category_bloc.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';

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

    // Sync static bridge with dynamic provider
    BrutalistPalette.update(palette);

    ref.listen(brutalistPaletteProvider, (previous, next) {
      BrutalistPalette.update(next);
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<CategoryBloc>(create: (_) => CategoryBloc()),
        BlocProvider<OnboardingCubit>(
          create: (_) => OnboardingCubit()..load(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            unauthenticated: () {
              goRouter.go('/login');
            },
          );
        },
        child: MaterialApp.router(
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
        ),
      ),
    );
  }
}
