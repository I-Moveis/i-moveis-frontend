import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/location_service.dart';
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
    'Brasília, DF',
    'Salvador, BA',
    'Fortaleza, CE',
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

  // Individual scroll controllers for each horizontal filter to enable interactivity
  final ScrollController _transactionScrollController = ScrollController();
  final ScrollController _propertyTypeScrollController = ScrollController();
  final ScrollController _bedroomsScrollController = ScrollController();
  final ScrollController _bathroomsScrollController = ScrollController();
  final ScrollController _amenitiesScrollController = ScrollController();
  final ScrollController _specialScrollController = ScrollController();
  final ScrollController _orderByScrollController = ScrollController();

  bool _locatingUser = false;

  late final TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _stateController = TextEditingController(
      text: ref.read(searchFiltersProvider).state,
    );
  }

  @override
  void dispose() {
    _stateController.dispose();
    _transactionScrollController.dispose();
    _propertyTypeScrollController.dispose();
    _bedroomsScrollController.dispose();
    _bathroomsScrollController.dispose();
    _amenitiesScrollController.dispose();
    _specialScrollController.dispose();
    _orderByScrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleNearbySearch(
      SearchFilters filters, SearchFiltersNotifier notifier) async {
    if (filters.latitude != null && filters.longitude != null) {
      notifier.clearNearbySearch();
      return;
    }
    setState(() => _locatingUser = true);
    try {
      final pos = await LocationService.getCurrentPosition();
      notifier.setNearbySearch(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buscando num raio de 5 km da sua localização.'),
        ),
      );
    } on LocationServiceDisabledException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ative o GPS para usar esta busca.')),
      );
    } on PermissionDeniedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permissão de localização negada.')),
      );
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter a localização.')),
      );
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

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
                _buildHorizontalFilter(
                  label: 'O que você busca?',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _transactionScrollController,
                  children: _transactionOptions.map((type) {
                    final isSelected = filters.transactionTypes.contains(type);
                    return AppChip(
                      label: type,
                      isSelected: isSelected,
                      onTap: () => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).toggleTransactionType(type),
                    );
                  }).toList(),
                ),

                // --- Property Type ---
                _buildHorizontalFilter(
                  label: 'Tipo de Imóvel',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _propertyTypeScrollController,
                  children: _propertyTypeOptions.map((type) {
                    final isSelected = filters.propertyTypes.contains(type);
                    return AppChip(
                      label: type,
                      isSelected: isSelected,
                      onTap: () => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).togglePropertyType(type),
                    );
                  }).toList(),
                ),

                // --- Bedrooms ---
                _buildHorizontalFilter(
                  label: 'Quartos',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _bedroomsScrollController,
                  children: [1, 2, 3, 4, 5].map((count) {
                    final isSelected = filters.bedrooms.contains(count);
                    return AppChip(
                      label: '$count+',
                      isSelected: isSelected,
                      onTap: () => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).toggleBedroom(count),
                    );
                  }).toList(),
                ),

                // --- Bathrooms ---
                _buildHorizontalFilter(
                  label: 'Banheiros',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _bathroomsScrollController,
                  children: [1, 2, 3, 4].map((count) {
                    final isSelected = filters.bathrooms.contains(count);
                    return AppChip(
                      label: '$count+',
                      isSelected: isSelected,
                      onTap: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .toggleBathroom(count),
                    );
                  }).toList(),
                ),

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

                // --- Area ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionLabel('Área (m²)', titleColor),
                    Text(
                      filters.areaRange == null
                          ? 'Qualquer'
                          : '${filters.areaRange!.start.toInt()} - ${filters.areaRange!.end.toInt()} m²',
                      style: AppTypography.labelLarge
                          .copyWith(color: accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                RangeSlider(
                  values: filters.areaRange ?? const RangeValues(0, 500),
                  max: 1000,
                  divisions: 50,
                  activeColor: accentColor,
                  inactiveColor: isDark
                      ? AppColors.blackLightest
                      : AppColors.lightBorder,
                  onChanged: (values) => ref
                      .read<SearchFiltersNotifier>(
                          searchFiltersProvider.notifier)
                      .updateAreaRange(values),
                ),
                if (filters.areaRange != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .updateAreaRange(null),
                      child: const Text('Limpar área'),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // --- State (UF) ---
                _buildSectionLabel('Estado (UF)', titleColor),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  hint: 'Ex: SP, RJ, MG',
                  prefixIcon: Icons.map_outlined,
                  controller: _stateController,
                  onChanged: (v) => ref
                      .read<SearchFiltersNotifier>(
                          searchFiltersProvider.notifier)
                      .updateState(v),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Amenities ---
                _buildHorizontalFilter(
                  label: 'Comodidades',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _amenitiesScrollController,
                  children: [
                    _AmenityData(
                        label: 'WiFi',
                        isSelected: filters.hasWifi,
                        onTap: () => ref.read(searchFiltersProvider.notifier).updateWifi(!filters.hasWifi)),
                    _AmenityData(
                        label: 'Piscina',
                        isSelected: filters.hasPool,
                        onTap: () => ref.read(searchFiltersProvider.notifier).updatePool(!filters.hasPool)),
                    _AmenityData(
                        label: 'Estacionamento',
                        isSelected: filters.hasParking,
                        onTap: () => ref.read(searchFiltersProvider.notifier).updateParking(!filters.hasParking)),
                    _AmenityData(
                        label: 'Aceita Pets',
                        isSelected: filters.isPetFriendly,
                        onTap: () => ref.read(searchFiltersProvider.notifier).updatePetFriendly(!filters.isPetFriendly)),
                  ].map((data) => AppChip(
                    label: data.label,
                    isSelected: data.isSelected,
                    onTap: data.onTap,
                  )).toList(),
                ),

                // --- Special filters (mobiliado / metrô / destaque) ---
                _buildHorizontalFilter(
                  label: 'Extras',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _specialScrollController,
                  children: [
                    _AmenityData(
                      label: 'Mobiliado',
                      isSelected: filters.isFurnished,
                      onTap: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .updateFurnished(!filters.isFurnished),
                    ),
                    _AmenityData(
                      label: 'Perto do metrô',
                      isSelected: filters.nearSubway,
                      onTap: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .updateNearSubway(!filters.nearSubway),
                    ),
                    _AmenityData(
                      label: 'Destaques',
                      isSelected: filters.isFeatured,
                      onTap: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .updateFeatured(!filters.isFeatured),
                    ),
                  ].map((data) => AppChip(
                        label: data.label,
                        isSelected: data.isSelected,
                        onTap: data.onTap,
                      )).toList(),
                ),

                // --- Near me ---
                _buildSectionLabel('Localização atual', titleColor),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: filters.latitude != null && filters.longitude != null
                      ? 'Desligar busca por proximidade'
                      : 'Buscar perto de mim (5 km)',
                  variant: AppButtonVariant.outline,
                  isLoading: _locatingUser,
                  onPressed: () => _toggleNearbySearch(
                    filters,
                    ref.read<SearchFiltersNotifier>(
                        searchFiltersProvider.notifier),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Order by ---
                _buildHorizontalFilter(
                  label: 'Ordenar por',
                  titleColor: titleColor,
                  accentColor: accentColor,
                  controller: _orderByScrollController,
                  children: _orderByOptions.map((opt) {
                    final isSelected = (filters.orderBy ?? 'isFeatured') ==
                        opt.apiValue;
                    return AppChip(
                      label: opt.label,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read<SearchFiltersNotifier>(
                              searchFiltersProvider.notifier)
                          .updateOrderBy(opt.apiValue),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

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

  Widget _buildHorizontalFilter({
    required String label,
    required List<Widget> children,
    required Color titleColor,
    required Color accentColor,
    required ScrollController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label, titleColor),
        const SizedBox(height: AppSpacing.md),
        Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(accentColor),
              trackColor: WidgetStateProperty.all(Colors.transparent),
              thickness: WidgetStateProperty.all(4),
              radius: const Radius.circular(10),
              interactive: true,
            ),
          ),
          child: Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: children.map((child) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: child,
                )).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
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
  _AmenityData({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
}

class _OrderByOption {
  const _OrderByOption(this.label, this.apiValue);
  final String label;
  final String apiValue;
}

const List<_OrderByOption> _orderByOptions = [
  _OrderByOption('Destaques', 'isFeatured'),
  _OrderByOption('Mais recentes', 'createdAt'),
  _OrderByOption('Mais vistos', 'views'),
  _OrderByOption('Menor preço', 'priceAsc'),
  _OrderByOption('Maior preço', 'priceDesc'),
  _OrderByOption('Mais próximos', 'nearest'),
];
