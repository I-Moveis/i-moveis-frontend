import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import '../effects/wave_background.dart';

/// Shared warm pastel palette used across all Brutalist Elegance pages.
///
/// Dark theme uses warm/bright tones. Light theme uses deep/muted tones.
abstract final class BrutalistPalette {
  static const warmYellow = Color(0xFFF5E6C8);    // softer, muted cream
  static const warmPeach = Color(0xFFE8C4A8);     // dusty peach
  static const warmOrange = Color(0xFFDEAD82);     // muted terracotta
  static const warmBrown = Color(0xFFC49A76);      // soft leather
  static const warmAmber = Color(0xFFD4B88C);      // warm sand

  static const deepOrange = Color(0xFFB07A50);     // earthy terracotta
  static const deepBrown = Color(0xFF9A6E48);      // warm wood
  static const deepAmber = Color(0xFFA68858);      // muted gold

  /// Accent peach: warm for dark, deep for light.
  static Color accentPeach(bool isDark) =>
      isDark ? warmPeach : deepOrange;

  /// Accent amber: warm for dark, deep for light.
  static Color accentAmber(bool isDark) =>
      isDark ? warmAmber : deepAmber;

  /// Accent orange: warm for dark, deep for light.
  static Color accentOrange(bool isDark) =>
      isDark ? warmOrange : deepOrange;

  /// Title color: white for dark, black for light.
  static Color title(bool isDark) =>
      isDark ? AppColors.white : AppColors.black;

  /// Muted text color.
  static Color muted(bool isDark) =>
      isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

  /// Faint text color (even more muted).
  static Color faint(bool isDark) =>
      isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;

  /// Glass background color.
  static Color glassBg(bool isDark) =>
      isDark ? AppColors.glass : const Color(0x14000000);

  /// Glass border color.
  static Color glassBorderColor(bool isDark) =>
      isDark ? AppColors.glassBorder : const Color(0x22000000);

  /// Card background color.
  static Color cardBg(bool isDark) => isDark
      ? AppColors.blackLight.withValues(alpha: 0.5)
      : AppColors.white.withValues(alpha: 0.9);

  /// Card border color.
  static Color cardBorder(bool isDark) => isDark
      ? AppColors.blackLightest.withValues(alpha: 0.5)
      : AppColors.lightBorder;

  /// Surface background for cards, chips, inputs.
  static Color surfaceBg(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.04)
      : Colors.white.withValues(alpha: 0.9);

  /// Surface border for cards, inputs, containers.
  static Color surfaceBorder(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.12);

  /// Subtle background for icon containers, buttons, progress bars.
  static Color subtleBg(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.08);

  /// Image placeholder background (warm beige in light).
  static Color imagePlaceholderBg(bool isDark) => isDark
      ? AppColors.blackLighter
      : const Color(0xFFF0EBE3);

  /// Warm background for splash/transition screens.
  static Color warmScrimBg(bool isDark) => isDark
      ? const Color(0xFF1A1410)
      : const Color(0xFFF5EDE4);

  /// Divider / thin separator color.
  static Color dividerColor(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.12);

  /// Overlay pill background (floating over images).
  static Color overlayPillBg(bool isDark) => isDark
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.white.withValues(alpha: 0.8);

  /// Subtle card shadow for light mode only.
  static List<BoxShadow> subtleShadow(bool isDark) => isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ];

  /// Input field focus glow shadow for light mode only.
  static List<BoxShadow> inputFocusShadow(bool isDark) => isDark
      ? const []
      : [
          BoxShadow(
            color: deepOrange.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];
}

/// Page scaffold for the Brutalist Elegance design language.
///
/// Provides the standard WaveBackground sunset + transparent Scaffold +
/// SafeArea + entrance/pulse animation controllers.
///
/// Usage:
/// ```dart
/// class MyPage extends StatefulWidget { ... }
///
/// class _MyPageState extends State<MyPage> with TickerProviderStateMixin {
///   @override
///   Widget build(BuildContext context) {
///     return BrutalistPageScaffold(
///       builder: (context, isDark, entrance, pulse) {
///         return CustomScrollView(slivers: [ ... ]);
///       },
///     );
///   }
/// }
/// ```
class BrutalistPageScaffold extends StatefulWidget {
  const BrutalistPageScaffold({
    super.key,
    required this.builder,
    this.waveColorScheme = WaveColorScheme.sunset,
    this.waveSpeed = 0.3,
    this.waveAmplitude = 0.6,
    this.waveCount = 5,
    this.resizeToAvoidBottomInset = false,
    this.showWaveBackground = true,
  });

