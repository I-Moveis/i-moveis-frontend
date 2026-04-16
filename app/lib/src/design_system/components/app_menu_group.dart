import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/seed_color_provider.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import 'brutalist_page_scaffold.dart';

/// Data model for a menu group item.
class AppMenuGroupItem {
  const AppMenuGroupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
}

/// Grouped menu items with dividers, used in profile and admin pages.
class AppMenuGroup extends ConsumerWidget {
  const AppMenuGroup({
    super.key,
    required this.items,
  });

  final List<AppMenuGroupItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final bg = palette.surfaceBg(isDark);
    final border = palette.surfaceBorder(isDark);
    final titleColor = palette.title(isDark);
    final mutedColor = palette.muted(isDark);
    final accentColor = palette.accentOrange(isDark);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildItem(items[i], titleColor, mutedColor, accentColor),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: AppSpacing.lg + 20 + AppSpacing.md,
                color: border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    AppMenuGroupItem item,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: item.iconColor ?? accentColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.label,
                style: AppTypography.titleSmall.copyWith(color: titleColor),
              ),
            ),
            item.trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: mutedColor.withValues(alpha: 0.4),
                ),
          ],
        ),
      ),
    );
  }
}
