import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class PropertyInfoCards extends StatelessWidget {
  const PropertyInfoCards({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalhes', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _card('${property.area.toInt()}', 'm²', Icons.straighten_rounded, cardBg, borderColor, titleColor, mutedColor, accentColor),
            const SizedBox(width: AppSpacing.sm),
            _card('${property.bedrooms}', 'quartos', Icons.bed_rounded, cardBg, borderColor, titleColor, mutedColor, accentColor),
            const SizedBox(width: AppSpacing.sm),
            _card('${property.bathrooms}', 'banh.', Icons.bathtub_outlined, cardBg, borderColor, titleColor, mutedColor, accentColor),
            const SizedBox(width: AppSpacing.sm),
            _card('${property.parkingSpots}', 'vaga${property.parkingSpots != 1 ? 's' : ''}', Icons.directions_car_outlined, cardBg, borderColor, titleColor, mutedColor, accentColor),
          ],
        ),
      ],
    );
  }

  Widget _card(
    String value,
    String label,
    IconData icon,
    Color bg,
    Color border,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: accentColor.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTypography.headlineMediumBold.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xxs),
            Text(label, style: AppTypography.captionTiny.copyWith(color: mutedColor)),
          ],
        ),
      ),
    );
  }
}
