import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';

/// Modal for selecting multiple transaction types (e.g., Aluguel, Comprar).
class TransactionTypeFilterModal extends ConsumerWidget {
  /// Creates a [TransactionTypeFilterModal].
  const TransactionTypeFilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final options = ['Aluguel', 'Comprar', 'Lançamentos'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(title: 'O que você busca?'),
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
                  final isSelected = filters.transactionTypes.contains(type);
                  return AppChip(
                    label: type,
                    isSelected: isSelected,
                    onTap: () => ref.read(searchFiltersProvider.notifier).toggleTransactionType(type),
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
