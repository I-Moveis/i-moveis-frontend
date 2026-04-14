import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_durations.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => _controller.forward(),
      onTapUp: _isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: _isDisabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: _buildButton(isDark),
      ),
    );
  }

  Widget _buildButton(bool isDark) {
    final colors = _getColors(isDark);
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(
        color: _isDisabled ? colors.bg.withValues(alpha: 0.5) : colors.bg,
        borderRadius: AppRadius.borderFull,
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!, width: 1.5)
            : null,
        boxShadow: widget.variant == AppButtonVariant.primary && !_isDisabled
            ? AppShadows.primaryGlow
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isDisabled ? null : widget.onPressed,
          borderRadius: AppRadius.borderFull,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.fg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: _getIconSize(), color: colors.fg),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  widget.label,
                  style: textStyle.copyWith(
                    color: _isDisabled ? colors.fg.withValues(alpha: 0.5) : colors.fg,
                  ),
                ),
                if (widget.trailingIcon != null && !widget.isLoading) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(widget.trailingIcon, size: _getIconSize(), color: colors.fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _getColors(bool isDark) {
    return switch (widget.variant) {
      AppButtonVariant.primary => _ButtonColors(
          bg: AppColors.primary,
          fg: AppColors.onPrimary,
        ),
      AppButtonVariant.secondary => _ButtonColors(
          bg: AppColors.secondary,
          fg: AppColors.onSecondary,
        ),
      AppButtonVariant.outline => _ButtonColors(
          bg: Colors.transparent,
          fg: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      AppButtonVariant.ghost => _ButtonColors(
          bg: Colors.transparent,
          fg: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      AppButtonVariant.danger => _ButtonColors(
          bg: AppColors.error,
          fg: Colors.white,
        ),
    };
  }

  EdgeInsets _getPadding() => switch (widget.size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  TextStyle _getTextStyle() => switch (widget.size) {
        AppButtonSize.small => AppTypography.labelMedium,
        AppButtonSize.medium => AppTypography.labelLarge,
        AppButtonSize.large => AppTypography.titleSmall,
      };

  double _getIconSize() => switch (widget.size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 20,
        AppButtonSize.large => 24,
      };
}

class _ButtonColors {
  final Color bg;
  final Color fg;
  final Color? borderColor;

  const _ButtonColors({required this.bg, required this.fg, this.borderColor});
}
