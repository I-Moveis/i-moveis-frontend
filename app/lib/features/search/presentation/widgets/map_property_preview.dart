import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/map_property.dart';

class MapPropertyPreview extends ConsumerWidget {
  const MapPropertyPreview({
    required this.property, required this.onClose, super.key,
    this.onTap,
  });

  final MapProperty property;
  final VoidCallback onClose;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      child: AppPropertyCard(
        title: property.title,
        subtitle: property.type,
        status: property.price,
        statusColor: accentColor,
        thumbnailIcon: property.thumbnailIcon,
        onTap: onTap,
        trailing: GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: BrutalistPalette.subtleBg(isDark),
              borderRadius: AppRadius.borderFull,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: mutedColor,
            ),
          ),
        ),
      ),
    );
  }
}
