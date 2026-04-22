import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal featuring advanced search filters: Location, Bedrooms, Price.
class SearchFilterModal extends ConsumerStatefulWidget {
  const SearchFilterModal({super.key});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  late TextEditingController _locationController;
  final List<String> _mockSuggestions = [
    'São Paulo, SP',
    'Rio de Janeiro, RJ',
    'Belo Horizonte, MG',
    'Curitiba, PR',
    'Porto Alegre, RS',
    'Florianópolis, SC',
  ];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(searchFiltersProvider);
    _locationController = TextEditingController(text: currentFilters.location);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final titleColor = BrutalistPalette.title(isDark);


    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtros de Busca',
            style: AppTypography.headlineMedium.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // --- Location ---
          Text(
            'Localização',
            style: AppTypography.titleMedium.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return _mockSuggestions.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              ref.read(searchFiltersProvider.notifier).updateLocation(selection);
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return AppTextField(
                controller: controller,
                focusNode: focusNode,
                hint: 'Cidade ou bairro...',
                prefixIcon: Icons.location_on_outlined,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: AppRadius.borderMd,
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  child: Container(
                    width: MediaQuery.of(context).size.width - AppSpacing.xxl * 2,
                    decoration: BoxDecoration(
                      border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(color: BrutalistPalette.dividerColor(isDark)),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option, style: AppTypography.bodyMedium.copyWith(color: titleColor)),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Bedrooms ---
          Text(
            'Quartos',
            style: AppTypography.titleMedium.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [0, 1, 2, 3, 4].map((count) {
                final isSelected = filters.bedrooms == count;
                final label = count == 0 ? 'Qualquer' : '$count+';
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AppChip(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => ref.read(searchFiltersProvider.notifier).updateBedrooms(count),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Price Range ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preço',
                style: AppTypography.titleMedium.copyWith(color: titleColor),
              ),
              Text(
                'R\$ ${filters.priceRange.start.toInt()} - R\$ ${filters.priceRange.end.toInt()}',
                style: AppTypography.labelLarge.copyWith(color: accentColor),
              ),

            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RangeSlider(
            values: filters.priceRange,
            max: 50000,
            divisions: 50,

            activeColor: accentColor,
            inactiveColor: isDark ? AppColors.blackLightest : AppColors.lightBorder,
            labels: RangeLabels(
              'R\$ ${filters.priceRange.start.toInt()}',
              'R\$ ${filters.priceRange.end.toInt()}',
            ),

            onChanged: (values) {
              ref.read(searchFiltersProvider.notifier).updatePriceRange(values);
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // --- Action Buttons ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(searchFiltersProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ver resultados'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Helper extension for AppTextField to support FocusNode (not in original class but useful here)
extension _FocusNodeExtension on AppTextField {
  // We'll need to modify AppTextField or pass FocusNode. 
  // Since I can't easily modify components that might be used elsewhere without care, 
  // I'll ensure I use properties correctly or create a local variant.
}
