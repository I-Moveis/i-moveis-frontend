import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/property.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_filters_provider.dart';

class SearchState {

  const SearchState({
    required this.properties,
    this.isOffline = false,
    this.hasReachedMax = false,
  });
  final List<Property> properties;
  final bool isOffline;
  final bool hasReachedMax;

  SearchState copyWith({
    List<Property>? properties,
    bool? isOffline,
    bool? hasReachedMax,
  }) {
    return SearchState(
      properties: properties ?? this.properties,
      isOffline: isOffline ?? this.isOffline,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// Provider for SearchNotifier.
final searchNotifierProvider = AsyncNotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

/// Provider to trigger scroll to top on SearchPage when tapping the nav bar icon
class ScrollTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void trigger() => state++;
}

final searchScrollTriggerProvider =
    NotifierProvider<ScrollTriggerNotifier, int>(ScrollTriggerNotifier.new);

class SearchNotifier extends AsyncNotifier<SearchState> {
  int _currentPage = 1;

  /// Sequência monotônica que identifica a "geração" da busca vigente.
  /// Incrementada antes de cada fetch; ao resolver, comparamos o seq local
  /// com este valor — se divergir, outra request foi disparada e este
  /// resultado está obsoleto (stale) e deve ser descartado. Evita que uma
  /// resposta lenta sobrescreva uma resposta recente (race condition).
  int _requestSeq = 0;

  /// Guard explícito para `loadNextPage`. `state.isLoading` não funciona
  /// porque a paginação não muda o AsyncValue para loading (mantém os
  /// itens visíveis enquanto carrega a próxima página). Sem este flag,
  /// cada frame do scroll que atingir o limite dispara uma nova request.
  bool _isLoadingNextPage = false;

  @override
  FutureOr<SearchState> build() async {
    // Watch filter changes to trigger rebuild
    ref.watch(searchFiltersProvider);

    _currentPage = 1;
    final seq = ++_requestSeq;
    final result = await _fetchPage(1);
    if (seq != _requestSeq) {
      // Resposta obsoleta; devolve estado neutro e deixa a build mais
      // recente preencher o state.
      return const SearchState(properties: []);
    }
    return SearchState(
      properties: result.properties,
      isOffline: result.isOffline,
      hasReachedMax: result.properties.isEmpty,
    );
  }

  /// Initial search or search reset
  Future<void> search() async {
    _currentPage = 1;
    final seq = ++_requestSeq;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(1);
      if (seq != _requestSeq) {
        throw const _StaleResponseException();
      }
      return SearchState(
        properties: result.properties,
        isOffline: result.isOffline,
        hasReachedMax: result.properties.isEmpty,
      );
    });
  }

  /// Loads the next page and appends to existing state
  Future<void> loadNextPage() async {
    if (_isLoadingNextPage ||
        (state.value?.hasReachedMax ?? false) ||
        state.isLoading) {
      return;
    }

    final currentState = state.value;
    if (currentState == null) return;

    _isLoadingNextPage = true;
    try {
      final nextPage = _currentPage + 1;
      final seq = ++_requestSeq;

      final result = await AsyncValue.guard(() => _fetchPage(nextPage));

      // Descarte silencioso se outra request já foi disparada no meio-tempo.
      if (seq != _requestSeq) return;

      result.when(
        data: (searchResult) {
          if (searchResult.properties.isEmpty) {
            state = AsyncValue.data(currentState.copyWith(hasReachedMax: true));
          } else {
            _currentPage = nextPage;
            state = AsyncValue.data(currentState.copyWith(
              properties: [
                ...currentState.properties,
                ...searchResult.properties,
              ],
              isOffline: searchResult.isOffline, // Update offline status
            ));
          }
        },
        error: (err, stack) {
          // Keep previous data visible while surfacing the error for pagination failures.
          state = AsyncValue<SearchState>.error(err, stack);
        },
        loading: () {},
      );
    } finally {
      _isLoadingNextPage = false;
    }
  }

  Future<SearchResult> _fetchPage(int page) async {
    final useCase = ref.read(searchPropertiesUseCaseProvider);
    final filters = ref.read(searchFiltersProvider);
    return useCase.execute(filters, page: page);
  }
}

/// Exceção interna: marca uma resposta como obsoleta (nova request foi
/// disparada antes desta resolver). Não é exposta ao usuário — é
/// capturada pelo `AsyncValue.guard` e convertida em erro silencioso.
class _StaleResponseException implements Exception {
  const _StaleResponseException();
}
