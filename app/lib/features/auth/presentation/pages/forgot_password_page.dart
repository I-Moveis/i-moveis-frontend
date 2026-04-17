import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// Forgot password page — Brutalist Elegance x Japanese Creative Web
///
/// Same visual language: WaveBackground sunset, warm pastels,
/// glass input, section marker "DATA-SYSTEM // RECOVERY",
/// index "03", gradient button.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  final ValueNotifier<bool> _emailFocusedNotifier = ValueNotifier(false);
  bool _isLoading = false;
  bool _linkSent = false;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;
  late final Animation<double> _formSlide;
  late final Animation<double> _formFade;

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

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    _headerScale = Tween<double>(begin: 0.8, end: 1).animate(
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

    _emailFocus.addListener(() {
      _emailFocusedNotifier.value = _emailFocus.hasFocus;
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
    _emailFocus.dispose();
    _emailFocusedNotifier.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleSendLink() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _linkSent = true;
      });
    });
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
                              const SizedBox(height: AppSpacing.gigantic),
                              _buildHeader(isDark),
                              const SizedBox(height: AppSpacing.gigantic),
                              _buildForm(isDark),
                              const SizedBox(height: AppSpacing.gigantic),
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
              color: BrutalistPalette.glassBg(isDark),
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: BrutalistPalette.glassBorderColor(isDark),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: BrutalistPalette.muted(isDark),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'VOLTAR',
                  style: AppTypography.labelSmall.copyWith(
                    color: BrutalistPalette.muted(isDark),
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
  //  HEADER — 03, RECUPERAR, SENHA, section marker
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
              builder: (context, child) {
                final glow = _pulseController.value;
                return Text(
                  '03',
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
              text: 'RECUPERAR',
              style: AppTypography.displayBrand.copyWith(
                color: titleColor,
              ),
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 900),
            ),
            const SizedBox(height: AppSpacing.xxs),
            RevealText(
              text: 'SENHA',
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
                    'DATA-SYSTEM // RECOVERY',
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
            const SizedBox(height: AppSpacing.xxl),
            FadeSlideIn(
              delay: const Duration(milliseconds: 1300),
              offsetDistance: 10,
              child: Text(
                'Informe seu email e enviaremos\num link para redefinir sua senha.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: BrutalistPalette.muted(isDark),
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FORM — email input + send button + success state
  // ═══════════════════════════════════════════════════════════════
  Widget _buildForm(bool isDark) {
    return Opacity(
      opacity: _formFade.value,
      child: Transform.translate(
        offset: Offset(0, _formSlide.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_linkSent) ...[
              _buildSuccessMessage(isDark),
            ] else ...[
              // Email input
              ValueListenableBuilder<bool>(
                valueListenable: _emailFocusedNotifier,
                builder: (context, isFocused, _) =>
                    _buildEmailField(isFocused, isDark),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Send button
              FadeSlideIn(
                delay: const Duration(milliseconds: 1500),
                offsetDistance: 20,
                child: _buildSendButton(isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isFocused, bool isDark) {
    final focusedBorder = BrutalistPalette.accentOrange(isDark).withValues(
      alpha: isDark ? 0.6 : 0.5,
    );
    final restBorder = BrutalistPalette.cardBorder(isDark);

    final fieldBg = isFocused
        ? (isDark
            ? AppColors.blackLight.withValues(alpha: 0.8)
            : AppColors.white.withValues(alpha: 0.95))
        : BrutalistPalette.surfaceBg(isDark);

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
      delay: const Duration(milliseconds: 1400),
      offsetDistance: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'EMAIL',
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
                        color:
                            BrutalistPalette.accentOrange(isDark).withValues(
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
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              style: AppTypography.monoInput.copyWith(
                color: textColor,
              ),
              cursorColor: cursorColor,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: 'seu@email.com',
                hintStyle: AppTypography.monoInput.copyWith(
                  color: hintColor,
                ),
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                  size: 18,
                  color: iconColor,
                ),
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

  Widget _buildSendButton(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;
        const pi2 = 3.14159265 * 2;

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

        final buttonTextColor = BrutalistPalette.title(!isDark);
        final loadingColor = BrutalistPalette.title(!isDark).withValues(
          alpha: isDark ? 0.8 : 0.9,
        );
        final glowColor = isDark
            ? BrutalistPalette.warmOrange.withValues(alpha: 0.2)
            : BrutalistPalette.deepOrange.withValues(alpha: 0.15);

        return GestureDetector(
          onTap: _isLoading ? null : _handleSendLink,
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
                  (0.5 + _sinApprox(shimmerValue * pi2) * 0.2)
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
                              'ENVIAR LINK',
                              style: AppTypography.buttonLabel.copyWith(
                                color: buttonTextColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.send_rounded,
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

  /// Simple sin approximation to avoid importing dart:math
  double _sinApprox(double x) {
    var normalized = x % (3.14159265 * 2);
    if (normalized > 3.14159265) normalized -= 3.14159265 * 2;
    final abs = normalized < 0 ? -normalized : normalized;
    final sign = normalized < 0 ? -1.0 : 1.0;
    return sign *
        (16 * abs * (3.14159265 - abs)) /
        (49.348 - 4 * abs * (3.14159265 - abs));
  }

  // ═══════════════════════════════════════════════════════════════
  //  SUCCESS MESSAGE — shown after link is sent
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSuccessMessage(bool isDark) {
    final accentColor = BrutalistPalette.accentAmber(isDark);
    const successColor = AppColors.success;
    final mutedColor = BrutalistPalette.muted(isDark);

    return FadeSlideIn(
      offsetDistance: 20,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successColor.withValues(alpha: 0.1),
              border: Border.all(
                color: successColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 32,
              color: successColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'LINK ENVIADO',
            style: AppTypography.labelAction.copyWith(
              color: accentColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Verifique sua caixa de entrada\ne clique no link para redefinir.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: mutedColor,
              height: 1.8,
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: BrutalistPalette.glassBg(isDark),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: BrutalistPalette.glassBorderColor(isDark),
                ),
              ),
              child: Center(
                child: Text(
                  'VOLTAR AO LOGIN',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.whiteDim
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
