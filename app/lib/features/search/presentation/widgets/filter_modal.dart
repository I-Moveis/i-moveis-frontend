import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Specific filter modal for Amenities (Comodidades).
class FilterModal extends ConsumerWidget {
  /// Creates a [FilterModal].
  const FilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch<SearchFilters>(searchFiltersProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBottomSheetHeader(title: 'Comodidades'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: [
                  _buildAmenityChip('WiFi', filters.hasWifi, (val) => ref.read(searchFiltersProvider.notifier).updateWifi(val), ref),
                  _buildAmenityChip('Piscina', filters.hasPool, (val) => ref.read(searchFiltersProvider.notifier).updatePool(val), ref),
                  _buildAmenityChip('Estacionamento', filters.hasParking, (val) => ref.read(searchFiltersProvider.notifier).updateParking(val), ref),
                  _buildAmenityChip('Aceita Pets', filters.isPetFriendly, (val) => ref.read(searchFiltersProvider.notifier).updatePetFriendly(val), ref),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // --- Action Buttons ---
              SizedBox(
                width: double.infinity,
                child: BrutalistGradientButton(
                  label: 'APLICAR FILTRO',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildAmenityChip(String label, bool value, ValueChanged<bool> onChanged, WidgetRef ref) {
    return AppChip(
      label: label,
      isSelected: value,
      onTap: () => onChanged(!value),
    );
  }
}
