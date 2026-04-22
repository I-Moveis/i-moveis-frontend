import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal for selecting multiple property types (e.g., Apartamento, Casa).
class PropertyTypeFilterModal extends ConsumerWidget {
  /// Creates a [PropertyTypeFilterModal].
  const PropertyTypeFilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final options = [
      'Apartamento',
      'Casa',
      'Studio',
      'Kitnet',
      'Cobertura',
      'Terreno',
      'Comercial',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(title: 'Tipo de Imóvel'),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: options.map((type) {
                  final isSelected = filters.propertyTypes.contains(type);
                  return AppChip(
                    label: type,
                    isSelected: isSelected,
                    onTap: () => ref.read(searchFiltersProvider.notifier).togglePropertyType(type),
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
