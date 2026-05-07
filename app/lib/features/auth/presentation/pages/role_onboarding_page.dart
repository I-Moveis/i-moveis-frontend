import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../design_system/design_system.dart';

/// Tela intersticial disparada após a primeira sessão de um usuário social
/// (Google). O JIT do backend criou o registro com role default `TENANT`;
/// aqui ele confirma/troca para `LANDLORD` antes de entrar no app.
class RoleOnboardingPage extends ConsumerStatefulWidget {
  const RoleOnboardingPage({super.key});

  @override
  ConsumerState<RoleOnboardingPage> createState() => _RoleOnboardingPageState();
}

class _RoleOnboardingPageState extends ConsumerState<RoleOnboardingPage>
    with TickerProviderStateMixin {
  String? _submittingRole;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;
  late final Animation<double> _cardsSlide;
  late final Animation<double> _cardsFade;

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

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _headerScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _cardsSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
      ),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
        _shimmerController.repeat();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _selectRole(String role) async {
    if (_submittingRole != null) return;
    setState(() => _submittingRole = role);

    final dio = ref.read(dioProvider);
    try {
      await dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: {'role': role},
      );
      if (!mounted) return;
      // Landlord aterrissa em /home (dashboard); /my-properties fica para o
      // acesso explícito via bottom nav.
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submittingRole = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar perfil: ${e.message ?? 'tente novamente'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: WaveBackground(
              speed: 0.4,
              amplitude: 0.8,
              waveCount: 7,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              _buildHeader(isDark),
                              const SizedBox(height: AppSpacing.gigantic),
                              _buildRoleCards(isDark),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HEADER — index, título, section marker
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    final accentPeach = BrutalistPalette.accentPeach(isDark);
    final accentAmber = BrutalistPalette.accentAmber(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    return Opacity(
      opacity: _headerFade.value,
      child: Transform.scale(
        scale: _headerScale.value,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final glow = _pulseController.value;
                return Text(
                  '03',
                  style: AppTypography.monoHero.copyWith(
                    color: isDark
                        ? BrutalistPalette.warmYellow
                            .withValues(alpha: 0.15 + glow * 0.08)
                        : BrutalistPalette.deepAmber
                            .withValues(alpha: 0.10 + glow * 0.06),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            RevealText(
              text: 'QUEM',
              style: AppTypography.displayBrand.copyWith(color: titleColor),
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 900),
            ),
            const SizedBox(height: AppSpacing.xxs),
            RevealText(
              text: 'É VOCÊ?',
              style: AppTypography.displaySubtitle.copyWith(color: accentPeach),
              delay: const Duration(milliseconds: 800),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 1100),
              offsetDistance: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 1,
                    color: accentAmber.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'PERFIL',
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
            ),
            const SizedBox(height: AppSpacing.xl),
            FadeSlideIn(
              delay: const Duration(milliseconds: 1300),
              offsetDistance: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Text(
                  'Escolha como você usa o i-Móveis.\nVocê pode mudar depois no seu perfil.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: BrutalistPalette.muted(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CARDS — TENANT + LANDLORD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRoleCards(bool isDark) {
    return Opacity(
      opacity: _cardsFade.value,
      child: Transform.translate(
        offset: Offset(0, _cardsSlide.value),
        child: Column(
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 1500),
              offsetDistance: 20,
              child: _buildRoleCard(
                isDark: isDark,
                role: 'TENANT',
                label: 'INQUILINO',
                description: 'Quero encontrar e alugar imóveis.',
                icon: Icons.person_outline_rounded,
                gradientColors: isDark
                    ? [
                        BrutalistPalette.warmBrown.withValues(alpha: 0.9),
                        BrutalistPalette.warmOrange.withValues(alpha: 0.85),
                        BrutalistPalette.warmYellow.withValues(alpha: 0.8),
                      ]
                    : [
                        BrutalistPalette.deepBrown,
                        BrutalistPalette.deepOrange,
                        BrutalistPalette.deepAmber,
                      ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 1700),
              offsetDistance: 20,
              child: _buildRoleCard(
                isDark: isDark,
                role: 'LANDLORD',
                label: 'PROPRIETÁRIO',
                description: 'Quero anunciar meus imóveis.',
                icon: Icons.home_work_outlined,
                gradientColors: isDark
                    ? [
                        BrutalistPalette.warmYellow.withValues(alpha: 0.85),
                        BrutalistPalette.warmOrange.withValues(alpha: 0.85),
                        BrutalistPalette.warmBrown.withValues(alpha: 0.9),
                      ]
                    : [
                        BrutalistPalette.deepAmber,
                        BrutalistPalette.deepOrange,
                        BrutalistPalette.deepBrown,
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required bool isDark,
    required String role,
    required String label,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final isSubmittingThis = _submittingRole == role;
    final isDisabled = _submittingRole != null && !isSubmittingThis;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerValue = _shimmerController.value;
        final glowColor = BrutalistPalette.accentOrange(isDark)
            .withValues(alpha: isDark ? 0.2 : 0.15);
        final contentColor = isDark ? AppColors.black : AppColors.white;

        return Opacity(
          opacity: isDisabled ? 0.4 : 1,
          child: MouseRegion(
            cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _selectRole(role),
              child: AnimatedContainer(
              duration: AppDurations.normal,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                  stops: [
                    0.0,
                    (0.5 + sin(shimmerValue * 2 * pi) * 0.2).clamp(0.0, 1.0),
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
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: contentColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderXs,
                        ),
                        child: Icon(icon, size: 28, color: contentColor),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: AppTypography.buttonLabel.copyWith(
                                color: contentColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              description,
                              style: AppTypography.bodySmall.copyWith(
                                color: contentColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      if (isSubmittingThis)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: contentColor.withValues(alpha: 0.9),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 22,
                          color: contentColor.withValues(alpha: 0.7),
                        ),
                    ],
                  ),
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
