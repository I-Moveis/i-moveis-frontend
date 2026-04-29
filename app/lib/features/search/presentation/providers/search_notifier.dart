import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/property.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_filters_provider.dart';

class SearchState {

  SearchState({
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

  @override
  FutureOr<SearchState> build() async {
    // Watch filter changes to trigger rebuild
    ref.watch(searchFiltersProvider);

    _currentPage = 1;
    final result = await _fetchPage(1);
    return SearchState(
      properties: result.properties,
      isOffline: result.isOffline,
      hasReachedMax: result.properties.isEmpty,
    );
  }

  /// Initial search or search reset
  Future<void> search() async {
    _currentPage = 1;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(1);
      return SearchState(
        properties: result.properties,
        isOffline: result.isOffline,
        hasReachedMax: result.properties.isEmpty,
      );
    });
  }

  /// Loads the next page and appends to existing state
  Future<void> loadNextPage() async {
    if ((state.value?.hasReachedMax ?? false) || state.isLoading) return;

    final currentState = state.value;
    if (currentState == null) return;
    
    final nextPage = _currentPage + 1;

    final result = await AsyncValue.guard(() => _fetchPage(nextPage));

    result.when(
      data: (searchResult) {
        if (searchResult.properties.isEmpty) {
          state = AsyncValue.data(currentState.copyWith(hasReachedMax: true));
        } else {
          _currentPage = nextPage;
          state = AsyncValue.data(currentState.copyWith(
            properties: [...currentState.properties, ...searchResult.properties],
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
  }

  Future<SearchResult> _fetchPage(int page) async {
    final useCase = ref.read(searchPropertiesUseCaseProvider);
    final filters = ref.read(searchFiltersProvider);
    return useCase.execute(filters, page: page);
  }
}
