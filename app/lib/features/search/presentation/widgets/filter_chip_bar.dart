import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/app_chip.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../providers/search_filters_provider.dart';
import 'bedrooms_filter_modal.dart';
import 'price_filter_modal.dart';
import 'property_type_filter_modal.dart';
import 'filter_modal.dart';
import 'transaction_type_filter_modal.dart';

/// A horizontal bar of filter chips for the search page with multi-selection display.
class FilterChipBar extends ConsumerWidget {
  /// Creates a [FilterChipBar].
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch<SearchFilters>(searchFiltersProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
    );
  }

  String _getMultiSelectLabel(List<String> items, String defaultLabel) {
    if (items.isEmpty) return defaultLabel;
    if (items.length == 1) return items.first;
    return '${items.first} +${items.length - 1}';
  }
}
