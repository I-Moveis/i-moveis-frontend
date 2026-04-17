import 'dart:math';
import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  1. CURTAIN TRANSITION — p5aholic-style page wipe
//     Black curtain slides in, covers the screen, then reveals the new page.
//     Two-phase animation: cover (0.0 -> 0.5) + reveal (0.5 -> 1.0).
// ═══════════════════════════════════════════════════════════════════════════════

/// Direction from which the curtain enters.
enum CurtainDirection { left, right, top, bottom }

/// A [PageRouteBuilder] that performs a two-phase curtain wipe.
///
/// Phase 1 (cover): a solid panel slides in from [direction] until it fills
/// the viewport. The old page is still visible behind it.
/// Phase 2 (reveal): the panel slides away in the same direction, uncovering
/// the new page underneath.
class CurtainTransition extends PageRouteBuilder<void> {

  CurtainTransition({
    required this.page,
    this.direction = CurtainDirection.right,
    this.curtainColor = AppColors.black,
    this.animationDuration = const Duration(milliseconds: 900),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: animationDuration,
          reverseTransitionDuration: animationDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _CurtainTransitionWidget(
              animation: animation,
              direction: direction,
              curtainColor: curtainColor,
              child: child,
            );
          },
        );
  final Widget page;
  final CurtainDirection direction;
  final Color curtainColor;
  final Duration animationDuration;
}

class _CurtainTransitionWidget extends StatelessWidget {

  const _CurtainTransitionWidget({
    required this.animation,
    required this.direction,
    required this.curtainColor,
    required this.child,
  });
  final Animation<double> animation;
  final CurtainDirection direction;
  final Color curtainColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final coverProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.5, curve: Curves.easeInQuart),
      ),
    );
    final revealProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 1, curve: Curves.easeOutQuart),
      ),
    );
    final childOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.45, 0.55, curve: Curves.easeIn),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          children: [
            Opacity(opacity: childOpacity.value, child: child),
            _buildCurtain(context, coverProgress.value, revealProgress.value),
          ],
        );
      },
    );
  }

  Widget _buildCurtain(BuildContext context, double cover, double reveal) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    double left = 0;
    double top = 0;
    double right = w;
    double bottom = h;

    switch (direction) {
      case CurtainDirection.left:
        // Enters from left edge, exits to the left.
        right = w * cover;
        left = w * reveal;
      case CurtainDirection.right:
        // Enters from right edge, exits to the right.
        left = w * (1.0 - cover);
        right = w * (1.0 - reveal) + w * reveal;
        // Simplify: curtain covers rightward then reveals rightward.
        left = w - w * cover;
        right = w;
        if (reveal > 0) {
          left = w * reveal;
        }
      case CurtainDirection.top:
        bottom = h * cover;
        top = h * reveal;
      case CurtainDirection.bottom:
        top = h - h * cover;
        bottom = h;
        if (reveal > 0) {
          top = h * reveal;
        }
    }

    final rect = Rect.fromLTRB(
      left.clamp(0.0, w),
      top.clamp(0.0, h),
      right.clamp(0.0, w),
      bottom.clamp(0.0, h),
    );

    if (rect.width <= 0 || rect.height <= 0) return const SizedBox.shrink();

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: ColoredBox(color: curtainColor),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  2. LOADING SCREEN — elegant loading / splash
//     Centered logo area, thin progress line, percentage in mono font.
//     Three styles: minimal, cosmic, wave.
// ═══════════════════════════════════════════════════════════════════════════════

/// Visual style for the [LoadingScreen].
enum LoadingStyle { minimal, cosmic, wave }

/// An elegant full-screen loading indicator.
///
/// [progress] ranges from 0.0 to 1.0. When it reaches 1.0 the screen
/// fades out automatically and calls [onComplete].
/// [logo] is an optional widget rendered at the center (icon, image, etc.).
class LoadingScreen extends StatefulWidget {

