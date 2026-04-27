import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal for selecting multiple bedroom counts.
class BedroomsFilterModal extends ConsumerWidget {
  /// Creates a [BedroomsFilterModal].
  const BedroomsFilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final options = [1, 2, 3, 4, 5];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(title: 'Quartos'),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: options.map((count) {
                  final label = '$count+';
                  final isSelected = filters.bedrooms.contains(count);
                  return AppChip(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => ref.read(searchFiltersProvider.notifier).toggleBedroom(count),
                  );
                }).toList(),
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
