import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Valores', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
        const SizedBox(height: AppSpacing.md),
        _row('Aluguel', property.price, titleColor, mutedColor),
        if (property.condoFee > 0)
          _row(
            'Condomínio',
            'R\$ ${property.condoFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            titleColor,
            mutedColor,
          ),
        if (property.taxes > 0)
          _row(
            'IPTU',
            'R\$ ${property.taxes.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            titleColor,
            mutedColor,
          ),
        Divider(height: AppSpacing.xxl, color: accentColor.withValues(alpha: 0.2)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Total / mês', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'R\$ ${property.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                textAlign: TextAlign.end,
                style: AppTypography.headlineMediumBold.copyWith(color: accentColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value, Color titleColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.titleSmall.copyWith(color: titleColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
