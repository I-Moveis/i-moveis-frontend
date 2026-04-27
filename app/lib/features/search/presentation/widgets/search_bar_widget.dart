import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';
import 'search_filter_modal.dart';

/// Collapsed search bar "Pill" that allows typing and triggers filters with suggestions.
class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({super.key});

  static const List<String> _mockSuggestions = [
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

  void _openFilters(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (context) => const SearchFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch<SearchFilters>(searchFiltersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _mockSuggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updateLocation(selection);
      },
      initialValue: TextEditingValue(text: filters.location),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AppSearchBar(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => ref.read<SearchFiltersNotifier>(searchFiltersProvider.notifier).updateLocation(value),
          onFilterTap: () => _openFilters(context),
          autofocus: false,
          hint: 'Cidade, bairro ou endereço...',
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: AppRadius.borderMd,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Container(
              width: MediaQuery.of(context).size.width - AppSpacing.screenHorizontal * 2,
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
                    title: Text(
                      option, 
                      style: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.title(isDark)),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
