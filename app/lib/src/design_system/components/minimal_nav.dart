import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_durations.dart';

/// Minimal top navigation.
///
/// Inspired by lqve.jp's clean horizontal nav, obake.blue's
/// [Works, Room 444, About] and PUNCH's gallery-like navigation.
/// Features uppercase spaced letters and a subtle active indicator.
class MinimalNav extends StatelessWidget {
  const MinimalNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.trailing,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Nav items
          Expanded(
            child: Row(
              children: List.generate(items.length, (i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xxl),
                    child: AnimatedDefaultTextStyle(
                      duration: AppDurations.normal,
                      style: AppTypography.navLabel.copyWith(
                        color: isSelected
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(items[i].toUpperCase()),
                          const SizedBox(height: 4),
                          // Active indicator dot
                          AnimatedContainer(
                            duration: AppDurations.normal,
                            width: isSelected ? 4 : 0,
                            height: isSelected ? 4 : 0,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primary : AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Trailing action
          ?trailing,
        ],
      ),
    );
  }
}
