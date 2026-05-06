import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/seed_color_provider.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Metric card showing icon, animated count-up value, and label.
class AppMetricCard extends ConsumerWidget {
  const AppMetricCard({
    required this.icon, required this.value, required this.label, super.key,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final bg = palette.surfaceBg(isDark);
    final border = palette.surfaceBorder(isDark);
    final titleColor = palette.title(isDark);
    final mutedColor = palette.muted(isDark);
    final accentColor = palette.accentOrange(isDark);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            _CountUpText(
              value: value,
              style: AppTypography.headlineLarge.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
          ],
        ),
      ),
    );
  }
}

class _CountUpText extends StatefulWidget {
  const _CountUpText({required this.value, required this.style});
  final int value;
  final TextStyle style;

  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
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
      animation: _animation,
      builder: (context, _) => Text('${_animation.value}', style: widget.style),
    );
  }
}
