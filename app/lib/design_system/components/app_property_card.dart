import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/seed_color_provider.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Property list item card with thumbnail, title, status badge, and trailing action.
class AppPropertyCard extends ConsumerWidget {
  const AppPropertyCard({
    required this.title, super.key,
    this.subtitle,
    this.status,
    this.statusColor,
    this.thumbnailIcon = Icons.home_rounded,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? status;
  final Color? statusColor;
  final IconData thumbnailIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final bg = palette.surfaceBg(isDark);
    final border = palette.surfaceBorder(isDark);
    final titleColor = palette.title(isDark);
    final mutedColor = palette.muted(isDark);
    final placeholderBg = palette.imagePlaceholderBg(isDark);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: placeholderBg,
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                thumbnailIcon,
                size: 24,
                color: mutedColor.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(color: mutedColor),
                    ),
                  ],
                  if (status != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (statusColor ?? mutedColor).withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        status!,
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor ?? mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
