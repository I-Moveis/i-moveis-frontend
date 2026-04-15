import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/design_system/design_system.dart';

/// Login page — Brutalist Elegance x Japanese Creative Web
///
/// Ported from the reference design: Wave background (sunset),
/// Space Mono index, Syne display, warm pastel accents,
/// glass morphism inputs, gradient shimmer button.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
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

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _formSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
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

  // ═══════════════════════════════════════════════════════════════
  //  WARM PASTEL ACCENT PALETTE
  // ═══════════════════════════════════════════════════════════════
  static const _warmYellow = AppColors.pastelYellow;
  static const _warmPeach = AppColors.pastelPeach;
  static const _warmOrange = Color(0xFFFFB878);
  static const _warmBrown = Color(0xFFD4A574);
  static const _warmAmber = Color(0xFFE8C47C);

  static const _deepOrange = Color(0xFFCC8844);
  static const _deepBrown = Color(0xFFAA7744);
  static const _deepAmber = Color(0xFFBB8833);

  void _handleLogin() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: WaveBackground(
              colorScheme: WaveColorScheme.sunset,
              speed: 0.4,
              amplitude: 0.8,
              waveCount: 7,
              adaptToTheme: true,
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
                              _buildForm(isDark),
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

  // ═══════════════════════════════════════════════════════════════
  //  HEADER — 01, i-móveis, ALUGUEL, data-system marker
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    final accentPeach = isDark ? _warmPeach : _deepOrange;
    final accentAmber = isDark ? _warmAmber : _deepAmber;
    final titleColor = isDark ? AppColors.white : AppColors.black;

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
                  style: AppTypography.monoDisplay.copyWith(
                    color: isDark
                        ? _warmYellow.withValues(alpha: 0.15 + glow * 0.08)
                        : _deepAmber.withValues(alpha: 0.10 + glow * 0.06),
                    fontSize: 80,
                    letterSpacing: -4.0,
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xs),

            RevealText(
              text: 'i-móveis',
              style: AppTypography.displayLarge.copyWith(
                color: titleColor,
                letterSpacing: -2.0,
              ),
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 900),
            ),

            const SizedBox(height: AppSpacing.xxs),

            RevealText(
              text: 'ALUGUEL',
              style: AppTypography.displayMedium.copyWith(
                color: accentPeach,
                letterSpacing: 8.0,
                fontWeight: FontWeight.w400,
              ),
              delay: const Duration(milliseconds: 900),
              duration: const Duration(milliseconds: 800),
            ),

            const SizedBox(height: AppSpacing.lg),

            FadeSlideIn(
              delay: const Duration(milliseconds: 1200),
              duration: const Duration(milliseconds: 600),
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
                      letterSpacing: 4.0,
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

  // ═══════════════════════════════════════════════════════════════
  //  FORM — inputs, forgot password, login button, socials
  // ═══════════════════════════════════════════════════════════════
  Widget _buildForm(bool isDark) {
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
                delay: 0,
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
                    color: isDark
                        ? AppColors.whiteMuted
                        : AppColors.lightTextTertiary,
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
                      color: isDark
                          ? _warmPeach.withValues(alpha: 0.7)
                          : _deepOrange.withValues(alpha: 0.8),
                      letterSpacing: 2.0,
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
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildSocialButton(
                      'APPLE',
                      Icons.apple_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INPUT FIELD — glass container, theme-adaptive colors
  // ═══════════════════════════════════════════════════════════════
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
    final focusedBorder = isDark
        ? _warmOrange.withValues(alpha: 0.6)
        : _deepOrange.withValues(alpha: 0.5);
    final restBorder = isDark ? AppColors.blackLightest : AppColors.lightBorder;

    final fieldBg = isDark
        ? (isFocused
            ? AppColors.blackLight.withValues(alpha: 0.8)
            : AppColors.blackLight.withValues(alpha: 0.4))
        : (isFocused
            ? AppColors.white.withValues(alpha: 0.9)
            : AppColors.white.withValues(alpha: 0.6));

    final labelColor = isDark
        ? (isFocused ? _warmPeach : AppColors.whiteMuted)
        : (isFocused ? _deepOrange : AppColors.lightTextTertiary);

    final textColor = isDark ? AppColors.white : AppColors.black;
    final hintColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
    final iconColor = isDark
        ? (isFocused ? _warmPeach : AppColors.whiteMuted)
        : (isFocused ? _deepOrange : AppColors.lightTextTertiary);
    final cursorColor = isDark ? _warmOrange : _deepOrange;

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
                style: AppTypography.labelMedium.copyWith(
                  color: labelColor,
                  letterSpacing: 3.0,
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
                        color:
                            (isDark ? _warmOrange : _deepOrange).withValues(
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
              boxShadow: isFocused && !isDark
                  ? [
                      BoxShadow(
                        color: _deepOrange.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.mono.copyWith(
                color: textColor,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              cursorColor: cursorColor,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.mono.copyWith(
                  color: hintColor,
                  fontSize: 14,
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

  // ═══════════════════════════════════════════════════════════════
  //  LOGIN BUTTON — gradient shimmer, theme-adaptive
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoginButton(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;

        final gradientColors = isDark
            ? [
                _warmBrown.withValues(alpha: 0.9),
                _warmOrange.withValues(alpha: 0.85),
                _warmYellow.withValues(alpha: 0.8),
              ]
            : [_deepBrown, _deepOrange, _deepAmber];

        final buttonTextColor = isDark ? AppColors.black : AppColors.white;
        final loadingColor = isDark
            ? AppColors.black.withValues(alpha: 0.8)
            : AppColors.white.withValues(alpha: 0.9);
        final glowColor = isDark
            ? _warmOrange.withValues(alpha: 0.2)
            : _deepOrange.withValues(alpha: 0.15);

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
                              style: AppTypography.labelLarge.copyWith(
                                color: buttonTextColor,
                                letterSpacing: 3.0,
                                fontWeight: FontWeight.w700,
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

  // ═══════════════════════════════════════════════════════════════
  //  DIVIDER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDivider(bool isDark) {
    final lineColor = isDark
        ? AppColors.blackLightest.withValues(alpha: 0.5)
        : AppColors.lightBorder.withValues(alpha: 0.6);
    final textColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;

    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'OU',
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              letterSpacing: 3.0,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SOCIAL BUTTONS — glass morphism, theme-adaptive
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSocialButton(String label, IconData icon, bool isDark) {
    final bgColor = isDark ? AppColors.glass : const Color(0x08000000);
    final borderColor = isDark
        ? AppColors.blackLightest.withValues(alpha: 0.6)
        : AppColors.lightBorder;
    final contentColor =
        isDark ? AppColors.whiteDim : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/home'),
        borderRadius: AppRadius.borderSm,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: contentColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: contentColor,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FOOTER — register link, version
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFooter(bool isDark) {
    final mutedColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
    final accentColor = isDark ? _warmYellow : _deepAmber;

    return Opacity(
      opacity: _footerFade.value,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NÃO TEM CONTA?',
                style: AppTypography.labelSmall.copyWith(
                  color: mutedColor,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  'CRIAR CONTA',
                  style: AppTypography.labelSmall.copyWith(
                    color: accentColor,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
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
                style: AppTypography.monoSmall.copyWith(
                  color: mutedColor.withValues(
                    alpha: 0.3 + _pulseController.value * 0.15,
                  ),
                  letterSpacing: 2.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
