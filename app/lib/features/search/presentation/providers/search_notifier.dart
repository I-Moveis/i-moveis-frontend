import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_filters_provider.dart';

// Provider for SearchNotifier.
final searchNotifierProvider = AsyncNotifierProvider<SearchNotifier, List<Property>>(
  SearchNotifier.new,
);

/// Provider to trigger scroll to top on SearchPage when tapping the nav bar icon
class ScrollTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void trigger() => state++;
}

final searchScrollTriggerProvider = NotifierProvider<ScrollTriggerNotifier, int>(ScrollTriggerNotifier.new);

class SearchNotifier extends AsyncNotifier<List<Property>> {
  int _currentPage = 1;
  bool _hasReachedMax = false;

  @override
  FutureOr<List<Property>> build() async {
    // Watch filter changes to trigger rebuild
    ref.watch(searchFiltersProvider);

    _currentPage = 1;
    _hasReachedMax = false;
    return _fetchPage(1);
  }

  /// Initial search or search reset
  Future<void> search() async {
    _currentPage = 1;
    _hasReachedMax = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  /// Loads the next page and appends to existing state
  Future<void> loadNextPage() async {
    if (_hasReachedMax || state.isLoading) return;

    final currentProperties = state.value ?? [];
    
    // Set loading state but keep previous data to allow "retry" or show previous items
    // Riverpod 2.0 AsyncValue.guard with data is a bit tricky, 
    // we can use state = AsyncValue.loading() but it will lose data in UI if not handled.
    // Better to just fetch and update state.
    
    final nextPage = _currentPage + 1;
    
    final result = await AsyncValue.guard(() => _fetchPage(nextPage));
    
    result.when(
      data: (newProperties) {
        if (newProperties.isEmpty) {
          _hasReachedMax = true;
        } else {
          _currentPage = nextPage;
          state = AsyncValue.data([...currentProperties, ...newProperties]);
        }
      },
      error: (err, stack) {
        // Keep previous data but set error
        state = AsyncError<List<Property>>(err, stack).copyWithPrevious(state);
      },
      loading: () {},
    );
  }

  Future<List<Property>> _fetchPage(int page) async {
    final useCase = ref.read(searchPropertiesUseCaseProvider);
    final filters = ref.read(searchFiltersProvider);
    return useCase.execute(filters, page: page);
  }
}
