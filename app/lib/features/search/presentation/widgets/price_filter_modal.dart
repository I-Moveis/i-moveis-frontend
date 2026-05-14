import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal for selecting the price range.
///
/// O slider mantém o valor localmente enquanto o usuário arrasta e só
/// propaga para o `searchFiltersProvider` quando o dedo é solto
/// (`onChangeEnd`). Sem isso, cada frame do arrasto dispararia uma
/// requisição nova no `searchNotifierProvider`.
class PriceFilterModal extends ConsumerStatefulWidget {
  /// Creates a [PriceFilterModal].
  const PriceFilterModal({super.key});

  @override
  ConsumerState<PriceFilterModal> createState() => _PriceFilterModalState();
}

class _PriceFilterModalState extends ConsumerState<PriceFilterModal> {
  RangeValues? _localRange;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    final displayRange = _localRange ?? filters.priceRange;

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
                    'R\$ ${displayRange.start.toInt()} - R\$ ${displayRange.end.toInt()}',
                    style: AppTypography.labelLarge.copyWith(color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              RangeSlider(
                values: displayRange,
                max: 50000,
                divisions: 50,
                activeColor: accentColor,
                inactiveColor:
                    isDark ? AppColors.blackLightest : AppColors.lightBorder,
                onChanged: (values) => setState(() => _localRange = values),
                onChangeEnd: (values) {
                  setState(() => _localRange = values);
                  ref
                      .read(searchFiltersProvider.notifier)
                      .updatePriceRange(values);
                },
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
