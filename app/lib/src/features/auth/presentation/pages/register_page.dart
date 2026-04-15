import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/design_system/design_system.dart';

/// Register page — Brutalist Elegance x Japanese Creative Web
///
/// Same visual language as login: WaveBackground sunset,
/// warm pastel accents, glass inputs, gradient shimmer button,
/// section marker "DATA-SYSTEM // REGISTRO".
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isOwner = false;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final ValueNotifier<bool> _nameFocusedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _emailFocusedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _phoneFocusedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _passwordFocusedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _confirmPasswordFocusedNotifier =
      ValueNotifier(false);

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;
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

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    _headerScale = Tween<double>(begin: 0.8, end: 1.0).animate(
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

    _nameFocus.addListener(
      () => _nameFocusedNotifier.value = _nameFocus.hasFocus,
    );
    _emailFocus.addListener(
      () => _emailFocusedNotifier.value = _emailFocus.hasFocus,
    );
    _phoneFocus.addListener(
      () => _phoneFocusedNotifier.value = _phoneFocus.hasFocus,
    );
    _passwordFocus.addListener(
      () => _passwordFocusedNotifier.value = _passwordFocus.hasFocus,
    );
    _confirmPasswordFocus.addListener(
      () => _confirmPasswordFocusedNotifier.value =
          _confirmPasswordFocus.hasFocus,
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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nameFocusedNotifier.dispose();
    _emailFocusedNotifier.dispose();
    _phoneFocusedNotifier.dispose();
    _passwordFocusedNotifier.dispose();
    _confirmPasswordFocusedNotifier.dispose();
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

  void _handleRegister() {
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
                              const SizedBox(height: AppSpacing.lg),
                              _buildBackButton(isDark),
                              const SizedBox(height: AppSpacing.xl),
                              _buildHeader(isDark),
                              const SizedBox(height: AppSpacing.huge),
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
  //  BACK BUTTON — glass style
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBackButton(bool isDark) {
    return Opacity(
      opacity: _headerFade.value,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => context.pop(),
          child: AnimatedContainer(
            duration: AppDurations.normal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.glass : const Color(0x08000000),
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorder
                    : const Color(0x14000000),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.whiteMuted
                      : AppColors.lightTextTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'VOLTAR',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.whiteMuted
                        : AppColors.lightTextTertiary,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HEADER — 02, CRIAR, CONTA, section marker
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    final accentPeach = isDark ? _warmPeach : _deepOrange;
    final accentAmber = isDark ? _warmAmber : _deepAmber;
    final titleColor = isDark ? AppColors.white : AppColors.black;

    return Opacity(
      opacity: _headerFade.value,
      child: Transform.scale(
        scale: _headerScale.value,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = _pulseController.value;
                return Text(
                  '02',
                  style: AppTypography.monoDisplay.copyWith(
                    color: isDark
                        ? _warmYellow.withValues(
                            alpha: 0.15 + glow * 0.08,
                          )
                        : _deepAmber.withValues(
                            alpha: 0.10 + glow * 0.06,
                          ),
                    fontSize: 80,
                    letterSpacing: -4.0,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            RevealText(
              text: 'CRIAR',
              style: AppTypography.displayLarge.copyWith(
                color: titleColor,
                letterSpacing: -2.0,
              ),
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 900),
            ),
            const SizedBox(height: AppSpacing.xxs),
            RevealText(
              text: 'CONTA',
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
                    'DATA-SYSTEM // REGISTRO',
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
  //  FORM — all inputs + owner toggle + terms
  // ═══════════════════════════════════════════════════════════════
  Widget _buildForm(bool isDark) {
    return Opacity(
      opacity: _formFade.value,
      child: Transform.translate(
        offset: Offset(0, _formSlide.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            ValueListenableBuilder<bool>(
              valueListenable: _nameFocusedNotifier,
              builder: (context, isFocused, _) => _buildInputField(
                controller: _nameController,
                focusNode: _nameFocus,
                isFocused: isFocused,
                label: 'NOME COMPLETO',
                hint: 'Seu nome',
                icon: Icons.person_outline_rounded,
                delay: 0,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Email
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
                delay: 1,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Phone
            ValueListenableBuilder<bool>(
              valueListenable: _phoneFocusedNotifier,
              builder: (context, isFocused, _) => _buildInputField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                isFocused: isFocused,
                label: 'TELEFONE',
                hint: '(00) 00000-0000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                delay: 2,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Password
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
                delay: 3,
                isDark: isDark,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
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
            const SizedBox(height: AppSpacing.lg),

            // Confirm password
            ValueListenableBuilder<bool>(
              valueListenable: _confirmPasswordFocusedNotifier,
              builder: (context, isFocused, _) => _buildInputField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                isFocused: isFocused,
                label: 'CONFIRMAR SENHA',
                hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                delay: 4,
                isDark: isDark,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _obscureConfirmPassword =
                        !_obscureConfirmPassword,
                  ),
                  child: Icon(
                    _obscureConfirmPassword
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

            const SizedBox(height: AppSpacing.xl),

            // Owner toggle
            FadeSlideIn(
              delay: const Duration(milliseconds: 1900),
              offsetDistance: 15,
              child: _buildOwnerToggle(isDark),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Terms
            FadeSlideIn(
              delay: const Duration(milliseconds: 2000),
              offsetDistance: 15,
              child: _buildTermsCheckbox(isDark),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Register button
            FadeSlideIn(
              delay: const Duration(milliseconds: 2100),
              offsetDistance: 20,
              child: _buildRegisterButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INPUT FIELD — glass container with focus state
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
      delay: Duration(milliseconds: 1200 + delay * 120),
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
  //  OWNER TOGGLE — glass container
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOwnerToggle(bool isDark) {
    final bgColor = isDark
        ? AppColors.blackLight.withValues(alpha: 0.4)
        : AppColors.white.withValues(alpha: 0.6);
    final borderColor = isDark
        ? (_isOwner
            ? _warmOrange.withValues(alpha: 0.4)
            : AppColors.blackLightest)
        : (_isOwner
            ? _deepOrange.withValues(alpha: 0.3)
            : AppColors.lightBorder);

    return AnimatedContainer(
      duration: AppDurations.medium,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOU PROPRIETÁRIO',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.whiteDim
                        : AppColors.lightTextPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ative para anunciar imóveis',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.whiteMuted
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOwner,
            onChanged: (v) => setState(() => _isOwner = v),
            activeThumbColor: isDark ? _warmAmber : _deepAmber,
            activeTrackColor: isDark
                ? _warmBrown.withValues(alpha: 0.4)
                : _deepOrange.withValues(alpha: 0.2),
            inactiveThumbColor: isDark
                ? AppColors.whiteMuted
                : AppColors.lightTextTertiary,
            inactiveTrackColor: isDark
                ? AppColors.blackLightest
                : AppColors.lightBorder,
            trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TERMS CHECKBOX — minimal style
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTermsCheckbox(bool isDark) {
    final accentColor = isDark ? _warmPeach : _deepOrange;

    return GestureDetector(
      onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppDurations.normal,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _acceptedTerms
                  ? accentColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: AppRadius.borderXs,
              border: Border.all(
                color: _acceptedTerms
                    ? accentColor
                    : (isDark
                        ? AppColors.blackLightest
                        : AppColors.lightBorder),
                width: 1.5,
              ),
            ),
            child: _acceptedTerms
                ? Icon(Icons.check_rounded, size: 14, color: accentColor)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'ACEITO OS TERMOS DE USO',
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.whiteMuted
                  : AppColors.lightTextTertiary,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  REGISTER BUTTON — gradient shimmer
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRegisterButton(bool isDark) {
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
          onTap: _isLoading ? null : _handleRegister,
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
                              'CRIAR CONTA',
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
  //  FOOTER — login link, version
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
                'JÁ TEM CONTA?',
                style: AppTypography.labelSmall.copyWith(
                  color: mutedColor,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  'ENTRAR',
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
