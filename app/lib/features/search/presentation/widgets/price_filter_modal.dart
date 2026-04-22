import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal for selecting the price range.
class PriceFilterModal extends ConsumerWidget {
  /// Creates a [PriceFilterModal].
  const PriceFilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(title: 'Preço'),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Faixa de preço',
                    style: AppTypography.titleMedium.copyWith(color: titleColor),
                  ),
                  Text(
                    'R\$ ${filters.priceRange.start.toInt()} - R\$ ${filters.priceRange.end.toInt()}',
                    style: AppTypography.labelLarge.copyWith(color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              RangeSlider(
                values: filters.priceRange,
                max: 50000,
                divisions: 50,
                activeColor: accentColor,
                inactiveColor: isDark ? AppColors.blackLightest : AppColors.lightBorder,
                onChanged: (values) => ref.read(searchFiltersProvider.notifier).updatePriceRange(values),
              ),
              const SizedBox(height: AppSpacing.xxl),
              BrutalistGradientButton(
                label: 'APLICAR FILTRO',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}
