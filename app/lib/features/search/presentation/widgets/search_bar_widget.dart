import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';
import 'search_filter_modal.dart';

/// Collapsed search bar "Pill" that triggers the filter modal.
class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({super.key});

  void _openFilters(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (context) => const SearchFilterModal(),
    );

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final mutedColor = BrutalistPalette.muted(isDark);
    final faintColor = BrutalistPalette.faint(isDark);

    // Build summary text
    var summary = filters.location.isEmpty ? 'Cidade, bairro ou endereço...' : filters.location;

    if (filters.bedrooms > 0) {
      summary += ' • ${filters.bedrooms}+ qtos';
    }
    if (filters.priceRange.start > 0 || filters.priceRange.end < 50000) {
      summary += ' • R\$${filters.priceRange.start.toInt()} - R\$${filters.priceRange.end.toInt()}';
    }

    return GestureDetector(
      onTap: () => _openFilters(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.mdLg,
        ),
        decoration: BoxDecoration(
          color: BrutalistPalette.surfaceBg(isDark),
          borderRadius: AppRadius.borderRound,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: mutedColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                summary,
                style: AppTypography.bodySmall.copyWith(
                  color: filters.location.isEmpty ? faintColor : mutedColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: BrutalistPalette.dividerColor(isDark),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(Icons.tune_rounded, size: 18, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
