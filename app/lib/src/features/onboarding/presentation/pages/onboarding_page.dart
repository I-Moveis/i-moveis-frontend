import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/design_system/design_system.dart';

/// Onboarding — Brutalist Elegance x Japanese Creative Web
///
/// 3 immersive slides with WaveBackground sunset, pulsing index
/// numbers, RevealText titles, section markers, glass skip button,
/// custom pill indicators, gradient shimmer CTA button.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _headerFade;
  late final Animation<double> _contentFade;
  late final Animation<double> _footerFade;

  static const _slides = [
    _SlideData(
      index: '01',
      titleTop: 'ENCONTRE',
      titleBottom: 'SEU LAR',
      marker: 'DATA-SYSTEM // DISCOVER',
      description: 'Milhares de imóveis verificados\nesperando por você',
    ),
    _SlideData(
      index: '02',
      titleTop: 'AGENDE',
      titleBottom: 'VISITAS',
      marker: 'DATA-SYSTEM // SCHEDULE',
      description: 'Sem telefonemas, sem espera.\nTudo pelo app',
    ),
    _SlideData(
      index: '03',
      titleTop: 'ALUGUE',
      titleBottom: 'DIGITAL',
      marker: 'DATA-SYSTEM // CONTRACT',
      description: 'Sem fiador.\nContrato 100% digital',
    ),
  ];

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
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
        _shimmerController.repeat();
        Future.delayed(const Duration(seconds: 9), () {
          if (mounted) {
            _pulseController.stop();
            _shimmerController.stop();
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: WaveBackground(
              colorScheme: WaveColorScheme.custom,
              speed: 0.4,
              amplitude: 0.8,
              waveCount: 7,
              adaptToTheme: true,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return Column(
                  children: [
                    // Skip button
                    const SizedBox(height: AppSpacing.lg),
                    _buildSkipButton(isDark),

                    // PageView slides
                    Expanded(
                      child: Opacity(
                        opacity: _contentFade.value,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          itemBuilder: (_, i) =>
                              _buildSlide(_slides[i], isDark),
                        ),
                      ),
                    ),

                    // Indicators + Button + Footer
                    _buildBottomSection(isDark),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SKIP BUTTON — glass style
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSkipButton(bool isDark) {
    return Opacity(
      opacity: _headerFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: AnimatedContainer(
              duration: AppDurations.normal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: BrutalistPalette.glassBg(isDark),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: BrutalistPalette.glassBorderColor(isDark),
                  width: 1,
                ),
              ),
              child: Text(
                'PULAR',
                style: AppTypography.labelSmall.copyWith(
                  color: BrutalistPalette.muted(isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SLIDE — index + titles + marker + description
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSlide(_SlideData slide, bool isDark) {
    final accentPeach = BrutalistPalette.accentPeach(isDark);
    final accentAmber = BrutalistPalette.accentAmber(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final descColor = BrutalistPalette.muted(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Index number with pulse
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final glow = _pulseController.value;
              return Text(
                slide.index,
                style: AppTypography.monoHero.copyWith(
                  color: isDark
                      ? BrutalistPalette.warmYellow.withValues(
                          alpha: 0.15 + glow * 0.08,
                        )
                      : BrutalistPalette.deepAmber.withValues(
                          alpha: 0.10 + glow * 0.06,
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xs),

          // Title top
          Text(
            slide.titleTop,
            style: AppTypography.displayBrand.copyWith(
              color: titleColor,
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          // Title bottom (accent)
          Text(
            slide.titleBottom,
            style: AppTypography.displaySubtitle.copyWith(
              color: accentPeach,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Section marker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 1,
                color: accentAmber.withValues(alpha: 0.4),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                slide.marker,
                style: AppTypography.sectionMarker.copyWith(
                  color: accentAmber.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 24,
                height: 1,
                color: accentAmber.withValues(alpha: 0.4),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: descColor,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BOTTOM SECTION — indicators + button + footer
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomSection(bool isDark) {
    final mutedColor = BrutalistPalette.faint(isDark);

    return Opacity(
      opacity: _footerFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          children: [
            // Page indicators
            _buildIndicators(isDark),
            const SizedBox(height: AppSpacing.xxxl),

            // CTA button
            _buildActionButton(isDark),
            const SizedBox(height: AppSpacing.xxl),

            // Version footer
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Text(
                  'v1.0.0 // DATA-SYSTEM',
                  style: AppTypography.monoSmallWide.copyWith(
                    color: mutedColor.withValues(
                      alpha: 0.3 + _pulseController.value * 0.15,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PAGE INDICATORS — pill active, dot inactive
  // ═══════════════════════════════════════════════════════════════
  Widget _buildIndicators(bool isDark) {
    final activeColor = BrutalistPalette.accentAmber(isDark);
    final inactiveColor = BrutalistPalette.faint(isDark).withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: isActive ? 24 : 6,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderFull,
            color: isActive
                ? activeColor
                : inactiveColor,
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ACTION BUTTON — gradient shimmer
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActionButton(bool isDark) {
    final isLastPage = _currentPage == _slides.length - 1;
    final buttonLabel = isLastPage ? 'COMEÇAR' : 'PRÓXIMO';

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;

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
          onTap: _goToNext,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: [
                  0.0,
                  (0.5 + sin(shimmerValue * 2 * pi) * 0.2)
                      .clamp(0.0, 1.0),
                  1.0,
                ],
              ),
              borderRadius: AppRadius.borderSm,
              boxShadow: AppShadows.buttonGlow(glowColor),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.borderSm,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: AppDurations.normal,
                        child: Text(
                          buttonLabel,
                          key: ValueKey(buttonLabel),
                          style: AppTypography.buttonLabel.copyWith(
                            color: buttonTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.arrow_forward_rounded,
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
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SLIDE DATA
// ═══════════════════════════════════════════════════════════════════
class _SlideData {
  const _SlideData({
    required this.index,
    required this.titleTop,
    required this.titleBottom,
    required this.marker,
    required this.description,
  });

  final String index;
  final String titleTop;
  final String titleBottom;
  final String marker;
  final String description;
}
