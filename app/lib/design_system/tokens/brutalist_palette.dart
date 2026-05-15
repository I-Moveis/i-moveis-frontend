import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';

/// Shared warm pastel palette used across all Brutalist Elegance pages.
/// Now dynamic based on a seed color.
@immutable
class DynamicBrutalistPalette {

  const DynamicBrutalistPalette(this.seed);
  final Color seed;

  Color get warmYellow => Color.lerp(seed, Colors.white, 0.3)!;
  Color get warmPeach => Color.lerp(seed, Colors.white, 0.15)!;
  Color get warmOrange => seed;
  Color get warmBrown => Color.lerp(seed, Colors.black, 0.2)!;
  Color get warmAmber => Color.lerp(seed, const Color(0xFFF5E6C8), 0.3)!;

  Color get deepOrange => Color.lerp(seed, Colors.black, 0.3)!;
  Color get deepBrown => Color.lerp(seed, Colors.black, 0.4)!;
  Color get deepAmber => Color.lerp(seed, Colors.black, 0.2)!;

  /// Accent peach: warm for dark, deep for light.
  Color accentPeach(bool isDark) => isDark ? warmPeach : deepOrange;

  /// Accent amber: warm for dark, deep for light.
  Color accentAmber(bool isDark) => isDark ? warmAmber : deepAmber;

  /// Accent orange: warm for dark, deep for light.
  Color accentOrange(bool isDark) => isDark ? warmOrange : deepOrange;

  /// Title color: white for dark, black for light.
  Color title(bool isDark) => isDark ? AppColors.white : AppColors.black;

  /// Muted text color.
  Color muted(bool isDark) => isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

  /// Faint text color (even more muted).
  Color faint(bool isDark) => isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;

  /// Glass background. Sólido em ambos os modos para não vazar o fundo.
  /// Dark: um degrau acima do card. Light: branco puro.
  Color glassBg(bool isDark) => isDark
      ? AppColors.blackLighter
      : AppColors.white;

  /// Glass border color.
  Color glassBorderColor(bool isDark) => isDark
      ? AppColors.blackLightest
      : AppColors.lightBorder;

  /// Card background color. Solid em ambos os modos — antes o dark tinha
  /// alpha 0.5, deixando o fundo (WaveBackground) atravessar os cards.
  Color cardBg(bool isDark) => isDark
      ? AppColors.blackLight
      : AppColors.white;

  /// Card border color.
  Color cardBorder(bool isDark) => isDark
      ? AppColors.blackLightest
      : AppColors.lightBorder;

  /// Surface background for cards, chips, inputs. Solid em dark (era 4%
  /// white → quase transparente).
  Color surfaceBg(bool isDark) => isDark
      ? AppColors.darkSurface
      : AppColors.white;

  /// Surface border for cards, inputs, containers.
  Color surfaceBorder(bool isDark) => isDark
      ? AppColors.blackLightest
      : Colors.black.withValues(alpha: 0.12);

  /// Subtle background for icon containers, buttons, progress bars.
  /// Um degrau acima do card pra criar contraste sem vazar o fundo.
  Color subtleBg(bool isDark) => isDark
      ? AppColors.blackLighter
      : AppColors.lightElevated;

  /// Image placeholder background (warm beige in light).
  Color imagePlaceholderBg(bool isDark) => isDark
      ? AppColors.blackLighter
      : const Color(0xFFF0EBE3);

  /// Warm background for splash/transition screens.
  Color warmScrimBg(bool isDark) => isDark
      ? Color.lerp(seed, Colors.black, 0.8)!
      : Color.lerp(seed, Colors.white, 0.8)!;

  /// Divider / thin separator color.
  Color dividerColor(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.12);

  /// Overlay pill background (floating over images).
  Color overlayPillBg(bool isDark) => isDark
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.white.withValues(alpha: 0.8);

  /// Subtle card shadow for light mode only.
  List<BoxShadow> subtleShadow(bool isDark) => isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ];

  /// Input field focus glow shadow for light mode only.
  List<BoxShadow> inputFocusShadow(bool isDark) => isDark
      ? const []
      : [
          BoxShadow(
            color: deepOrange.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DynamicBrutalistPalette &&
          runtimeType == other.runtimeType &&
          seed == other.seed;

  @override
  int get hashCode => seed.hashCode;
}

/// Static bridge to the dynamic palette system.
///
/// This allows legacy static code to benefit from real-time color updates
/// without requiring a full refactor of every page.
class BrutalistPalette {
  BrutalistPalette._();

  static DynamicBrutalistPalette _current = const DynamicBrutalistPalette(Color(0xFFFFB74D));

  // Static methods cannot be expressed as setters in Dart.
  // ignore: use_setters_to_change_properties
  static void update(DynamicBrutalistPalette newPalette) {
    _current = newPalette;
  }

  // --- CORE COLORS (delegated to _current) ---
  static Color get warmBrown => _current.warmBrown;
  static Color get warmOrange => _current.warmOrange;
  static Color get warmYellow => _current.warmYellow;
  static Color get warmPeach => _current.warmPeach;
  static Color get warmAmber => _current.warmAmber;
  static Color get deepBrown => _current.deepBrown;
  static Color get deepOrange => _current.deepOrange;
  static Color get deepAmber => _current.deepAmber;

  // --- SEMANTIC COLORS ---
  static Color title(bool isDark) => _current.title(isDark);
  static Color muted(bool isDark) => _current.muted(isDark);
  static Color faint(bool isDark) => _current.faint(isDark);
  static Color accentPeach(bool isDark) => _current.accentPeach(isDark);
  static Color accentAmber(bool isDark) => _current.accentAmber(isDark);
  static Color accentOrange(bool isDark) => _current.accentOrange(isDark);

  // --- SURFACE COLORS ---
  static Color cardBg(bool isDark) => _current.cardBg(isDark);
  static Color cardBorder(bool isDark) => _current.cardBorder(isDark);
  static Color surfaceBg(bool isDark) => _current.surfaceBg(isDark);
  static Color surfaceBorder(bool isDark) => _current.surfaceBorder(isDark);
  static Color subtleBg(bool isDark) => _current.subtleBg(isDark);
  static Color imagePlaceholderBg(bool isDark) => _current.imagePlaceholderBg(isDark);
  static Color warmScrimBg(bool isDark) => _current.warmScrimBg(isDark);
  static Color dividerColor(bool isDark) => _current.dividerColor(isDark);
  static Color overlayPillBg(bool isDark) => _current.overlayPillBg(isDark);

  // --- GLASS MORPHISM ---
  static Color glassBg(bool isDark) => _current.glassBg(isDark);
  static Color glassBorderColor(bool isDark) => _current.glassBorderColor(isDark);

  // --- EFFECTS ---
  static List<BoxShadow> subtleShadow(bool isDark) => _current.subtleShadow(isDark);
  static List<BoxShadow> inputFocusShadow(bool isDark) => _current.inputFocusShadow(isDark);
}
