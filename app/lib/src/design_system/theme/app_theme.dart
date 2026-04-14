import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_radius.dart';

/// Complete ThemeData for Dark and Light modes.
///
/// Synthesizes design inspirations:
/// - Magic Receipt: dark backgrounds, neon accent energy
/// - McShannock: clean minimalism, tight tracking headings
/// - SSScript: focused UI, generous spacing
/// - Airbnb: warm rounded shapes, friendly interactions
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryDark,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkCard,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorderSubtle,
          scrim: AppColors.scrim,
        ),

        // ─── Typography ──────────────────────────────────────────
        textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),

        // ─── AppBar ──────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // ─── Bottom Navigation ───────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkTextTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        ),

        // ─── Navigation Bar (Material 3) ────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall.copyWith(
              color: AppColors.darkTextTertiary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.darkTextTertiary, size: 24);
          }),
          elevation: 0,
          height: 64,
        ),

        // ─── Cards ───────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
            side: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Elevated Button ─────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ─── Outlined Button ─────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ─── Text Button ────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ─── Input Decoration ────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextTertiary),
          labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
          prefixIconColor: AppColors.darkTextTertiary,
          suffixIconColor: AppColors.darkTextTertiary,
        ),

        // ─── Chip ────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          disabledColor: AppColors.darkCard,
          labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkTextPrimary),
          secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderFull,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),

        // ─── Bottom Sheet ────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          dragHandleColor: AppColors.darkTextDisabled,
          dragHandleSize: Size(40, 4),
          showDragHandle: true,
        ),

        // ─── Dialog ──────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),

        // ─── Floating Action Button ──────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
          ),
        ),

        // ─── Snackbar ────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkElevated,
          contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),

        // ─── Divider ────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorderSubtle,
          thickness: 1,
          space: 1,
        ),

        // ─── Switch / Checkbox / Radio ──────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
            return AppColors.darkTextTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.darkCard;
          }),
        ),

        // ─── ListTile ───────────────────────────────────────────
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          titleTextStyle: AppTypography.titleSmall.copyWith(color: AppColors.darkTextPrimary),
          subtitleTextStyle: AppTypography.bodySmall.copyWith(color: AppColors.darkTextSecondary),
          iconColor: AppColors.darkTextSecondary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        ),

        // ─── Tab Bar ────────────────────────────────────────────
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.darkTextTertiary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelLarge,
          dividerColor: Colors.transparent,
        ),
      );

  // ═══════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryDark,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryLight,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightCard,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightBorderSubtle,
        ),

        textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.lightTextTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          indicatorColor: AppColors.primaryDark.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall.copyWith(
              color: AppColors.lightTextTertiary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryDark, size: 24);
            }
            return const IconThemeData(color: AppColors.lightTextTertiary, size: 24);
          }),
          elevation: 0,
          height: 64,
        ),

        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
            side: const BorderSide(color: AppColors.lightBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.lightTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderFull,
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextTertiary),
          labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
          prefixIconColor: AppColors.lightTextTertiary,
          suffixIconColor: AppColors.lightTextTertiary,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightBackground,
          selectedColor: AppColors.primaryDark.withValues(alpha: 0.12),
          labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.lightTextPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderFull,
            side: const BorderSide(color: AppColors.lightBorder),
          ),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          dragHandleColor: AppColors.lightTextDisabled,
          dragHandleSize: Size(40, 4),
          showDragHandle: true,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightTextPrimary,
          contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorderSubtle,
          thickness: 1,
          space: 1,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.lightTextTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
            return AppColors.lightBorderSubtle;
          }),
        ),

        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          titleTextStyle: AppTypography.titleSmall.copyWith(color: AppColors.lightTextPrimary),
          subtitleTextStyle: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
          iconColor: AppColors.lightTextSecondary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        ),

        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.lightTextTertiary,
          indicatorColor: AppColors.primaryDark,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelLarge,
          dividerColor: Colors.transparent,
        ),
      );

  // ─── Helper: Build TextTheme ───────────────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: primary),
        displayMedium: AppTypography.displayMedium.copyWith(color: primary),
        displaySmall: AppTypography.displaySmall.copyWith(color: primary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: primary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: primary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: primary),
        titleLarge: AppTypography.titleLarge.copyWith(color: primary),
        titleMedium: AppTypography.titleMedium.copyWith(color: primary),
        titleSmall: AppTypography.titleSmall.copyWith(color: primary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: primary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: secondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: secondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: primary),
        labelMedium: AppTypography.labelMedium.copyWith(color: secondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: secondary),
      );
}
