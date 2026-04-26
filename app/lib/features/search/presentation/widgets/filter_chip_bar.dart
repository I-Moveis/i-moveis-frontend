import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/app_chip.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/brutalist_palette.dart';
import '../providers/search_filters_provider.dart';
import 'bedrooms_filter_modal.dart';
import 'price_filter_modal.dart';
import 'property_type_filter_modal.dart';
import 'filter_modal.dart';
import 'transaction_type_filter_modal.dart';

/// A horizontal bar of filter chips for the search page with a scroll indicator.
class FilterChipBar extends ConsumerStatefulWidget {
  const FilterChipBar({super.key});

  @override
  ConsumerState<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends ConsumerState<FilterChipBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch<SearchFilters>(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.dragged) || states.contains(WidgetState.hovered)) {
                  return BrutalistPalette.accentOrange(isDark);
                }
                return BrutalistPalette.accentOrange(isDark);
              }),
              trackColor: WidgetStateProperty.all(Colors.transparent),
              thickness: WidgetStateProperty.all(4.0),
              radius: const Radius.circular(AppRadius.full),
              interactive: true,
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md, // Further increased space from the chips
              ),
              child: Row(
                children: [
                  // Transaction Type(s)
                  AppChip(
                    label: _getMultiSelectLabel(filters.transactionTypes, 'Busca'),
                    isSelected: filters.transactionTypes.isNotEmpty,
                    onTap: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (context) => const TransactionTypeFilterModal(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Property Type(s)
                  AppChip(
                    label: _getMultiSelectLabel(filters.propertyTypes, 'Tipo'),
                    isSelected: filters.propertyTypes.isNotEmpty,
                    onTap: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (context) => const PropertyTypeFilterModal(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Bedrooms
                  AppChip(
                    label: filters.bedrooms.isEmpty 
                        ? 'Quartos' 
                        : '${filters.bedrooms.join(', ')} qtos',
                    isSelected: filters.bedrooms.isNotEmpty,
                    onTap: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (context) => const BedroomsFilterModal(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Price
                  AppChip(
                    label: 'Preço',
                    isSelected: filters.priceRange.start > 0 || filters.priceRange.end < 50000,
                    onTap: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (context) => const PriceFilterModal(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Amenities
                  AppChip(
                    label: 'Comodidades',
                    isSelected: filters.hasWifi || filters.hasPool || filters.hasParking || filters.isPetFriendly,
                    onTap: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (context) => const FilterModal(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMultiSelectLabel(List<String> items, String defaultLabel) {
    if (items.isEmpty) return defaultLabel;
    if (items.length == 1) return items.first;
    return '${items.first} +${items.length - 1}';
  }
}
