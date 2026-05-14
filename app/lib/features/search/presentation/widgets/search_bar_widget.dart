import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';
import 'search_filter_modal.dart';

/// Collapsed search bar "Pill" that allows typing and triggers filters with suggestions.
///
/// O `onChanged` do input é debounced em 400ms antes de atualizar o
/// `searchFiltersProvider` — evita uma requisição por tecla digitada.
class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  static const Duration _kDebounce = Duration(milliseconds: 400);

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

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _applyLocation(String value) {
    ref
        .read<SearchFiltersNotifier>(searchFiltersProvider.notifier)
        .updateLocation(value);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_kDebounce, () {
      if (!mounted) return;
      _applyLocation(value);
    });
  }

  void _onSelected(String selection) {
    _debounce?.cancel();
    _applyLocation(selection);
  }

  void _openFilters(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (context) => const SearchFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      onSelected: _onSelected,
      initialValue: TextEditingValue(text: filters.location),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AppSearchBar(
          controller: controller,
          focusNode: focusNode,
          onChanged: _onChanged,
          onFilterTap: () => _openFilters(context),
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
