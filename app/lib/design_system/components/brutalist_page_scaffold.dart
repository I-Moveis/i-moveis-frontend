import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/seed_color_provider.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/brutalist_palette.dart';
import '../../design_system/effects/wave_background.dart';

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
class BrutalistPageScaffold extends ConsumerStatefulWidget {
  const BrutalistPageScaffold({
    required this.builder, super.key,
    this.waveColorScheme = WaveColorScheme.custom,
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
  ConsumerState<BrutalistPageScaffold> createState() => _BrutalistPageScaffoldState();
}

class _BrutalistPageScaffoldState extends ConsumerState<BrutalistPageScaffold>
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
/// ```dart
/// 01  DESTAQUES
/// ── DATA-SYSTEM // FEATURED
/// ```
class BrutalistSectionHeader extends ConsumerWidget {
  const BrutalistSectionHeader({
    required this.index, required this.title, required this.marker, super.key,
  });

  final String index;
  final String title;
  final String marker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final titleColor = palette.title(isDark);
    final accentAmber = palette.accentAmber(isDark);

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
                  letterSpacing: 1,
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
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The standard version footer used across all Brutalist pages.
class BrutalistVersionFooter extends ConsumerWidget {
  const BrutalistVersionFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final mutedColor = palette.faint(isDark);

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
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing index number (large mono display) used in page headers.
class BrutalistPulsingIndex extends ConsumerWidget {
  const BrutalistPulsingIndex({
    required this.index, required this.pulseController, super.key,
    this.fontSize = 56,
  });

  final String index;
  final AnimationController pulseController;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final glow = pulseController.value;
        return Text(
          index,
          style: AppTypography.monoDisplay.copyWith(
            color: isDark
                ? palette.warmYellow.withValues(
                    alpha: 0.12 + glow * 0.06)
                : palette.deepAmber.withValues(
                    alpha: 0.08 + glow * 0.04),
            fontSize: fontSize,
            letterSpacing: -3,
          ),
        );
      },
    );
  }
}

/// A glass morphism container matching the Brutalist Elegance style.
class BrutalistGlassContainer extends ConsumerWidget {
  const BrutalistGlassContainer({
    required this.child, super.key,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.glassBg(isDark),
          borderRadius: borderRadius ?? AppRadius.borderSm,
          border: Border.all(
            color: palette.glassBorderColor(isDark),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Gradient shimmer button matching the login/onboarding CTA style.
class BrutalistGradientButton extends ConsumerWidget {
  const BrutalistGradientButton({
    required this.label, required this.onTap, super.key,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);

    final gradientColors = isDark
        ? [
            palette.warmBrown.withValues(alpha: 0.9),
            palette.warmOrange.withValues(alpha: 0.85),
            palette.warmYellow.withValues(alpha: 0.8),
          ]
        : [
            palette.deepBrown,
            palette.deepOrange,
            palette.deepAmber,
          ];

    final buttonTextColor = isDark ? AppColors.black : AppColors.white;
    final glowColor = isDark
        ? palette.warmOrange.withValues(alpha: 0.2)
        : palette.deepOrange.withValues(alpha: 0.15);

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
                            letterSpacing: 3,
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
