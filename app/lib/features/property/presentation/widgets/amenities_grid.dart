import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class AmenitiesGrid extends StatelessWidget {
  const AmenitiesGrid({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    if (property.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenidades', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: property.amenities.map((amenity) => _chip(amenity, accentColor)).toList(),
        ),
      ],
    );
  }

  Widget _chip(String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: accentColor),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmallBold.copyWith(color: accentColor)),
        ],
      ),
    );
  }
}
