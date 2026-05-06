import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/demo_role.dart';
import '../bloc/social_provider.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

/// Login page ÔÇö Brutalist Elegance x Japanese Creative Web
///
/// Ported from the reference design: Wave background (sunset),
/// Space Mono index, Syne display, warm pastel accents,
/// glass morphism inputs, gradient shimmer button.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  SocialProvider? _loadingSocial; // null = none, google/apple = loading
  final ValueNotifier<bool> _emailFocusedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _passwordFocusedNotifier = ValueNotifier(false);

  // Animation controllers
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  // Entrance animations
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _formSlide;
  late final Animation<double> _formFade;
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

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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

    _formSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1, curve: Curves.easeOut),
      ),
    );

    _emailFocus.addListener(() {
      _emailFocusedNotifier.value = _emailFocus.hasFocus;
    });
    _passwordFocus.addListener(() {
      _passwordFocusedNotifier.value = _passwordFocus.hasFocus;
    });

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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailFocusedNotifier.dispose();
    _passwordFocusedNotifier.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).login(
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (user) {
          setState(() => _loadingSocial = null);
          final String destination;
          if (user.needsRoleOnboarding) {
            destination = '/onboarding/role';
          } else if (user.isAdmin) {
            destination = '/admin';
          } else if (user.isOwner) {
            destination = '/profile/my-properties';
          } else {
            destination = '/home';
          }
          context.go(destination);
        },
        unauthenticated: () {
          setState(() {
            _isLoading = false;
            _loadingSocial = null;
          });
        },
        error: (message) {
          setState(() => _loadingSocial = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $message')),
          );
        },
      );
    });

    final state = ref.watch(authNotifierProvider);

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
          resizeToAvoidBottomInset: true,
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
                              const SizedBox(height: AppSpacing.xl),
                              _buildHeader(isDark),
                              const SizedBox(height: AppSpacing.gigantic),
                              _buildForm(isDark, state),
                              const SizedBox(height: AppSpacing.xxxl),
                              _buildFooter(isDark),
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

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  HEADER ÔÇö 01, i-m├│veis, ALUGUEL, data-system marker
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildHeader(bool isDark) {
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
                  '01',
                  style: AppTypography.monoHero.copyWith(
                    color: isDark
                        ? BrutalistPalette.warmYellow.withValues(alpha: 0.15 + glow * 0.08)
                        : BrutalistPalette.deepAmber.withValues(alpha: 0.10 + glow * 0.06),
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

            const SizedBox(height: AppSpacing.lg),

            FadeSlideIn(
              delay: const Duration(milliseconds: 1200),
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
                    'DATA-SYSTEM // LOGIN',
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
  //  FORM ÔÇö inputs, forgot password, login button, socials
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildForm(bool isDark, AuthState state) {
    // Derivado do state do Bloc ÔÇö garante que o bot├úo sai de loading
    // quando a request falha (state=error) ou sucede (state=authenticated).
    _isLoading = state is Loading;

    return Opacity(
      opacity: _formFade.value,
      child: Transform.translate(
        offset: Offset(0, _formSlide.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _emailFocusedNotifier,
              builder: (context, isFocused, _) => _buildInputField(
                controller: _emailController,
                focusNode: _emailFocus,
                isFocused: isFocused,
                label: 'EMAIL',
                hint: 'seu@email.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            ValueListenableBuilder<bool>(
              valueListenable: _passwordFocusedNotifier,
              builder: (context, isFocused, _) => _buildInputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                isFocused: isFocused,
                label: 'SENHA',
                hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                delay: 1,
                isDark: isDark,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                    color: BrutalistPalette.muted(isDark),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Align(
              alignment: Alignment.centerRight,
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 1600),
                offsetDistance: 10,
                child: GestureDetector(
                  onTap: () => context.push('/forgot-password'),
                  child: Text(
                    'ESQUECI MINHA SENHA',
                    style: AppTypography.labelSmall.copyWith(
                      color: BrutalistPalette.accentPeach(isDark).withValues(
                          alpha: isDark ? 0.7 : 0.8),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            FadeSlideIn(
              delay: const Duration(milliseconds: 1400),
              offsetDistance: 20,
              child: _buildLoginButton(isDark),
            ),

            const SizedBox(height: AppSpacing.xl),

            FadeSlideIn(
              delay: const Duration(milliseconds: 1600),
              offsetDistance: 10,
              child: _buildDivider(isDark),
            ),

            const SizedBox(height: AppSpacing.xl),

            FadeSlideIn(
              delay: const Duration(milliseconds: 1800),
              offsetDistance: 20,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      'GOOGLE',
                      Icons.g_mobiledata_rounded,
                      isDark,
                      SocialProvider.google,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildSocialButton(
                      'APPLE',
                      Icons.apple_rounded,
                      isDark,
                      SocialProvider.apple,
                    ),
                  ),
                ],
              ),
            ),

            if (kDebugMode && kUseMockAuth) ...[
              const SizedBox(height: AppSpacing.xxl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 2000),
                offsetDistance: 10,
                child: _buildDemoRoleSection(isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  INPUT FIELD ÔÇö glass container, theme-adaptive colors
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    int delay = 0,
    Widget? suffixIcon,
  }) {
    final focusedBorder = BrutalistPalette.accentOrange(isDark)
        .withValues(alpha: isDark ? 0.6 : 0.5);
    final restBorder = isDark ? AppColors.blackLightest : AppColors.lightBorder;

    final fieldBg = isDark
        ? (isFocused ? AppColors.blackLighter : AppColors.blackLight)
        : (isFocused ? AppColors.white : AppColors.white);

    final labelColor = isFocused
        ? BrutalistPalette.accentPeach(isDark)
        : BrutalistPalette.muted(isDark);

    final textColor = BrutalistPalette.title(isDark);
    final hintColor = BrutalistPalette.faint(isDark);
    final iconColor = isFocused
        ? BrutalistPalette.accentPeach(isDark)
        : BrutalistPalette.muted(isDark);
    final cursorColor = BrutalistPalette.accentOrange(isDark);

    return FadeSlideIn(
      delay: Duration(milliseconds: 1200 + delay * 150),
      offsetDistance: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.inputLabel.copyWith(
                  color: labelColor,
                ),
              ),
              if (isFocused) ...[
                const SizedBox(width: AppSpacing.sm),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BrutalistPalette.accentOrange(isDark)
                            .withValues(
                          alpha: 0.5 + _pulseController.value * 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          AnimatedContainer(
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: isFocused ? focusedBorder : restBorder,
                width: isFocused ? 1.5 : 1.0,
              ),
              boxShadow: isFocused
                  ? BrutalistPalette.inputFocusShadow(isDark)
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.monoInput.copyWith(
                color: textColor,
              ),
              cursorColor: cursorColor,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.monoInput.copyWith(
                  color: hintColor,
                ),
                prefixIcon: Icon(icon, size: 18, color: iconColor),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  LOGIN BUTTON ÔÇö gradient shimmer, theme-adaptive
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildLoginButton(bool isDark) {
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
        final loadingColor = isDark
            ? AppColors.black.withValues(alpha: 0.8)
            : AppColors.white.withValues(alpha: 0.9);
        final glowColor = BrutalistPalette.accentOrange(isDark)
            .withValues(alpha: isDark ? 0.2 : 0.15);

        return GestureDetector(
          onTap: _isLoading ? null : _handleLogin,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            height: 56,
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
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: loadingColor,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ENTRAR',
                              style: AppTypography.buttonLabel.copyWith(
                                color: buttonTextColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color:
                                  buttonTextColor.withValues(alpha: 0.7),
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

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  DIVIDER
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildDivider(bool isDark) {
    final lineColor = isDark
        ? AppColors.blackLightest.withValues(alpha: 0.5)
        : AppColors.lightBorder.withValues(alpha: 0.6);
    final textColor = BrutalistPalette.faint(isDark);

    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'OU',
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  SOCIAL BUTTONS ÔÇö glass morphism, theme-adaptive
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildSocialButton(
    String label,
    IconData icon,
    bool isDark,
    SocialProvider provider,
  ) {
    final isLoadingThis = _loadingSocial == provider;
    final isLoadingOther = _loadingSocial != null && _loadingSocial != provider;

    final bgColor = isDark ? AppColors.blackLight : AppColors.lightSurface;
    final borderColor =
        isDark ? AppColors.blackLightest : AppColors.lightBorder;
    final contentColor = isLoadingOther
        ? (isDark ? AppColors.whiteDim : AppColors.lightTextSecondary)
            .withValues(alpha: 0.4)
        : (isDark ? AppColors.whiteDim : AppColors.lightTextSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loadingSocial != null
            ? null
            : () {
                if (provider == SocialProvider.apple) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login Apple em breve')),
                  );
                  return;
                }
                setState(() => _loadingSocial = provider);
                ref
                    .read(authNotifierProvider.notifier)
                    .socialLogin(provider);
              },
        borderRadius: AppRadius.borderSm,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor.withValues(
              alpha: isLoadingOther ? 0.5 : 1.0,
            ),
            borderRadius: AppRadius.borderSm,
            border: Border.all(
              color: isLoadingOther ? borderColor.withValues(alpha: 0.3) : borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoadingThis)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(contentColor),
                  ),
                )
              else
                Icon(icon, size: 20, color: contentColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  FOOTER ÔÇö register link, version
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildFooter(bool isDark) {
    final mutedColor = BrutalistPalette.faint(isDark);
    final accentColor = isDark ? BrutalistPalette.warmYellow : BrutalistPalette.deepAmber;

    return Opacity(
      opacity: _footerFade.value,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'N├âO TEM CONTA?',
                style: AppTypography.labelSmall.copyWith(
                  color: mutedColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  'CRIAR CONTA',
                  style: AppTypography.labelSmall.copyWith(
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

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
        ],
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  DEMO ROLES ÔÇö dev-only quick login buttons
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildDemoRoleSection(bool isDark) {
    final mutedColor = isDark
        ? AppColors.whiteDim.withValues(alpha: 0.5)
        : AppColors.lightTextSecondary.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DEV // ENTRAR COMO',
          style: AppTypography.monoSmallWide.copyWith(color: mutedColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildDemoRoleButton(
                'CLIENTE',
                Icons.person_outline_rounded,
                isDark,
                DemoRole.client,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildDemoRoleButton(
                'PROPRIET├üRIO',
                Icons.home_work_outlined,
                isDark,
                DemoRole.owner,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildDemoRoleButton(
                'ADMIN',
                Icons.shield_outlined,
                isDark,
                DemoRole.admin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemoRoleButton(
    String label,
    IconData icon,
    bool isDark,
    DemoRole role,
  ) {
    final bgColor = isDark ? AppColors.blackLight : AppColors.lightSurface;
    final borderColor =
        isDark ? AppColors.blackLightest : AppColors.lightBorder;
    final contentColor =
        isDark ? AppColors.whiteDim : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading || _loadingSocial != null
            ? null
            : () => ref
                .read(authNotifierProvider.notifier)
                .demoLogin(role),
        borderRadius: AppRadius.borderSm,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: contentColor, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.monoSmallWide.copyWith(
                  color: contentColor,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
