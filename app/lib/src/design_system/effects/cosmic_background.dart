import 'dart:math';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Cosmic starfield background effect.
///
/// Inspired by Midnight Grand Orchestra's Starpeggio and
/// UNDER VOYAGER's space aesthetic. Renders twinkling stars
/// with animated opacity using a CustomPainter.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({
    super.key,
    this.starCount = 50,
    this.child,
    this.showGradient = true,
    this.adaptToTheme = true,
  });

  final int starCount;
  final Widget? child;
  final bool showGradient;
  /// When true, adapts colors for light/dark theme automatically.
  final bool adaptToTheme;

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !widget.adaptToTheme ||
        Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? AppColors.cosmicGradient
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F8F8), Color(0xFFEEEEEE)],
          );

    return Stack(
      children: [
        // Gradient backdrop
        if (widget.showGradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),

        // Stars — isolated in RepaintBoundary for performance
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _StarfieldPainter(
                  starCount: widget.starCount,
                  animationValue: _controller.value,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ),

        // Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({
    required this.starCount,
    required this.animationValue,
    this.isDark = true,
  });

  final int starCount;
  final double animationValue;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(123);
    final paint = Paint();

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final baseRadius = 0.3 + random.nextDouble() * 1.2;
      final phase = random.nextDouble() * 2 * pi;
      final speed = 0.5 + random.nextDouble() * 1.5;

      // Twinkling animation
      final twinkle = 0.3 + 0.7 * ((sin(animationValue * 2 * pi * speed + phase) + 1) / 2);

      // Color variation adapts to theme
      final colorChoice = random.nextDouble();
      Color starColor;
      if (isDark) {
        if (colorChoice < 0.7) {
          starColor = Colors.white.withValues(alpha: 0.5 * twinkle + 0.1);
        } else if (colorChoice < 0.85) {
          starColor = AppColors.pastelBlue.withValues(alpha: 0.4 * twinkle + 0.1);
        } else {
          starColor = AppColors.pastelLavender.withValues(alpha: 0.4 * twinkle + 0.1);
        }
      } else {
        // Light theme: subtle dark dots instead of bright stars
        if (colorChoice < 0.7) {
          starColor = const Color(0xFF000000).withValues(alpha: 0.06 * twinkle + 0.02);
        } else if (colorChoice < 0.85) {
          starColor = const Color(0xFF2B00FF).withValues(alpha: 0.05 * twinkle + 0.01);
        } else {
          starColor = const Color(0xFFECACAC).withValues(alpha: 0.08 * twinkle + 0.02);
        }
      }

      paint.color = starColor;

      // Draw star with slight bloom
      canvas.drawCircle(Offset(x, y), baseRadius * twinkle, paint);

      // Bloom for only the brightest stars (reduced threshold for perf)
      if (baseRadius > 1.0 && twinkle > 0.85) {
        paint.color = starColor.withValues(alpha: isDark ? 0.04 : 0.02);
        canvas.drawCircle(Offset(x, y), baseRadius * 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue || isDark != oldDelegate.isDark;
}
