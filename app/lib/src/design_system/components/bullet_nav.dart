import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_durations.dart';

/// p5aholic.me style navigation with bullet (●) separators.
///
/// Home ● Projects ● Info ● Contact
///
/// Uppercase, wide tracking, minimal. The navigation should
/// feel like a table of contents, not a toolbar.
class BulletNav extends StatelessWidget {
  const BulletNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                style: AppTypography.navLabel.copyWith(
                  color: i == selectedIndex
                      ? (isDark ? AppColors.white : AppColors.black)
                      : (isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary),
                ),
                child: Text(items[i].toUpperCase()),
              ),
            ),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  '●',
                  style: TextStyle(
                    fontSize: 4,
                    color: isDark
                        ? AppColors.darkTextDisabled
                        : AppColors.lightTextDisabled,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
