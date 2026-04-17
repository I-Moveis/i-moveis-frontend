import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_durations.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Numbered portfolio card.
///
/// Directly inspired by obake.blue's numbered project system (01-47)
/// and PUNCH portfolio's clean image + text layout.
/// Features a large monospace number, image area, title, and metadata.
class NumberedCard extends StatelessWidget {
  const NumberedCard({
    required this.number, required this.title, super.key,
    this.subtitle,
    this.date,
    this.imageColor,
    this.onTap,
  });

  final int number;
  final String title;
  final String? subtitle;
  final String? date;
  final Color? imageColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numStr = number.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: imageColor ??
                      (isDark ? AppColors.darkCard : AppColors.lightBorderSubtle),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Stack(
                  children: [
                    // Large number overlay
                    Positioned(
                      left: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Text(
                        numStr,
                        style: AppTypography.monoDisplay.copyWith(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Number + Date row
            Row(
              children: [
                Text(
                  numStr,
                  style: AppTypography.monoLarge.copyWith(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    date!,
                    style: AppTypography.monoSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Title
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
