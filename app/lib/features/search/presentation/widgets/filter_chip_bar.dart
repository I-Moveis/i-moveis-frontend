import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/app_chip.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../providers/search_filters_provider.dart';
import 'bedrooms_filter_modal.dart';
import 'price_filter_modal.dart';
import 'property_type_filter_modal.dart';
import 'search_filter_modal.dart';
import 'transaction_type_filter_modal.dart';

/// A horizontal bar of filter chips for the search page.
class FilterChipBar extends ConsumerWidget {
  /// Creates a [FilterChipBar].
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          AppChip(
            label: filters.transactionType,
            isSelected: true,
            onTap: () => showAppBottomSheet<void>(
              context: context,
              builder: (context) => const TransactionTypeFilterModal(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: filters.propertyType ?? 'Tipo',
            isSelected: filters.propertyType != null,
            onTap: () => showAppBottomSheet<void>(
              context: context,
              builder: (context) => const PropertyTypeFilterModal(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: filters.bedrooms == 0 ? 'Quartos' : '${filters.bedrooms}+ qtos',
            isSelected: filters.bedrooms > 0,
            onTap: () => showAppBottomSheet<void>(
              context: context,
              builder: (context) => const BedroomsFilterModal(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Preço',
            isSelected: filters.priceRange.start > 0 || filters.priceRange.end < 50000,
            onTap: () => showAppBottomSheet<void>(
              context: context,
              builder: (context) => const PriceFilterModal(),
            ),
          ),
        ],
      ),
    );
  }
}
