import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/seed_color_provider.dart';

/// Animated wave background — PS3 XMB style.
///
/// Flowing ribbon lines with no fill, just thin strokes that
/// drift and undulate like the iconic PlayStation 3 menu.
/// Inspired by:
/// - PS3 XMB: pure line ribbons, no fill, ethereal glow
/// - p5aholic: mathematical precision in animation
/// - Midnight Grand Orchestra: flowing wave motions

enum WaveColorScheme {
  /// Deep blue/purple gradients (Midnight Grand Orchestra)
  midnight,

  /// Teal/cyan (LQVE)
  ocean,

  /// Green/purple/pink (Northern lights)
  aurora,

  /// Orange/pink/purple
  sunset,

  /// White/gray on black (p5aholic)
  mono,

  /// Dynamic color based on seedColorProvider
  custom,
}

class WaveBackground extends ConsumerStatefulWidget {
  const WaveBackground({
    super.key,
    this.waveCount = 8,
    this.colorScheme = WaveColorScheme.custom,
    this.speed = 0.6,
    this.amplitude = 1.0,
    this.child,
    this.adaptToTheme = true,
  });

  final int waveCount;
  final WaveColorScheme colorScheme;
  final double speed;
  final double amplitude;
  final Widget? child;
  /// When true, adapts background and line colors for light/dark theme.
  final bool adaptToTheme;

  @override
  ConsumerState<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends ConsumerState<WaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Duration is irrelevant — we use elapsed time, not value.
      duration: const Duration(seconds: 1),
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
    
    final seedColor = ref.watch(seedColorProvider);
    final colors = _getColors(widget.colorScheme, isDark, seedColor);

    return Stack(
      children: [
        // Background fill
        Positioned.fill(
          child: Container(color: colors.background),
        ),
        // Wave lines — isolated RepaintBoundary for performance
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final elapsed = (_controller.lastElapsedDuration?.inMicroseconds ?? 0)
                    .toDouble() * 0.000001;
                return CustomPaint(
                  painter: _WavePainter(
                    time: elapsed,
                    waveCount: widget.waveCount,
                    colors: colors,
                    speed: widget.speed,
                    amplitude: widget.amplitude,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }

  _WaveColors _getColors(WaveColorScheme scheme, bool isDark, Color seedColor) {
    final darkBg = const Color(0xFF111111);
    final lightBg = const Color(0xFFF5F5F5);
    final bg = isDark ? darkBg : lightBg;

    switch (scheme) {
      case WaveColorScheme.midnight:
        return _WaveColors(
          background: bg,
          waves: _generateGradientLines(
            isDark ? const Color(0xFF2020AA) : const Color(0xFF4040CC),
            isDark ? const Color(0xFF6040DD) : const Color(0xFF7050EE),
            widget.waveCount,
            isDark: isDark,
          ),
        );
      case WaveColorScheme.ocean:
        return _WaveColors(
          background: bg,
          waves: _generateGradientLines(
            isDark ? const Color(0xFF01FFEA) : const Color(0xFF00A0A0),
            isDark ? const Color(0xFF005F5F) : const Color(0xFF008080),
            widget.waveCount,
            isDark: isDark,
          ),
        );
      case WaveColorScheme.aurora:
        return _WaveColors(
          background: bg,
          waves: _generateGradientLines(
            isDark ? const Color(0xFF06D6A0) : const Color(0xFF00BFA0),
            isDark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED),
            widget.waveCount,
            isDark: isDark,
          ),
        );
      case WaveColorScheme.sunset:
        return _WaveColors(
          background: bg,
          waves: _generateGradientLines(
            isDark ? const Color(0xFFD4917A) : const Color(0xFFCC7A60),
            isDark ? const Color(0xFFDEAD82) : const Color(0xFFB08060),
            widget.waveCount,
            isDark: isDark,
          ),
        );
      case WaveColorScheme.mono:
        return _WaveColors(
          background: isDark ? const Color(0xFF111111) : const Color(0xFFF8F8F8),
          waves: _generateGradientLines(
            isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
            isDark ? const Color(0xFF444444) : const Color(0xFF666666),
            widget.waveCount,
            isDark: isDark,
          ),
        );
      case WaveColorScheme.custom:
        return _WaveColors(
          background: bg,
          waves: _generateGradientLines(
            seedColor,
            Color.lerp(seedColor, isDark ? Colors.white : Colors.black, 0.3)!,
            widget.waveCount,
            isDark: isDark,
          ),
        );
    }
  }

  /// Generates a spread of line colors from [start] to [end],
  /// with opacity fading toward the edges — the PS3 ribbon look.
  List<Color> _generateGradientLines(Color start, Color end, int count,
      {bool isDark = true}) {
    return List.generate(count, (i) {
      final t = count > 1 ? i / (count - 1) : 0.5;
      // Bell curve opacity: brightest in center, fading at edges
      final centerDist = (t - 0.5).abs() * 2.0; // 0 at center, 1 at edges
      final baseOpacity = isDark ? 0.08 : 0.12;
      final peakOpacity = isDark ? 0.35 : 0.45;
      final opacity = baseOpacity + (1.0 - centerDist * centerDist) * peakOpacity;
      return Color.lerp(start, end, t)!.withValues(alpha: opacity);
    });
  }
}

class _WaveColors {
  const _WaveColors({required this.background, required this.waves});
  final Color background;
  final List<Color> waves;
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.time,
    required this.waveCount,
    required this.colors,
    required this.speed,
    required this.amplitude,
  });

  final double time;
  final int waveCount;
  final _WaveColors colors;
  final double speed;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final count = min(waveCount, colors.waves.length);
    final centerY = size.height * 0.5;

    for (int i = 0; i < count; i++) {
      final t = count > 1 ? i / (count - 1) : 0.5;

      // PS3-style: lines spread vertically from center
      final spread = (t - 0.5) * size.height * 0.6;
      final baseY = centerY + spread;

      // Each line has unique frequency + phase for organic feel
      final frequency = (1.5 + i * 0.15) * pi / size.width;
      // Continuous time — never resets, seamless infinite loop
      final phaseShift = time * speed * (0.3 + i * 0.04);
      final waveHeight = size.height * (0.03 + (0.5 - (t - 0.5).abs()) * 0.06) * amplitude;

      // Thin stroke, no fill
      final paint = Paint()
        ..color = colors.waves[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..isAntiAlias = true;

      final path = Path();

      // First point — 2 harmonics only (3rd adds <1px difference)
      final firstY = baseY +
          sin(phaseShift) * waveHeight +
          sin(phaseShift * 0.7) * waveHeight * 0.4;
      path.moveTo(0, firstY);

      // Draw smooth wave — step of 8px, 2 harmonics for performance
      for (double x = 0; x <= size.width; x += 8) {
        final y = baseY +
            sin(x * frequency + phaseShift) * waveHeight +
            sin(x * frequency * 2.1 + phaseShift * 0.7) * waveHeight * 0.3;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);

      // Lightweight glow for center ribbons — no MaskFilter blur (expensive)
      if ((t - 0.5).abs() < 0.25) {
        final glowPaint = Paint()
          ..color = colors.waves[i].withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
