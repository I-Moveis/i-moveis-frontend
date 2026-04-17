import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Pastel-colored chip.
///
/// Inspired by ILY GIRL exhibition's pastel acrylic blocks
/// and the soft anime-aesthetic color language.
class PastelChip extends StatelessWidget {
  const PastelChip({
    required this.label, super.key,
    this.color,
    this.onTap,
  });

  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.pastelLavender;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.25),
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: chipColor.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: chipColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
