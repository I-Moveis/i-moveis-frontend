import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class MapPriceMarker extends StatelessWidget {
  const MapPriceMarker({
    required this.formattedPrice,
    required this.onTap,
    super.key,
    this.isSelected = false,
  });

  final String formattedPrice;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? BrutalistPalette.accentAmber(isDark)
        : BrutalistPalette.accentPeach(isDark);
    final textColor = isDark ? AppColors.black : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xsSm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.borderPill,
          boxShadow: AppShadows.lightSm,
        ),
        child: Text(
          formattedPrice,
          style: AppTypography.labelMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