  /// Builds the page content. Receives context, theme brightness,
  /// and the entrance/pulse controllers for orchestrating animations.
  final Widget Function(
    BuildContext context,
    bool isDark,
    AnimationController entranceController,
    AnimationController pulseController,
  ) builder;

  final WaveColorScheme waveColorScheme;
  final double waveSpeed;
  final double waveAmplitude;
  final int waveCount;
  final bool resizeToAvoidBottomInset;
  final bool showWaveBackground;

  @override
  State<BrutalistPageScaffold> createState() => _BrutalistPageScaffoldState();
}

class _BrutalistPageScaffoldState extends State<BrutalistPageScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
        Future.delayed(const Duration(seconds: 9), () {
          if (mounted) _pulseController.stop();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        if (widget.showWaveBackground)
          Positioned.fill(
            child: RepaintBoundary(
              child: WaveBackground(
                colorScheme: widget.waveColorScheme,
                speed: widget.waveSpeed,
                amplitude: widget.waveAmplitude,
                waveCount: widget.waveCount,
                adaptToTheme: true,
              ),
            ),
          ),

        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return widget.builder(
                  context,
                  isDark,
                  _entranceController,
                  _pulseController,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED BUILDERS — Section header, footer, glass container
// ═══════════════════════════════════════════════════════════════

/// Builds a numbered section header matching the Brutalist Elegance pattern.
///
/// Example:
/// ```
/// 01  DESTAQUES
/// ── DATA-SYSTEM // FEATURED
/// ```
class BrutalistSectionHeader extends StatelessWidget {
  const BrutalistSectionHeader({
    super.key,
    required this.index,
    required this.title,
    required this.marker,
  });

  final String index;
  final String title;
  final String marker;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final accentAmber = BrutalistPalette.accentAmber(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              index,
              style: AppTypography.monoIndex.copyWith(
                color: isDark
                    ? BrutalistPalette.warmYellow.withValues(alpha: 0.25)
                    : BrutalistPalette.deepAmber.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTypography.headlineLarge.copyWith(
                  color: titleColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              width: 16,
              height: 1,
              color: accentAmber.withValues(alpha: 0.4),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              marker,
              style: AppTypography.sectionMarker.copyWith(
                color: accentAmber.withValues(alpha: 0.5),
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The standard version footer used across all Brutalist pages.
class BrutalistVersionFooter extends StatelessWidget {
  const BrutalistVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = BrutalistPalette.faint(isDark);

    return Center(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 1,
            color: mutedColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'v1.0.0 // DATA-SYSTEM',
            style: AppTypography.monoSmall.copyWith(
              color: mutedColor.withValues(alpha: 0.4),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing index number (large mono display) used in page headers.
class BrutalistPulsingIndex extends StatelessWidget {
  const BrutalistPulsingIndex({
    super.key,
    required this.index,
    required this.pulseController,
    this.fontSize = 56,
  });

  final String index;
  final AnimationController pulseController;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final glow = pulseController.value;
        return Text(
          index,
          style: AppTypography.monoDisplay.copyWith(
            color: isDark
                ? BrutalistPalette.warmYellow.withValues(
                    alpha: 0.12 + glow * 0.06)
                : BrutalistPalette.deepAmber.withValues(
                    alpha: 0.08 + glow * 0.04),
            fontSize: fontSize,
            letterSpacing: -3.0,
          ),
        );
      },
    );
  }
}

/// A glass morphism container matching the Brutalist Elegance style.
class BrutalistGlassContainer extends StatelessWidget {
  const BrutalistGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: BrutalistPalette.glassBg(isDark),
          borderRadius: borderRadius ?? AppRadius.borderSm,
          border: Border.all(
            color: BrutalistPalette.glassBorderColor(isDark),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Gradient shimmer button matching the login/onboarding CTA style.
class BrutalistGradientButton extends StatelessWidget {
  const BrutalistGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            BrutalistPalette.warmBrown.withValues(alpha: 0.9),
            BrutalistPalette.warmOrange.withValues(alpha: 0.85),
            BrutalistPalette.warmYellow.withValues(alpha: 0.8),
          ]
        : [
            BrutalistPalette.deepBrown,
            BrutalistPalette.deepOrange,
            BrutalistPalette.deepAmber,
          ];

    final buttonTextColor = isDark ? AppColors.black : AppColors.white;
    final glowColor = isDark
        ? BrutalistPalette.warmOrange.withValues(alpha: 0.2)
        : BrutalistPalette.deepOrange.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: AppRadius.borderSm,
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderSm,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: buttonTextColor.withValues(alpha: 0.8),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: AppTypography.labelLarge.copyWith(
                            color: buttonTextColor,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          icon ?? Icons.arrow_forward_rounded,
                          size: 18,
                          color: buttonTextColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
