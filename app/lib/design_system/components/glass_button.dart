import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_durations.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Glass-morphism button.
///
/// p5aholic.me: color preset buttons at bottom-left,
/// 24px squares with hsla(0,0%,100%,.01) + 5px blur.
/// Almost invisible. Confidence in restraint.
class GlassButton extends StatefulWidget {
  const GlassButton({
    required this.label, super.key,
    this.onPressed,
    this.icon,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isActive;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (isDark ? AppColors.overlayMedium : AppColors.black)
                : _isHovered
                    ? (isDark ? AppColors.overlayLight : AppColors.lightBorderSubtle)
                    : (isDark ? AppColors.glass : const Color(0x08000000)),
            borderRadius: AppRadius.borderSm,
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorder
                  : const Color(0x14000000),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 14,
                  color: widget.isActive
                      ? AppColors.white
                      : (isDark ? AppColors.whiteMuted : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isActive
                      ? AppColors.white
                      : (isDark ? AppColors.whiteMuted : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
