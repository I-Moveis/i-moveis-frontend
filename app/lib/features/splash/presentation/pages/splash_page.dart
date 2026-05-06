import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../auth/presentation/providers/auth_status_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

/// Splash screen ÔÇö Brutalist Elegance x Japanese Creative Web
///
/// Cinematic entrance: WaveBackground sunset, pulsing index "00",
/// RevealText brand name, section marker, loading indicator,
/// then CurtainTransition to onboarding.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _markerFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _markerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1, curve: Curves.easeOut),
      ),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
        _loadingController.repeat();
        _navigateAfterDelay();
      }
    });

    // Fire the session check in parallel with the splash animation so that
    // by the time the curtain drops, authStatus is already resolved.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authNotifierProvider.notifier).checkSession();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      Navigator.of(context).pushReplacement(
        CurtainTransition(
          page: const _PostSplashRouter(),
          direction: CurtainDirection.bottom,
          curtainColor: BrutalistPalette.warmScrimBg(isDark),
        ),
      );
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: WaveBackground(
              speed: 0.3,
              amplitude: 0.6,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        _buildLogo(isDark),
                        const SizedBox(height: AppSpacing.gigantic),
                        _buildLoadingIndicator(isDark),
                        const Spacer(flex: 2),
                        _buildFooter(isDark),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  LOGO ÔÇö index 00 + brand name + subtitle + marker
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildLogo(bool isDark) {
    final accentPeach = BrutalistPalette.accentPeach(isDark);
    final accentAmber = BrutalistPalette.accentAmber(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    return Opacity(
      opacity: _logoFade.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: Column(
          children: [
            // System index number
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = _pulseController.value;
                return Text(
                  '00',
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

            RevealText(
              text: 'i-m├│veis',
              style: AppTypography.displayBrand.copyWith(
                color: titleColor,
              ),
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 900),
            ),

            const SizedBox(height: AppSpacing.xxs),

            RevealText(
              text: 'ALUGUEL',
              style: AppTypography.displaySubtitle.copyWith(
                color: accentPeach,
              ),
              delay: const Duration(milliseconds: 900),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Section marker
            Opacity(
              opacity: _markerFade.value,
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
                    'DATA-SYSTEM // INITIALIZING',
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
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  LOADING INDICATOR ÔÇö 3 pulsing dots
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildLoadingIndicator(bool isDark) {
    final dotColor = BrutalistPalette.accentAmber(isDark);

    return Opacity(
      opacity: _footerFade.value,
      child: AnimatedBuilder(
        animation: _loadingController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              // Stagger each dot by 0.2
              final delay = i * 0.2;
              final progress =
                  ((_loadingController.value - delay) % 1.0).clamp(0.0, 1.0);
              // Sin wave for smooth pulsing
              final scale = 0.5 + 0.5 * _sinWave(progress);

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor.withValues(alpha: 0.3 + scale * 0.5),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  double _sinWave(double t) {
    // Simple sine approximation for 0..1 range
    final x = t * 3.14159265 * 2;
    return (x - x * x * x / 6 + x * x * x * x * x / 120).clamp(-1.0, 1.0);
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  FOOTER ÔÇö version + system status
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildFooter(bool isDark) {
    final mutedColor = BrutalistPalette.faint(isDark);

    return Opacity(
      opacity: _footerFade.value,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Text(
            'v1.0.0 // LOADING SYSTEM',
            style: AppTypography.monoSmallWide.copyWith(
              color: mutedColor.withValues(
                alpha: 0.3 + _pulseController.value * 0.15,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Picks the first route shown after the splash, based on auth + onboarding.
///
/// Priority:
/// 1. Authenticated ÔåÆ `/home`
/// 2. Onboarding pending ÔåÆ `/onboarding`
/// 3. Onboarding completed (unauth) ÔåÆ `/login`
/// If [AuthStatus] is still `unknown` when this widget mounts, it waits for a
/// resolved status via a Riverpod listener.
class _PostSplashRouter extends ConsumerStatefulWidget {
  const _PostSplashRouter();

  @override
  ConsumerState<_PostSplashRouter> createState() => _PostSplashRouterState();
}

class _PostSplashRouterState extends ConsumerState<_PostSplashRouter> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNavigate());
  }

  void _maybeNavigate() {
    if (!mounted || _navigated) return;
    final status = ref.read(authStatusProvider);
    if (status == AuthStatus.unknown) return;

    final onboarding = ref.read(onboardingProvider);
    if (onboarding.isLoading) return;

    final destination = _resolveDestination(
      status,
      onboarding.value ?? OnboardingStatus.pending,
    );
    _navigated = true;
    context.go(destination);
  }

  String _resolveDestination(AuthStatus status, OnboardingStatus onboarding) {
    if (status == AuthStatus.authenticated) {
      final authState = ref.read(authNotifierProvider);
      return authState.maybeWhen(
        authenticated: (user) {
          if (user.needsRoleOnboarding) return '/onboarding/role';
          if (user.isAdmin) return '/admin';
          // LANDLORD e TENANT caem em /home; o builder da rota decide qual
          // página mostrar (LandlordDashboardPage vs HomePage) pelo isOwner.
          return '/home';
        },
        orElse: () => '/home',
      );
    }
    if (onboarding == OnboardingStatus.completed) return '/login';
    return '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<AuthStatus>(authStatusProvider, (_, __) => _maybeNavigate())
      ..listen<AsyncValue<OnboardingStatus>>(
        onboardingProvider,
        (_, __) => _maybeNavigate(),
      );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: BrutalistPalette.warmScrimBg(isDark),
    );
  }
}
