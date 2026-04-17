import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

enum AppBadgeVariant { success, warning, error, info, neutral }

/// Status badge for displaying states (Active, Pending, Error, etc.)
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label, super.key,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          // Dot indicator
          if (icon == null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getColors(bool isDark) => switch (variant) {
        AppBadgeVariant.success => _BadgeColors(
            bg: isDark ? AppColors.successBg : AppColors.successLight,
            fg: AppColors.success,
          ),
        AppBadgeVariant.warning => _BadgeColors(
            bg: isDark ? AppColors.warningBg : AppColors.warningLight,
            fg: AppColors.warning,
          ),
        AppBadgeVariant.error => _BadgeColors(
            bg: isDark ? AppColors.errorBg : AppColors.errorLight,
            fg: AppColors.error,
          ),
        AppBadgeVariant.info => _BadgeColors(
            bg: isDark ? AppColors.infoBg : AppColors.infoLight,
            fg: AppColors.info,
          ),
        AppBadgeVariant.neutral => _BadgeColors(
            bg: isDark ? AppColors.darkElevated : AppColors.lightBorderSubtle,
            fg: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
      };
}

class _BadgeColors {
  const _BadgeColors({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}
