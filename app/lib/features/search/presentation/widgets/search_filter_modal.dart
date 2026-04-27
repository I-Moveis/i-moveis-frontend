import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Central Hub for all search filters with multi-selection support.
class SearchFilterModal extends ConsumerStatefulWidget {
  const SearchFilterModal({super.key});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  final List<String> _mockSuggestions = [
    'São Paulo, SP',
    'Rio de Janeiro, RJ',
    'Belo Horizonte, MG',
    'Curitiba, PR',
    'Porto Alegre, RS',
    'Florianópolis, SC',
  ];

  final List<String> _transactionOptions = ['Aluguel', 'Comprar', 'Lançamentos'];
  final List<String> _propertyTypeOptions = [
    'Apartamento',
    'Casa',
    'Studio',
    'Kitnet',
    'Cobertura',
    'Terreno',
    'Comercial',
  ];

  bool _isPropertyTypeExpanded = false;
  bool _isBedroomsExpanded = false;
  bool _isAmenitiesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch<SearchFilters>(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBottomSheetHeader(title: 'Todos os Filtros'),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Location (NOW FIRST) ---
                _buildSectionLabel('Localização', titleColor),
                const SizedBox(height: AppSpacing.md),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<String>.empty();
                    return _mockSuggestions.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updateLocation(selection);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    if (controller.text != filters.location && filters.location.isNotEmpty) {
                      controller.text = filters.location;
                    }
                    return AppTextField(
                      controller: controller,
                      focusNode: focusNode,
                      hint: 'Cidade ou bairro...',
                      prefixIcon: Icons.location_on_outlined,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return _buildAutocompleteOptions(context, onSelected, options, isDark, titleColor);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Transaction Type ---
                _buildSectionLabel('O que você busca?', titleColor),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _transactionOptions.map((type) {
                      final isSelected = filters.transactionTypes.contains(type);
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: AppChip(
                          label: type,
                          isSelected: isSelected,
                          onTap: () => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).toggleTransactionType(type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Property Type ---
                _buildSectionLabel('Tipo de Imóvel', titleColor),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ...(_isPropertyTypeExpanded
                            ? _propertyTypeOptions
                            : _propertyTypeOptions.take(3))
                        .map((type) {
                      final isSelected = filters.propertyTypes.contains(type);
                      return AppChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () => ref
                            .read<SearchFiltersNotifier>(
                                searchFiltersProvider.notifier)
                            .togglePropertyType(type),
                      );
                    }),
                    AppChip(
                      label: _isPropertyTypeExpanded ? 'Ver menos' : 'Ver mais',
                      icon: _isPropertyTypeExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _isPropertyTypeExpanded = !_isPropertyTypeExpanded;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Bedrooms ---
                _buildSectionLabel('Quartos', titleColor),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ...(_isBedroomsExpanded
                            ? [1, 2, 3, 4, 5]
                            : [1, 2, 3])
                        .map((count) {
                      final isSelected = filters.bedrooms.contains(count);
                      final label = '$count+';
                      return AppChip(
                        label: label,
                        isSelected: isSelected,
                        onTap: () => ref
                            .read<SearchFiltersNotifier>(
                                searchFiltersProvider.notifier)
                            .toggleBedroom(count),
                      );
                    }),
                    AppChip(
                      label: _isBedroomsExpanded ? 'Ver menos' : 'Ver mais',
                      icon: _isBedroomsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _isBedroomsExpanded = !_isBedroomsExpanded;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Price Range ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionLabel('Preço', titleColor),
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
                  onChanged: (values) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updatePriceRange(values),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Amenities ---
                _buildSectionLabel('Comodidades', titleColor),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    ...(_isAmenitiesExpanded
                        ? [
                            _AmenityData(
                                label: 'WiFi',
                                isSelected: filters.hasWifi,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updateWifi(!filters.hasWifi)),
                            _AmenityData(
                                label: 'Piscina',
                                isSelected: filters.hasPool,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updatePool(!filters.hasPool)),
                            _AmenityData(
                                label: 'Estacionamento',
                                isSelected: filters.hasParking,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updateParking(!filters.hasParking)),
                            _AmenityData(
                                label: 'Aceita Pets',
                                isSelected: filters.isPetFriendly,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updatePetFriendly(!filters.isPetFriendly)),
                          ]
                        : [
                            _AmenityData(
                                label: 'WiFi',
                                isSelected: filters.hasWifi,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updateWifi(!filters.hasWifi)),
                            _AmenityData(
                                label: 'Piscina',
                                isSelected: filters.hasPool,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updatePool(!filters.hasPool)),
                            _AmenityData(
                                label: 'Estacionamento',
                                isSelected: filters.hasParking,
                                onTap: () => ref
                                    .read(searchFiltersProvider.notifier)
                                    .updateParking(!filters.hasParking)),
                          ]).map((data) => AppChip(
                          label: data.label,
                          isSelected: data.isSelected,
                          onTap: data.onTap,
                        )),
                    AppChip(
                      label: _isAmenitiesExpanded ? 'Ver menos' : 'Ver mais',
                      icon: _isAmenitiesExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _isAmenitiesExpanded = !_isAmenitiesExpanded;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // --- Action Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Limpar',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).reset();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: BrutalistGradientButton(
                        label: 'VER RESULTADOS',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAutocompleteOptions(BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options, bool isDark, Color titleColor) {
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
  }
}

class _AmenityData {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  _AmenityData({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}
