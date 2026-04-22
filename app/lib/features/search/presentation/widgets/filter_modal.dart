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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final titleColor = BrutalistPalette.title(isDark);

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
                
                _buildToggleItem(
                  'WiFi',
                  filters.hasWifi,
                  (val) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updateWifi(val),
                  isDark,
                  accentColor,
                ),
                _buildToggleItem(
                  'Piscina',
                  filters.hasPool,
                  (val) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updatePool(val),
                  isDark,
                  accentColor,
                ),
                _buildToggleItem(
                  'Estacionamento',
                  filters.hasParking,
                  (val) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updateParking(val),
                  isDark,
                  accentColor,
                ),
                _buildToggleItem(
                  'Aceita Pets',
                  filters.isPetFriendly,
                  (val) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updatePetFriendly(val),
                  isDark,
                  accentColor,
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

  Widget _buildToggleItem(
    String label, 
    bool value, 
    ValueChanged<bool> onChanged,
    bool isDark,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: BrutalistPalette.dividerColor(isDark),
            width: 0.5,
          ),
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