  const LoadingScreen({
    super.key,
    required this.progress,
    this.style = LoadingStyle.minimal,
    this.onComplete,
    this.logo,
    this.backgroundColor = AppColors.black,
    this.foregroundColor = AppColors.white,
  });
  final double progress;
  final LoadingStyle style;
  final VoidCallback? onComplete;
  final Widget? logo;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress >= 1.0 && !_completed) {
      _completed = true;
      _fadeController.forward().then((_) {
        widget.onComplete?.call();
      });
    } else if (widget.progress < 1.0 && _completed) {
      _completed = false;
      _fadeController.reset();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
      ),
      child: ColoredBox(
        color: widget.backgroundColor,
        child: switch (widget.style) {
          LoadingStyle.minimal => _buildMinimal(context),
          LoadingStyle.cosmic => _buildCosmic(context),
          LoadingStyle.wave => _buildWave(context),
        },
      ),
    );
  }

  // -- Minimal ---------------------------------------------------------------

  Widget _buildMinimal(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        if (widget.logo != null)
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + _pulseController.value * 0.03;
                return Transform.scale(scale: scale, child: child);
              },
              child: widget.logo,
            ),
          ),

        // Progress line and percentage near the bottom.
        Positioned(
          left: size.width * 0.2,
          right: size.width * 0.2,
          bottom: size.height * 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(widget.progress * 100).round().toString().padLeft(3, '0')}%',
                style: AppTypography.mono.copyWith(
                  color: widget.foregroundColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: widget.foregroundColor.withValues(alpha: 0.08),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widget.progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 1,
                    color: widget.foregroundColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -- Cosmic ----------------------------------------------------------------

  Widget _buildCosmic(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final glow = _pulseController.value;
        return Stack(
          children: [
            // Subtle radial gradient that pulses.
            Center(
              child: Container(
                width: 200 + glow * 40,
                height: 200 + glow * 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.foregroundColor
                          .withValues(alpha: 0.04 + glow * 0.02),
                      widget.foregroundColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            if (widget.logo != null)
              Center(
                child: Transform.scale(
                  scale: 1.0 + glow * 0.05,
                  child: widget.logo,
                ),
              ),

            Positioned(
              left: size.width * 0.15,
              right: size.width * 0.15,
              bottom: size.height * 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.progress * 100).round()}',
                    style: AppTypography.monoLarge.copyWith(
                      color: widget.foregroundColor
                          .withValues(alpha: 0.3 + glow * 0.2),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: widget.foregroundColor.withValues(alpha: 0.06),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: widget.progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: LinearGradient(
                            colors: [
                              widget.foregroundColor.withValues(alpha: 0),
                              widget.foregroundColor
                                  .withValues(alpha: 0.5 + glow * 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // -- Wave ------------------------------------------------------------------

  Widget _buildWave(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Stack(
          children: [
            if (widget.logo != null) Center(child: widget.logo),

            Positioned(
              left: size.width * 0.1,
              right: size.width * 0.1,
              bottom: size.height * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (widget.progress * 100)
                        .round()
                        .toString()
                        .padLeft(3, '0'),
                    style: AppTypography.monoIndex.copyWith(
                      color: widget.foregroundColor.withValues(alpha: 0.4),
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 20,
                    child: CustomPaint(
                      size: Size(size.width * 0.8, 20),
                      painter: _WaveProgressPainter(
                        progress: widget.progress.clamp(0.0, 1.0),
                        wavePhase: _waveController.value * 2 * pi,
                        color: widget.foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Paints a sine-wave progress line.
class _WaveProgressPainter extends CustomPainter {

  _WaveProgressPainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
  });
  final double progress;
  final double wavePhase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      trackPaint,
    );

    if (progress <= 0) return;

    final progressWidth = size.width * progress;
    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const amplitude = 4.0;
    const frequency = 3.0;

    for (double x = 0; x <= progressWidth; x += 1) {
      final y = size.height / 2 +
          sin(x / size.width * frequency * 2 * pi + wavePhase) * amplitude;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_WaveProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || wavePhase != oldDelegate.wavePhase;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  3. CIRCLE REVEAL — ILY GIRL-style expanding circle clip
//     New page reveals from an expanding circle originating at a given point.
// ═══════════════════════════════════════════════════════════════════════════════

/// A [PageRouteBuilder] that reveals the new page with an expanding circle
/// clip. [origin] is the center of the circle in global coordinates; when
/// null it defaults to the screen center.
class CircleReveal extends PageRouteBuilder<void> {

  CircleReveal({
    required this.page,
    this.origin,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: animationDuration,
          reverseTransitionDuration: animationDuration,
          opaque: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _CircleRevealWidget(
              animation: animation,
              origin: origin,
              child: child,
            );
          },
        );

  /// Circle expanding from screen center.
  factory CircleReveal.center({
    required Widget page,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return CircleReveal(page: page, origin: null, animationDuration: duration);
  }

  /// Circle expanding from a tap position.
  factory CircleReveal.fromTap({
    required Widget page,
    required Offset tapPosition,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return CircleReveal(
      page: page,
      origin: tapPosition,
      animationDuration: duration,
    );
  }

  /// Circle expanding from a given corner.
  factory CircleReveal.fromCorner({
    required Widget page,
    required BuildContext context,
    Alignment corner = Alignment.bottomRight,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final size = MediaQuery.of(context).size;
    final offset = Offset(
      (corner.x + 1) / 2 * size.width,
      (corner.y + 1) / 2 * size.height,
    );
    return CircleReveal(
      page: page,
      origin: offset,
      animationDuration: duration,
    );
  }
  final Widget page;
  final Offset? origin;
  final Duration animationDuration;
}

class _CircleRevealWidget extends StatelessWidget {

  const _CircleRevealWidget({
    required this.animation,
    required this.origin,
    required this.child,
  });
  final Animation<double> animation;
  final Offset? origin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return ClipPath(
          clipper: _CircleRevealClipper(
            fraction: curved.value,
            origin: origin,
          ),
          child: child,
        );
      },
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {

  _CircleRevealClipper({required this.fraction, this.origin});
  final double fraction;
  final Offset? origin;

  @override
  Path getClip(Size size) {
    final center = origin ?? Offset(size.width / 2, size.height / 2);

    // Maximum radius: distance from origin to the farthest corner.
    final maxRadius = [
      (center - Offset.zero).distance,
      (center - Offset(size.width, 0)).distance,
      (center - Offset(0, size.height)).distance,
      (center - Offset(size.width, size.height)).distance,
    ].reduce(max);

    final radius = maxRadius * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      fraction != oldClipper.fraction || origin != oldClipper.origin;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  4. SLICE TRANSITION — obake.blue-style staggered slices
//     Screen splits into N horizontal (or vertical) slices that slide out
//     in a staggered sequence, revealing the new page.
// ═══════════════════════════════════════════════════════════════════════════════

/// Axis along which slices are cut.
enum SliceAxis { horizontal, vertical }

/// A [PageRouteBuilder] that reveals the new page through staggered slices.
class SliceTransition extends PageRouteBuilder<void> {

  SliceTransition({
    required this.page,
    this.sliceCount = 6,
    this.axis = SliceAxis.horizontal,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: animationDuration,
          reverseTransitionDuration: animationDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _SliceTransitionWidget(
              animation: animation,
              sliceCount: sliceCount,
              axis: axis,
              child: child,
            );
          },
        );
  final Widget page;
  final int sliceCount;
  final SliceAxis axis;
  final Duration animationDuration;
}

class _SliceTransitionWidget extends StatelessWidget {

  const _SliceTransitionWidget({
    required this.animation,
    required this.sliceCount,
    required this.axis,
    required this.child,
  });
  final Animation<double> animation;
  final int sliceCount;
  final SliceAxis axis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          children: [
            // New page underneath.
            child,
            // Overlay slices that slide away with stagger.
            ...List.generate(sliceCount, (i) => _buildSlice(context, i)),
          ],
        );
      },
    );
  }

  Widget _buildSlice(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;

    // Stagger: each slice starts and ends at slightly offset intervals.
    final staggerStart = index / (sliceCount * 2.0);
    final staggerEnd = (0.5 + (index + 1) / (sliceCount * 2.0)).clamp(0.0, 1.0);

    final sliceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(staggerStart, staggerEnd, curve: Curves.easeInQuart),
      ),
    );

    final progress = sliceAnim.value;

    // Alternate direction: even slices go right/down, odd go left/up.
    final direction = index.isEven ? 1.0 : -1.0;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    if (axis == SliceAxis.horizontal) {
      final sliceHeight = size.height / sliceCount;
      return Positioned(
        left: progress * size.width * direction,
        top: index * sliceHeight,
        child: Opacity(
          opacity: opacity,
          child: ClipRect(
            child: SizedBox(
              width: size.width,
              height: sliceHeight + 1, // +1 to prevent subpixel gaps
              child: const ColoredBox(color: AppColors.black),
            ),
          ),
        ),
      );
    } else {
      final sliceWidth = size.width / sliceCount;
      return Positioned(
        left: index * sliceWidth,
        top: progress * size.height * direction,
        child: Opacity(
          opacity: opacity,
          child: ClipRect(
            child: SizedBox(
              width: sliceWidth + 1,
              height: size.height,
              child: const ColoredBox(color: AppColors.black),
            ),
          ),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  5. FADE SLIDE TRANSITION — LQVE-style subtle elegance
//     Combined fade + slight upward slide. Professional and understated.
// ═══════════════════════════════════════════════════════════════════════════════

/// A [PageRouteBuilder] with a subtle fade-in combined with an upward slide.
class FadeSlideTransition extends PageRouteBuilder<void> {

  FadeSlideTransition({
    required this.page,
    this.offsetDistance = 30.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: animationDuration,
          reverseTransitionDuration: animationDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved =
                CurvedAnimation(parent: animation, curve: curve);
            return AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                return Opacity(
                  opacity: curved.value,
                  child: Transform.translate(
                    offset:
                        Offset(0, offsetDistance * (1.0 - curved.value)),
                    child: child,
                  ),
                );
              },
            );
          },
        );
  final Widget page;
  final double offsetDistance;
  final Duration animationDuration;
  final Curve curve;
}

/// A standalone entrance widget: plays once when first inserted into the tree.
/// Useful for staggered list items or section reveals.
class FadeSlideIn extends StatefulWidget {

  const FadeSlideIn({
    super.key,
    required this.child,
    this.offsetDistance = 30.0,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
  });
  final Widget child;
  final double offsetDistance;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.offsetDistance),
      end: Offset.zero,
    ).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  6. GLITCH TRANSITION — punchred.xyz-style digital glitch
//     Brief random RGB shift + horizontal slice displacement.
//     Quick and impactful (200-300 ms).
// ═══════════════════════════════════════════════════════════════════════════════

/// A [PageRouteBuilder] that performs a brief digital glitch effect during
/// the page transition.
class GlitchTransition extends PageRouteBuilder<void> {

  GlitchTransition({
    required this.page,
    this.sliceCount = 12,
    this.animationDuration = const Duration(milliseconds: 280),
    this.seed = 42,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: animationDuration,
          reverseTransitionDuration: animationDuration,
          opaque: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _GlitchTransitionWidget(
              animation: animation,
              sliceCount: sliceCount,
              seed: seed,
              child: child,
            );
          },
        );
  final Widget page;
  final int sliceCount;
  final Duration animationDuration;
  final int seed;
}

class _GlitchTransitionWidget extends StatelessWidget {

  const _GlitchTransitionWidget({
    required this.animation,
    required this.sliceCount,
    required this.seed,
    required this.child,
  });
  final Animation<double> animation;
  final int sliceCount;
  final int seed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rng = Random(seed);

    // Pre-generate random displacements for each slice.
    final displacements = List.generate(
      sliceCount,
      (_) => (rng.nextDouble() - 0.5) * 80, // -40..+40 px
    );
    // Random color-shift per slice (red/cyan split).
    final colorShifts = List.generate(
      sliceCount,
      (_) => (rng.nextDouble() - 0.5) * 12, // -6..+6 px
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Glitch intensity peaks in the middle of the transition.
        final intensity = sin(t * pi);
        // Child fades in throughout.
        final childOpacity = Curves.easeIn.transform(t.clamp(0.0, 1.0));

        if (intensity < 0.01) {
          return Opacity(opacity: childOpacity, child: child);
        }

        final size = MediaQuery.of(context).size;
        final sliceHeight = size.height / sliceCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // New page fading in behind.
            Opacity(opacity: childOpacity, child: child),

            // Glitch overlay: displaced horizontal slices with RGB edges.
            ...List.generate(sliceCount, (i) {
              final dx = displacements[i] * intensity;
              final rgbDx = colorShifts[i] * intensity;
              final sliceOpacity = (1.0 - t).clamp(0.0, 1.0);

              return Positioned(
                left: dx,
                top: i * sliceHeight,
                child: Opacity(
                  opacity: sliceOpacity * 0.85,
                  child: SizedBox(
                    width: size.width + 40,
                    height: sliceHeight + 1,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cyan channel shift.
                        Positioned(
                          left: rgbDx,
                          top: 0,
                          child: SizedBox(
                            width: size.width,
                            height: sliceHeight + 1,
                            child: ColoredBox(
                              color: const Color(0xFF00FFFF)
                                  .withValues(alpha: 0.08 * intensity),
                            ),
                          ),
                        ),
                        // Red channel shift.
                        Positioned(
                          left: -rgbDx,
                          top: 0,
                          child: SizedBox(
                            width: size.width,
                            height: sliceHeight + 1,
                            child: ColoredBox(
                              color: const Color(0xFFFF0000)
                                  .withValues(alpha: 0.08 * intensity),
                            ),
                          ),
                        ),
                        // Base black slice.
                        ColoredBox(
                          color: AppColors.black
                              .withValues(alpha: 0.7 * intensity * sliceOpacity),
                          child: SizedBox(
                            width: size.width,
                            height: sliceHeight + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
