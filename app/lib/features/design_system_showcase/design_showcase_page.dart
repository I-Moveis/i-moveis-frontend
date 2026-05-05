import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Showcase — Brutalist Elegance.
///
/// COMPLETE design system showcase: every token, component, effect,
/// and navigation system available in the design_system folder.
/// Organized into numbered sections for easy comparison.
class DesignShowcasePage extends StatefulWidget {
  const DesignShowcasePage({super.key});

  @override
  State<DesignShowcasePage> createState() => _DesignShowcasePageState();
}

class _DesignShowcasePageState extends State<DesignShowcasePage> {
  bool _isDark = true;
  int _navIndex = 0;
  String _bgStyle = 'Cosmic';
  int _minimalNavIndex = 0;
  int _bottomNavIndex = 0;
  int _progressNavIndex = 0;
  final ValueNotifier<double> _loadingProgress = ValueNotifier<double>(0);
  bool _isLoadingRunning = false;
  final Set<int> _selectedChips = {0};

  // New section states
  bool _fullscreenMenuOpen = false;
  bool _sidebarExpanded = true;
  int _sidebarNavIndex = 0;
  int _floatingNavIndex = 0;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  void _startLoadingDemo() {
    if (_isLoadingRunning) return;
    _loadingProgress.value = 0.0;
    setState(() => _isLoadingRunning = true);

    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return false;

      _loadingProgress.value = (_loadingProgress.value + 0.01).clamp(0.0, 1.0);

      if (_loadingProgress.value >= 1.0) {
        setState(() => _isLoadingRunning = false);
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? AppTheme.dark : AppTheme.light,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final faintColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;

    return Stack(
      children: [
        // Dynamic WebGL/Canvas Background Player
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: switch (_bgStyle) {
              'Cosmic' => const CosmicBackground(),
              'Waves' => const WaveBackground(),
              _ => const SizedBox.expand(),
            },
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              // ══════════════════════════════════════════════════
              //  HERO — one massive word. That's it.
              // ══════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Section marker
                        Text(
                          'DESIGN SYSTEM',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // THE title
                        RevealText(
                          text: 'Desafio\nCiclo.',
                          style: AppTypography.displayMassive
                              .copyWith(color: textColor),
                          duration: const Duration(milliseconds: 1000),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        Text(
                          'Catálogo completo do design system.\nTodas as tokens, componentes e efeitos.',
                          style: AppTypography.bodyLarge.copyWith(
                            color: mutedColor,
                            height: 1.8,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled,
                              ),
                              borderRadius: AppRadius.borderFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_backspace_rounded,
                                  size: 14,
                                  color: mutedColor,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'BACK TO LOGIN',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: mutedColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.huge),
                      ],
                    ),
                  ),
                ),
              ),

              // ══════════════════════════════════════════════════
              //  BULLET NAV — p5aholic style
              // ══════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: BulletNav(
                  items: const [
                    'Tokens',
                    'Components',
                    'Cards',
                    'Navigation',
                    'Effects'
                  ],
                  selectedIndex: _navIndex,
                  onTap: (i) => setState(() => _navIndex = i),
                ),
              ),

              // Divider
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  height: 1,
                  color:
                      isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                ),
              ),

              // ══════════════════════════════════════════════════
              //  THEME TOGGLE & CURSOR TESTER
              // ══════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final (i, label) in ['Dark', 'Light'].indexed) ...[
                            GlassButton(
                              label: label,
                              isActive: (i == 0 && isDark) || (i == 1 && !isDark),
                              onPressed: () {
                                if ((i == 0 && !isDark) || (i == 1 && isDark)) {
                                  _toggleTheme();
                                }
                              },
                            ),
                            if (i == 0) const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('WEBGL / CANVAS BACKGROUND', style: AppTypography.labelSmall.copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final bg in ['Cosmic', 'Waves'])
                            GlassButton(
                              label: bg.toUpperCase(),
                              isActive: _bgStyle == bg,
                              onPressed: () => setState(() => _bgStyle = bg),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  00 — JAPANESE WEB AESTHETICS (EXTRACTED)
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '00', title: 'EXTRACTED AESTHETICS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXTRACTED COLOR TOKENS', style: AppTypography.sectionMarker.copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(
                        children: [
                          _ColorSwatch(color: AppColors.lqveCyan, label: 'LQVE Cyan'),
                          SizedBox(width: AppSpacing.sm),
                          _ColorSwatch(color: AppColors.obakeBlue, label: 'Obake Blue'),
                          SizedBox(width: AppSpacing.sm),
                          _ColorSwatch(color: AppColors.obakePink, label: 'Obake Pink'),
                          SizedBox(width: AppSpacing.sm),
                          _ColorSwatch(color: AppColors.starpeggioCyan, label: 'Starpeggio'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Row(
                        children: [
                          _ColorSwatch(color: AppColors.overtureTeal, label: 'Overture Teal'),
                          SizedBox(width: AppSpacing.sm),
                          _ColorSwatch(color: AppColors.overtureDark, label: 'Overture Dark'),
                          SizedBox(width: AppSpacing.sm),
                          _ColorSwatch(color: AppColors.p5OffWhite, label: 'p5aholic White'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.gigantic),
                      
                      Text('EXTRACTED TYPOGRAPHIES (Google Fonts)', style: AppTypography.sectionMarker.copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.xl),
                      
                      _FontShowcaseItem(
                        title: 'Syne (PP Neue Machina alt)',
                        description: 'Modern, geometric, massive display style. Used in obake.blue and p5aholic headers.',
                        sampleText: 'RADICAL CREATIVE',
                        style: AppTypography.displayMedium.copyWith(color: textColor),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      _FontShowcaseItem(
                        title: "Space Grotesk (Suisse Int'l alt)",
                        description: 'Architectural and slightly brutalist. Used in LQVE for headlines and structural text.',
                        sampleText: 'STRUCTURAL. OVERVIEW.',
                        style: AppTypography.headlineMedium.copyWith(color: textColor, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      _FontShowcaseItem(
                        title: 'Manrope (Aventa alt)',
                        description: 'Quiet, highly legible geometric body text. Never competes with the display fonts.',
                        sampleText: 'The philosophy of this design system is to let the typography be the architecture. Body text is kept intentionally small and unopinionated to maximize the perceived scale of the headers.',
                        style: AppTypography.bodyLarge.copyWith(color: mutedColor),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      _FontShowcaseItem(
                        title: 'Space Mono (Oroban Masuria alt)',
                        description: 'Technical, calculated aesthetic. Used in Midnight Grand Orchestra for indices and numbers.',
                        sampleText: '01 02 DATA-STREAM',
                        style: AppTypography.monoIndex.copyWith(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  01 — TYPOGRAPHY SCALE
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '01', title: 'TYPOGRAPHY'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Massive
                      Text('Aa',
                          style: AppTypography.displayMassive
                              .copyWith(color: textColor)),
                      _TypeLabel('displayMassive — 72px / w800 / -4.0',
                          faintColor),
                      const SizedBox(height: AppSpacing.xxxl),

                      // Display Large
                      Text('Display Large',
                          style: AppTypography.displayLarge
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'displayLarge — 48px / w700 / -2.5', faintColor),
                      const SizedBox(height: AppSpacing.xxl),

                      // Display Medium
                      Text('Display Medium',
                          style: AppTypography.displayMedium
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'displayMedium — 36px / w700 / -1.5', faintColor),
                      const SizedBox(height: AppSpacing.xxl),

                      // Display Small
                      Text('Display Small',
                          style: AppTypography.displaySmall
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'displaySmall — 28px / w600 / -1.0', faintColor),
                      const SizedBox(height: AppSpacing.xxl),

                      // Headline Large
                      Text('Headline Large',
                          style: AppTypography.headlineLarge
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'headlineLarge — 22px / w600 / -0.5', faintColor),
                      const SizedBox(height: AppSpacing.xl),

                      // Headline Medium
                      Text('Headline Medium',
                          style: AppTypography.headlineMedium
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'headlineMedium — 18px / w600 / -0.3', faintColor),
                      const SizedBox(height: AppSpacing.xl),

                      // Headline Small
                      Text('Headline Small',
                          style: AppTypography.headlineSmall
                              .copyWith(color: textColor)),
                      _TypeLabel(
                          'headlineSmall — 16px / w600 / -0.2', faintColor),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      Text('Title Large',
                          style: AppTypography.titleLarge
                              .copyWith(color: textColor)),
                      Text('Title Medium',
                          style: AppTypography.titleMedium
                              .copyWith(color: textColor)),
                      Text('Title Small',
                          style: AppTypography.titleSmall
                              .copyWith(color: textColor)),
                      _TypeLabel('titleLarge 16 / titleMedium 14 / titleSmall 13',
                          faintColor),
                      const SizedBox(height: AppSpacing.xl),

                      // Body
                      Text(
                        'Body Large — The restraint of the body makes the display feel enormous. '
                        'Generous line-height (1.7) creates breathing room.',
                        style:
                            AppTypography.bodyLarge.copyWith(color: mutedColor),
                      ),
                      _TypeLabel('bodyLarge — 15px / w400 / 1.7 height',
                          faintColor),
                      const SizedBox(height: AppSpacing.md),
                      Text('Body Medium — 13px secondary content.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: mutedColor)),
                      Text('Body Small — 11px fine print.',
                          style: AppTypography.bodySmall
                              .copyWith(color: mutedColor)),
                      const SizedBox(height: AppSpacing.xxl),

                      // Labels
                      Text('LABEL LARGE',
                          style: AppTypography.labelLarge
                              .copyWith(color: mutedColor)),
                      Text('LABEL MEDIUM',
                          style: AppTypography.labelMedium
                              .copyWith(color: mutedColor)),
                      Text('LABEL SMALL',
                          style: AppTypography.labelSmall
                              .copyWith(color: mutedColor)),
                      _TypeLabel(
                          'labelLarge 12 / labelMedium 10 / labelSmall 9',
                          faintColor),
                      const SizedBox(height: AppSpacing.xxl),

                      // Mono
                      Text('01',
                          style: AppTypography.monoDisplay
                              .copyWith(color: faintColor)),
                      _TypeLabel('monoDisplay — 64px / w300', faintColor),
                      const SizedBox(height: AppSpacing.xl),
                      Text('32',
                          style: AppTypography.monoLarge
                              .copyWith(color: faintColor)),
                      _TypeLabel('monoLarge — 32px / w300', faintColor),
                      const SizedBox(height: AppSpacing.lg),
                      Text('22',
                          style: AppTypography.monoIndex
                              .copyWith(color: faintColor)),
                      _TypeLabel('monoIndex — 22px / w400 / 0.04em', faintColor),
                      const SizedBox(height: AppSpacing.lg),
                      Text('mono — 14px code/data',
                          style:
                              AppTypography.mono.copyWith(color: faintColor)),
                      Text('monoSmall — 11px',
                          style: AppTypography.monoSmall
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.xxl),

                      // Nav / Section
                      Text('SECTION MARKER',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('NAVIGATION LABEL',
                          style: AppTypography.navLabel
                              .copyWith(color: mutedColor)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  02 — COLORS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '02', title: 'PALETTE'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE BLACK',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(children: [
                        _ColorSwatch(color: AppColors.black, label: '#0F0F0F'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.blackLight, label: '#1A1A1A'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.blackLighter, label: '#242424'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.blackLightest, label: '#333333'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.white,
                            label: '#FFFFFF',
                            border: true),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('TEXT HIERARCHY',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(children: [
                        _ColorSwatch(color: AppColors.white, label: 'Primary', border: true),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(color: AppColors.whiteDim, label: 'Dim'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.whiteMuted, label: 'Muted'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.whiteFaint, label: 'Faint'),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('SEMANTIC',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(children: [
                        _ColorSwatch(
                            color: AppColors.success, label: 'Success'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(
                            color: AppColors.warning, label: 'Warning'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(color: AppColors.error, label: 'Error'),
                        SizedBox(width: AppSpacing.sm),
                        _ColorSwatch(color: AppColors.info, label: 'Info'),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('IRIDESCENT',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: AppRadius.borderXs,
                        child: SizedBox(
                          height: 48,
                          child: Row(children: [
                            for (final c in [
                              AppColors.iridescent1,
                              AppColors.iridescent2,
                              AppColors.iridescent3,
                              AppColors.iridescent4,
                              AppColors.iridescent5,
                              AppColors.iridescent6,
                            ])
                              Expanded(child: Container(color: c)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('PASTEL',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: AppRadius.borderXs,
                        child: SizedBox(
                          height: 48,
                          child: Row(children: [
                            for (final c in [
                              AppColors.pastelPink,
                              AppColors.pastelBlue,
                              AppColors.pastelMint,
                              AppColors.pastelLavender,
                              AppColors.pastelYellow,
                              AppColors.pastelPeach,
                            ])
                              Expanded(child: Container(color: c)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  03 — SPACING SCALE
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '03', title: 'SPACING'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (name, value) in [
                        ('xxs', AppSpacing.xxs),
                        ('xs', AppSpacing.xs),
                        ('sm', AppSpacing.sm),
                        ('md', AppSpacing.md),
                        ('lg', AppSpacing.lg),
                        ('xl', AppSpacing.xl),
                        ('xxl', AppSpacing.xxl),
                        ('xxxl', AppSpacing.xxxl),
                        ('huge', AppSpacing.huge),
                        ('massive', AppSpacing.massive),
                        ('gigantic', AppSpacing.gigantic),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(name,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text('${value.toInt()}px',
                                    style: AppTypography.monoSmall
                                        .copyWith(color: faintColor)),
                              ),
                              Container(
                                width: value,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.whiteFaint
                                      : AppColors.lightTextDisabled,
                                  borderRadius: AppRadius.borderXs,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  04 — RADIUS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '04', title: 'RADIUS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final (name, radius) in [
                        ('none', AppRadius.none),
                        ('xs (4)', AppRadius.xs),
                        ('sm (8)', AppRadius.sm),
                        ('md (12)', AppRadius.md),
                        ('lg (16)', AppRadius.lg),
                        ('xl (20)', AppRadius.xl),
                        ('xxl (24)', AppRadius.xxl),
                        ('full', AppRadius.full),
                      ])
                        Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkElevated
                                    : AppColors.lightBorderSubtle,
                                borderRadius: BorderRadius.circular(
                                    radius.clamp(0, 28)),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(name,
                                style: AppTypography.monoSmall
                                    .copyWith(color: faintColor, fontSize: 8)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  05 — DURATIONS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '05', title: 'DURATIONS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (name, dur) in [
                        ('fast', AppDurations.fast),
                        ('normal', AppDurations.normal),
                        ('medium', AppDurations.medium),
                        ('slow', AppDurations.slow),
                        ('emphasis', AppDurations.emphasis),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(name,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text('${dur.inMilliseconds}ms',
                                    style: AppTypography.monoSmall
                                        .copyWith(color: faintColor)),
                              ),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBorderSubtle
                                        : AppColors.lightBorderSubtle,
                                    borderRadius: AppRadius.borderFull,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor:
                                        dur.inMilliseconds / 600.0,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: mutedColor,
                                        borderRadius: AppRadius.borderFull,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  06 — BUTTONS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '06', title: 'BUTTONS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('AppButton variants',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                          label: 'Primary',
                          onPressed: () {},
                          isExpanded: true),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                          label: 'Secondary',
                          variant: AppButtonVariant.secondary,
                          onPressed: () {},
                          isExpanded: true),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                          label: 'Outline',
                          variant: AppButtonVariant.outline,
                          onPressed: () {},
                          isExpanded: true),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        Expanded(
                          child: AppButton(
                              label: 'Ghost',
                              variant: AppButtonVariant.ghost,
                              onPressed: () {},
                              isExpanded: true),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                              label: 'Danger',
                              variant: AppButtonVariant.danger,
                              onPressed: () {},
                              isExpanded: true),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('AppButton sizes',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        AppButton(
                            label: 'Small',
                            size: AppButtonSize.small,
                            onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                            label: 'Medium',
                            onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                            label: 'Large',
                            size: AppButtonSize.large,
                            onPressed: () {}),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('With icons & loading',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        AppButton(
                            label: 'Icon',
                            icon: Icons.add,
                            onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                            label: 'Trailing',
                            trailingIcon: Icons.arrow_forward,
                            onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
                        const AppButton(
                            label: 'Loading', isLoading: true),
                      ]),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('GlassButton',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        GlassButton(label: 'Glass', onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
                        GlassButton(
                            label: 'Active',
                            onPressed: () {},
                            isActive: true),
                        const SizedBox(width: AppSpacing.sm),
                        GlassButton(
                            label: 'Icon',
                            icon: Icons.arrow_forward,
                            onPressed: () {}),
                      ]),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  07 — CHIPS & BADGES
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '07', title: 'CHIPS & BADGES'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AppChip (filter)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final (i, label) in [
                            'All',
                            'Projects',
                            'Experiments',
                            'Archives',
                          ].indexed)
                            AppChip(
                              label: label,
                              isSelected: _selectedChips.contains(i),
                              onTap: () {
                                setState(() {
                                  if (_selectedChips.contains(i)) {
                                    _selectedChips.remove(i);
                                  } else {
                                    _selectedChips.add(i);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('PastelChip',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          PastelChip(
                              label: 'ILLUSTRATION',
                              color: AppColors.pastelPink),
                          PastelChip(
                              label: 'DESIGN', color: AppColors.pastelBlue),
                          PastelChip(
                              label: 'MUSIC', color: AppColors.pastelLavender),
                          PastelChip(
                              label: 'ARCHIVE', color: AppColors.pastelMint),
                          PastelChip(
                              label: 'MOTION', color: AppColors.pastelYellow),
                          PastelChip(
                              label: 'PHOTO', color: AppColors.pastelPeach),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('AppBadge',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppBadge(
                              label: 'LIVE',
                              variant: AppBadgeVariant.success),
                          AppBadge(
                              label: 'PENDING',
                              variant: AppBadgeVariant.warning),
                          AppBadge(
                              label: 'ERROR',
                              variant: AppBadgeVariant.error),
                          AppBadge(
                              label: 'ARCHIVE'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  08 — INPUTS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '08', title: 'INPUTS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      Text('AppSearchBar',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppSearchBar(
                        isButton: true,
                        onTap: () {
                          showAppBottomSheet<void>(
                            context: context,
                            builder: (ctx) => const Padding(
                              padding: EdgeInsets.all(
                                  AppSpacing.screenHorizontal),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBottomSheetHeader(title: 'Search'),
                                  SizedBox(height: AppSpacing.lg),
                                  AppSearchBar(
                                      hint: 'Type...', autofocus: true),
                                  SizedBox(height: AppSpacing.xxl),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('AppTextField',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const AppTextField(
                        label: 'EMAIL',
                        hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const AppTextField(
                        label: 'PASSWORD',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: Icons.visibility_off_outlined,
                        obscureText: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const AppTextField(
                        label: 'NAME',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  09 — AVATARS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '09', title: 'AVATARS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AppAvatar sizes',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(
                        children: [
                          AppAvatar(size: AppAvatarSize.xs, initials: 'XS'),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(size: AppAvatarSize.sm, initials: 'SM'),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(initials: 'MD'),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(size: AppAvatarSize.lg, initials: 'LG'),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(size: AppAvatarSize.xl, initials: 'XL'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('With badge & icon fallback',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      const Row(
                        children: [
                          AppAvatar(
                              size: AppAvatarSize.lg,
                              initials: 'DC',
                              showBadge: true),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(
                              size: AppAvatarSize.lg,
                              showBadge: true,
                              badgeColor: AppColors.warning),
                          SizedBox(width: AppSpacing.md),
                          AppAvatar(
                              size: AppAvatarSize.lg,
                              initials: 'AB',
                              backgroundColor: AppColors.iridescent6),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  10 — CARDS (Basic)
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '10', title: 'CARDS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AppCard',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Standard Card',
                                style: AppTypography.headlineSmall
                                    .copyWith(color: textColor)),
                            const SizedBox(height: AppSpacing.xs),
                            Text('With border and optional elevation.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('AppImageCard',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppImageCard(
                        title: 'Beach Apartment',
                        subtitle: r'Florianópolis • R$ 250/night',
                        badge: 'Novo',
                        placeholderColor: AppColors.iridescent5.withValues(alpha: 0.2),
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('AppGlassCard',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppGlassCard(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glass Card',
                                style: AppTypography.headlineSmall
                                    .copyWith(color: textColor)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                                'Frosted glass effect with backdrop blur.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  11 — ADVANCED CARDS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '11', title: 'ADVANCED CARDS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ProjectShowcaseCard (LQVE)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ProjectShowcaseCard(
                        index: 1,
                        title: 'Midnight Grand Orchestra',
                        client: 'PUNCH',
                        year: '2026',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('GlassmorphicCard (p5aholic)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      GlassmorphicCard(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glassmorphic',
                                style: AppTypography.headlineLarge
                                    .copyWith(color: textColor)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                                'Frosted glass with customizable blur & opacity.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('PortfolioGridCard (obake.blue)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      PortfolioGridCard(
                        index: 7,
                        title: 'Web Graphic Experiments v3',
                        date: '2026.04',
                        category: 'Design & Dev',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('MusicReleaseCard (Starpeggio)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      MusicReleaseCard(
                        title: 'OVERTURE',
                        subtitle: 'Midnight Grand Orchestra',
                        edition: 'LIMITED EDITION',
                        price: '¥4,400',
                        trackList: const [
                          'Overture',
                          'Starlight',
                          'Midnight Run',
                          'Echo Chamber',
                        ],
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('ExhibitionCard (ILY GIRL)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ExhibitionCard(
                        titleJp: 'イリーガール展',
                        titleEn: 'ILY GIRL Exhibition',
                        dateRange: 'Jan 15 – Feb 28, 2026',
                        venue: 'Shibuya Gallery',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text('CreatorProfileCard (punchred.xyz)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      CreatorProfileCard(
                        name: 'Keita Yamada',
                        role: 'Creative Developer / Designer',
                        bio: 'Building experimental web experiences that push the boundaries of browser capabilities.',
                        socialLinks: const [
                          CreatorSocialLink(
                              label: 'GitHub', url: 'https://github.com'),
                          CreatorSocialLink(
                              label: 'Twitter', url: 'https://twitter.com'),
                        ],
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  12 — NUMBERED CARD
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '12', title: 'NUMBERED CARD'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: NumberedCard(
                    number: 1,
                    title: 'UNDER VOYAGER',
                    subtitle: 'Collaborative project with Mika Pikazo',
                    date: '2026.02',
                    imageColor: AppColors.iridescent6.withValues(alpha: 0.15),
                    onTap: () {},
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  13 — LIST TILES
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '13', title: 'LIST TILES'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AppListTile(
                      title: 'Account Settings',
                      subtitle: 'Manage your profile and preferences',
                      leading: const AppAvatar(
                          size: AppAvatarSize.sm, initials: 'AS'),
                      onTap: () {},
                      showDivider: true,
                    ),
                    AppListTile(
                      title: 'Notifications',
                      subtitle: 'Push, email, and SMS settings',
                      leading: Icon(Icons.notifications_outlined,
                          color: mutedColor, size: 24),
                      onTap: () {},
                      showDivider: true,
                    ),
                    AppListTile(
                      title: 'Privacy & Security',
                      subtitle: 'Data sharing and account protection',
                      leading: Icon(Icons.shield_outlined,
                          color: mutedColor, size: 24),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  14 — PROJECT LIST ITEMS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child:
                    _SectionHeader(number: '14', title: 'PROJECT LIST ITEMS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ProjectListItem(
                      index: 1,
                      title: 'Midnight Grand Orchestra',
                      role: 'Design & Dev',
                      date: 'Apr 2026',
                      collaborator: 'PUNCH',
                      onTap: () {},
                    ),
                    ProjectListItem(
                      index: 2,
                      title: 'Web Graphic Experiments v3',
                      role: 'Dev / Design',
                      date: 'Mar 2026',
                      onTap: () {},
                    ),
                    ProjectListItem(
                      index: 3,
                      title: 'UNDER VOYAGER',
                      role: 'Design & Dev',
                      date: 'Feb 2026',
                      collaborator: 'Mika Pikazo',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  15 — MINIMAL NAV
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '15', title: 'MINIMAL NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: MinimalNav(
                  items: const ['Works', 'Room 444', 'About', 'Contact'],
                  selectedIndex: _minimalNavIndex,
                  onTap: (i) => setState(() => _minimalNavIndex = i),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  16 — BOTTOM NAV
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '16', title: 'BOTTOM NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: AppBottomNav(
                      currentIndex: _bottomNavIndex,
                      onTap: (i) => setState(() => _bottomNavIndex = i),
                      items: const [
                        AppBottomNavItem(
                            icon: Icons.explore_outlined,
                            activeIcon: Icons.explore,
                            label: 'Explore'),
                        AppBottomNavItem(
                            icon: Icons.favorite_outline,
                            activeIcon: Icons.favorite,
                            label: 'Saved'),
                        AppBottomNavItem(
                            icon: Icons.chat_outlined,
                            activeIcon: Icons.chat,
                            label: 'Messages'),
                        AppBottomNavItem(
                            icon: Icons.person_outline,
                            activeIcon: Icons.person,
                            label: 'Profile'),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  17 — BREADCRUMB NAV
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '17', title: 'BREADCRUMB NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: BreadcrumbNav(
                    items: [
                      BreadcrumbItem(label: 'Home', onTap: () {}),
                      BreadcrumbItem(label: 'Projects', onTap: () {}),
                      const BreadcrumbItem(label: 'Midnight Orchestra'),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  18 — PROGRESS NAV (Dots + Bar)
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '18', title: 'PROGRESS NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dots mode',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ProgressNav(
                        sections: const [
                          ProgressNavSection(label: 'Intro'),
                          ProgressNavSection(label: 'Work'),
                          ProgressNavSection(label: 'About'),
                          ProgressNavSection(label: 'Contact'),
                        ],
                        currentIndex: _progressNavIndex,
                        onSectionTap: (i) =>
                            setState(() => _progressNavIndex = i),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('Bar mode',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ProgressNav(
                        sections: const [
                          ProgressNavSection(label: 'Intro'),
                          ProgressNavSection(label: 'Work'),
                          ProgressNavSection(label: 'About'),
                          ProgressNavSection(label: 'Contact'),
                        ],
                        currentIndex: _progressNavIndex,
                        scrollProgress:
                            _progressNavIndex / 3.0,
                        mode: ProgressNavMode.bar,
                        onSectionTap: (i) =>
                            setState(() => _progressNavIndex = i),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  19 — CINEMATIC HERO
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '19', title: 'CINEMATIC HERO'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: CinematicHero(
                      title: 'RADICAL\nCREATIVE.',
                      subtitle: 'Full-screen cinematic impact area',
                      sectionLabel: 'HERO SECTION',
                      height: 300,
                      showStars: isDark,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  20 — SCROLL ANIMATIONS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child:
                    _SectionHeader(number: '20', title: 'SCROLL ANIMATIONS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ScrollReveal (scroll to see)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      ScrollReveal(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorderSubtle
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Text('↑ Revealed from below',
                              style: AppTypography.headlineSmall
                                  .copyWith(color: textColor)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        direction: RevealDirection.left,
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorderSubtle
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Text('← Revealed from left',
                              style: AppTypography.headlineSmall
                                  .copyWith(color: textColor)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('StaggeredReveal',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      StaggeredReveal(
                        children: [
                          for (int i = 0; i < 4; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: AppRadius.borderSm,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorderSubtle
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: Text('Staggered item ${i + 1}',
                                    style: AppTypography.bodyLarge
                                        .copyWith(color: textColor)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('TextReveal',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      TextReveal(
                        text: 'Each character animates into view individually.',
                        style: AppTypography.headlineMedium
                            .copyWith(color: textColor),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextReveal(
                        text: 'Word by word reveal animation.',
                        style: AppTypography.headlineMedium
                            .copyWith(color: mutedColor),
                        perWord: true,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('CountUpText',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CountUpText(
                                  value: 47,
                                  padLeft: 2,
                                  style: AppTypography.monoDisplay
                                      .copyWith(color: textColor),
                                ),
                                Text('Projects',
                                    style: AppTypography.labelMedium
                                        .copyWith(color: faintColor)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                CountUpText(
                                  value: 12,
                                  padLeft: 2,
                                  style: AppTypography.monoDisplay
                                      .copyWith(color: textColor),
                                ),
                                Text('Clients',
                                    style: AppTypography.labelMedium
                                        .copyWith(color: faintColor)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                CountUpText(
                                  value: 99.9,
                                  decimalPlaces: 1,
                                  suffix: '%',
                                  style: AppTypography.monoLarge
                                      .copyWith(color: textColor),
                                ),
                                Text('Uptime',
                                    style: AppTypography.labelMedium
                                        .copyWith(color: faintColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  21 — FADE SLIDE IN
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '21', title: 'FADE SLIDE IN'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 3; i++)
                        FadeSlideIn(
                          delay: Duration(milliseconds: 200 * i),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorderSubtle
                                      : AppColors.lightBorder,
                                ),
                              ),
                              child: Text(
                                  'FadeSlideIn — delay ${200 * i}ms',
                                  style: AppTypography.bodyLarge
                                      .copyWith(color: textColor)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  22 — LOADING SCREENS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child:
                    _SectionHeader(number: '22', title: 'LOADING SCREENS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppButton(
                        label: _isLoadingRunning
                            ? 'Loading...'
                            : 'Start Loading Demo',
                        icon: Icons.play_arrow,
                        onPressed: _startLoadingDemo,
                        isExpanded: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      for (final (label, style) in [
                        ('Minimal', LoadingStyle.minimal),
                        ('Cosmic', LoadingStyle.cosmic),
                        ('Wave', LoadingStyle.wave),
                      ]) ...[
                        Text(label,
                            style: AppTypography.labelLarge
                                .copyWith(color: faintColor)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          height: 160,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorderSubtle
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: ValueListenableBuilder<double>(
                            valueListenable: _loadingProgress,
                            builder: (context, progress, _) {
                              return LoadingScreen(
                                progress: progress,
                                style: style,
                                backgroundColor: isDark
                                    ? AppColors.black
                                    : AppColors.lightElevated,
                                foregroundColor:
                                    isDark ? AppColors.white : AppColors.black,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  23 — BOTTOM SHEET
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '23', title: 'BOTTOM SHEET'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: AppButton(
                    label: 'Open Bottom Sheet',
                    icon: Icons.vertical_align_bottom,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      showAppBottomSheet<void>(
                        context: context,
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(
                              AppSpacing.screenHorizontal),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppBottomSheetHeader(
                                  title: 'Example Sheet'),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'This is a design-system styled bottom sheet with drag handle, '
                                'header, and consistent styling.',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppColors.whiteDim
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              AppButton(
                                label: 'Got it',
                                onPressed: () => Navigator.pop(ctx),
                                isExpanded: true,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                      );
                    },
                    isExpanded: true,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  24 — SHADOWS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '24', title: 'SHADOWS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Light theme shadows',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          for (final (label, shadow) in [
                            ('Sm', AppShadows.lightSm),
                            ('Md', AppShadows.lightMd),
                            ('Lg', AppShadows.lightLg),
                          ]) ...[
                            Expanded(
                              child: Container(
                                height: 64,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: AppRadius.borderMd,
                                  boxShadow: shadow,
                                ),
                                alignment: Alignment.center,
                                child: Text(label,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Glow effects',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          for (final (label, shadow) in [
                            ('Primary', AppShadows.primaryGlow),
                            ('Accent', AppShadows.accentGlow),
                            ('Error', AppShadows.errorGlow),
                          ]) ...[
                            Expanded(
                              child: Container(
                                height: 64,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: AppRadius.borderMd,
                                  boxShadow: shadow,
                                ),
                                alignment: Alignment.center,
                                child: Text(label,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  25 — GLASS & OVERLAY
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '25', title: 'GLASS & OVERLAY'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GLASS TOKENS',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Text('glass — 1% white, glassBorder — 4% white',
                          style: AppTypography.monoSmall
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glass Container',
                                style: AppTypography.headlineSmall
                                    .copyWith(color: textColor)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                                "Almost invisible. That's the point. (p5aholic)",
                                style: AppTypography.bodyMedium
                                    .copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        decoration: BoxDecoration(
                          gradient: AppColors.glassGradient,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glass Gradient',
                                style: AppTypography.headlineSmall
                                    .copyWith(color: textColor)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                                'Subtle top-left to bottom-right gradient, 5%→2% white.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('OVERLAY TOKENS',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          for (final (label, color) in [
                            ('Light\n4%', AppColors.overlayLight),
                            ('Medium\n10%', AppColors.overlayMedium),
                            ('Dark\n50%', AppColors.overlayDark),
                            ('Scrim\n80%', AppColors.scrim),
                          ]) ...[
                            Expanded(
                              child: Container(
                                height: 72,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxs),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: AppRadius.borderSm,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorderSubtle
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(label,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.monoSmall.copyWith(
                                        color: AppColors.white, fontSize: 8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('GRAIN TEXTURE',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightElevated,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorderSubtle
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Grain noise simulation via repeating tiny dots
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.borderMd,
                                  color: AppColors.grain,
                                ),
                              ),
                            ),
                            Center(
                              child: Text('grain — Color(0x08FFFFFF)',
                                  style: AppTypography.monoSmall
                                      .copyWith(color: mutedColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),


              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  27 — SURFACE COLORS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '27', title: 'SURFACE COLORS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DARK THEME SURFACES',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      for (final (label, color, hex) in [
                        ('darkBackground', AppColors.darkBackground, '#0F0F0F'),
                        ('darkSurface', AppColors.darkSurface, '#141414'),
                        ('darkCard', AppColors.darkCard, '#1A1A1A'),
                        ('darkElevated', AppColors.darkElevated, '#242424'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: AppRadius.borderXs,
                                  border: Border.all(
                                    color: AppColors.darkBorderSubtle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(label,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                              Text(hex,
                                  style: AppTypography.monoSmall
                                      .copyWith(color: faintColor)),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('LIGHT THEME SURFACES',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      for (final (label, color, hex) in [
                        ('lightBackground', AppColors.lightBackground, '#FFFFFF'),
                        ('lightSurface', AppColors.lightSurface, '#FFFFFF'),
                        ('lightCard', AppColors.lightCard, '#FFFFFF'),
                        ('lightElevated', AppColors.lightElevated, '#F5F5F5'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: AppRadius.borderXs,
                                  border: Border.all(
                                    color: AppColors.lightBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(label,
                                    style: AppTypography.monoSmall
                                        .copyWith(color: mutedColor)),
                              ),
                              Text(hex,
                                  style: AppTypography.monoSmall
                                      .copyWith(color: faintColor)),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text('BORDER TOKENS',
                          style: AppTypography.sectionMarker
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          for (final (label, color) in [
                            ('darkBorder', AppColors.darkBorder),
                            ('darkBorderSubtle', AppColors.darkBorderSubtle),
                            ('lightBorder', AppColors.lightBorder),
                            ('lightBorderSubtle', AppColors.lightBorderSubtle),
                          ]) ...[
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.borderXs,
                                      border: Border.all(
                                          color: color, width: 2),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(label,
                                      style: AppTypography.monoSmall.copyWith(
                                          color: faintColor, fontSize: 7),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  28 — FULLSCREEN MENU
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child:
                    _SectionHeader(number: '28', title: 'FULLSCREEN MENU'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FullscreenMenu (p5aholic / LQVE)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                          'Overlay navigation with staggered animation, massive typography, and indexed items.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: mutedColor)),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Open Fullscreen Menu',
                        icon: Icons.menu,
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            setState(() => _fullscreenMenuOpen = true),
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  29 — SIDEBAR NAV
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '29', title: 'SIDEBAR NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SidebarNav (punchred.xyz)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        height: 320,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorderSubtle
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            SidebarNav(
                              items: const [
                                SidebarNavItem(
                                    icon: Icons.home_outlined,
                                    label: 'Home'),
                                SidebarNavItem(
                                    icon: Icons.work_outline,
                                    label: 'Projects'),
                                SidebarNavItem(
                                    icon: Icons.info_outline,
                                    label: 'About'),
                                SidebarNavItem(
                                    icon: Icons.email_outlined,
                                    label: 'Contact'),
                              ],
                              currentIndex: _sidebarNavIndex,
                              expanded: _sidebarExpanded,
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightElevated,
                              activeColor: isDark
                                  ? AppColors.white
                                  : AppColors.black,
                              inactiveColor: isDark
                                  ? AppColors.whiteFaint
                                  : AppColors.lightTextTertiary,
                              indicatorColor: isDark
                                  ? AppColors.white
                                  : AppColors.black,
                              onItemTap: (i) =>
                                  setState(() => _sidebarNavIndex = i),
                              onToggle: () => setState(
                                  () => _sidebarExpanded = !_sidebarExpanded),
                            ),
                            Expanded(
                              child: Container(
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                                alignment: Alignment.center,
                                child: Text(
                                  'Content area\nSelected: ${['Home', 'Projects', 'About', 'Contact'][_sidebarNavIndex]}',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium
                                      .copyWith(color: mutedColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  30 — FLOATING NAV
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child: _SectionHeader(number: '30', title: 'FLOATING NAV'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FloatingNav (LQVE)',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                          'Glass pill that auto-hides on scroll. Shown here as standalone.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: mutedColor)),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: FloatingNav(
                          items: const [
                            FloatingNavItem(
                                icon: Icons.home_outlined, label: 'Home'),
                            FloatingNavItem(
                                icon: Icons.explore_outlined,
                                label: 'Explore'),
                            FloatingNavItem(
                                icon: Icons.favorite_outline,
                                label: 'Saved'),
                            FloatingNavItem(
                                icon: Icons.person_outline,
                                label: 'Profile'),
                          ],
                          currentIndex: _floatingNavIndex,
                          onItemTap: (i) =>
                              setState(() => _floatingNavIndex = i),
                          bottomPadding: 0,
                          backgroundColor: isDark
                              ? AppColors.blackLight.withValues(alpha: 0.85)
                              : AppColors.white.withValues(alpha: 0.9),
                          activeColor: isDark
                              ? AppColors.white
                              : AppColors.black,
                          inactiveColor: isDark
                              ? AppColors.whiteMuted
                              : AppColors.lightTextTertiary,
                          activeFillColor: isDark
                              ? AppColors.white.withValues(alpha: 0.1)
                              : AppColors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  31 — PAGE TRANSITIONS
              // ══════════════════════════════════════════════════
              const SliverToBoxAdapter(
                child:
                    _SectionHeader(number: '31', title: 'PAGE TRANSITIONS'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tap each to test the transition live',
                          style: AppTypography.labelLarge
                              .copyWith(color: faintColor)),
                      const SizedBox(height: AppSpacing.md),
                      _TransitionButton(
                        name: 'CurtainTransition',
                        description: 'p5aholic-style page wipe. Two-phase: cover then reveal.',
                        icon: Icons.curtains,
                        onTap: () => Navigator.of(context).push(
                          CurtainTransition(
                            page: const _TransitionDemoPage(name: 'Curtain'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _TransitionButton(
                        name: 'CircleReveal',
                        description: 'ILY GIRL-style expanding circle clip from center.',
                        icon: Icons.circle_outlined,
                        onTap: () => Navigator.of(context).push(
                          CircleReveal.center(
                            page: const _TransitionDemoPage(name: 'Circle Reveal'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _TransitionButton(
                        name: 'SliceTransition',
                        description: 'obake.blue-style staggered horizontal slices.',
                        icon: Icons.view_column_outlined,
                        onTap: () => Navigator.of(context).push(
                          SliceTransition(
                            page: const _TransitionDemoPage(name: 'Slice'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _TransitionButton(
                        name: 'FadeSlideTransition',
                        description: 'LQVE-style subtle fade + upward slide.',
                        icon: Icons.swap_vert,
                        onTap: () => Navigator.of(context).push(
                          FadeSlideTransition(
                            page: const _TransitionDemoPage(name: 'Fade Slide'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _TransitionButton(
                        name: 'GlitchTransition',
                        description: 'punchred.xyz-style RGB shift + displaced slices. 280ms.',
                        icon: Icons.flash_on,
                        onTap: () => Navigator.of(context).push(
                          GlitchTransition(
                            page: const _TransitionDemoPage(name: 'Glitch'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.gigantic)),

              // ══════════════════════════════════════════════════
              //  FOOTER
              // ══════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  height: 1,
                  color:
                      isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'COMPLETE DESIGN SYSTEM',
                        style: AppTypography.sectionMarker
                            .copyWith(color: faintColor),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('© 2026',
                              style: AppTypography.monoSmall
                                  .copyWith(color: faintColor)),
                          const SizedBox(width: AppSpacing.xxl),
                          Text('Desafio Ciclo',
                              style: AppTypography.monoSmall
                                  .copyWith(color: mutedColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
            ],
          ),
        ),

        // ── Fullscreen Menu Overlay ──
        FullscreenMenu(
          isOpen: _fullscreenMenuOpen,
          items: const [
            FullscreenMenuItem(label: 'Work', subtitle: 'Selected projects'),
            FullscreenMenuItem(label: 'About', subtitle: 'Our philosophy'),
            FullscreenMenuItem(label: 'Contact', subtitle: 'Get in touch'),
            FullscreenMenuItem(label: 'Archive', subtitle: 'Past experiments'),
          ],
          backgroundColor: isDark
              ? AppColors.black.withValues(alpha: 0.96)
              : AppColors.white.withValues(alpha: 0.97),
          textColor: isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary,
          activeTextColor: isDark ? AppColors.white : AppColors.black,
          indexColor: isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled,
          socialLinks: const [
            SocialLink(label: 'GitHub', icon: Icons.code),
            SocialLink(label: 'Twitter', icon: Icons.alternate_email),
          ],
          onClose: () => setState(() => _fullscreenMenuOpen = false),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HELPERS — minimal, functional
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.number, required this.title});
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          Text(
            number,
            style: AppTypography.monoSmall.copyWith(
              color:
                  isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: AppTypography.sectionMarker.copyWith(
              color:
                  isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Container(
              height: 1,
              color:
                  isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(
      {required this.color, required this.label, this.border = false});
  final Color color;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.borderXs,
                border: border
                    ? Border.all(
                        color: isDark
                            ? AppColors.blackLightest
                            : AppColors.lightBorder,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.monoSmall.copyWith(
              color:
                  isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FontShowcaseItem extends StatelessWidget {
  const _FontShowcaseItem({
    required this.title,
    required this.description,
    required this.sampleText,
    required this.style,
  });

  final String title;
  final String description;
  final String sampleText;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleLarge.copyWith(color: isDark ? AppColors.white : AppColors.black)),
        const SizedBox(height: AppSpacing.xs),
        Text(description, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary)),
        const SizedBox(height: AppSpacing.md),
        Text(sampleText, style: style),
      ],
    );
  }
}

class _TypeLabel extends StatelessWidget {
  const _TypeLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(text,
          style: AppTypography.monoSmall.copyWith(color: color)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TRANSITION DEMO HELPERS
// ═══════════════════════════════════════════════════════════════

class _TransitionButton extends StatelessWidget {
  const _TransitionButton({
    required this.name,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: mutedColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          AppTypography.titleMedium.copyWith(color: textColor)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(description,
                      style:
                          AppTypography.bodySmall.copyWith(color: mutedColor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: mutedColor, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Full-screen landing page shown after a transition.
/// Tap anywhere or press the button to go back.
class _TransitionDemoPage extends StatelessWidget {
  const _TransitionDemoPage({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final faintColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Back arrow
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_back, color: textColor, size: 20),
                  ),
                ),

                const Spacer(),

                // Transition name
                Text(
                  'TRANSITION',
                  style:
                      AppTypography.sectionMarker.copyWith(color: faintColor),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  name.toUpperCase(),
                  style:
                      AppTypography.displayMassive.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'You just experienced the $name transition.\nTap anywhere or press back to return.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: mutedColor,
                    height: 1.8,
                  ),
                ),

                const Spacer(),

                // Return button
                Center(
                  child: AppButton(
                    label: 'Go Back',
                    icon: Icons.arrow_back,
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: AppSpacing.gigantic),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
