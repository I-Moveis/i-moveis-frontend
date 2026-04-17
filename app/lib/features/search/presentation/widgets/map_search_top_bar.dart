import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

class MapSearchTopBar extends StatelessWidget {
  const MapSearchTopBar({
    required this.onBack, required this.onSearchTap, super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final faintColor = BrutalistPalette.faint(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: borderColor),
                boxShadow: BrutalistPalette.subtleShadow(isDark),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: mutedColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadius.borderXl,
                  border: Border.all(color: borderColor),
                  boxShadow: BrutalistPalette.subtleShadow(isDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 16, color: mutedColor),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Buscar no mapa...',
                      style: AppTypography.bodyMedium.copyWith(color: faintColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
