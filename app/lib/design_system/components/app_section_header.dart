import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/seed_color_provider.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/tokens/app_spacing.dart';

/// Section header with title and optional action link.
class AppSectionHeader extends ConsumerWidget {
  const AppSectionHeader({
    required this.title, super.key,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final titleColor = palette.title(isDark);
    final actionColor = palette.accentPeach(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(color: titleColor),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTypography.titleSmall.copyWith(
                  color: actionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
