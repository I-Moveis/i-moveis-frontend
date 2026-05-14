import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Provider for the SearchPropertiesUseCase.
final searchPropertiesUseCaseProvider = Provider<SearchPropertiesUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return SearchPropertiesUseCaseImpl(repository);
});

class SearchResult {

  SearchResult({
    required this.properties,
    required this.isOffline,
    this.totalResults = 0,
    this.currentPage = 1,
    this.hasNextPage = false,
  });
  final List<Property> properties;
  final bool isOffline;
  final int totalResults;
  final int currentPage;
  final bool hasNextPage;
}

// Contract for search use case — abstract to allow mocking in tests and
// swapping mock impl for a real API-backed one without touching callers.
// ignore: one_member_abstracts
abstract class SearchPropertiesUseCase {
  Future<SearchResult> execute(SearchFilters filters, {int page = 1});
}

class SearchPropertiesUseCaseImpl implements SearchPropertiesUseCase {

  SearchPropertiesUseCaseImpl(this._repository);
  final PropertyRepository _repository;

  @override
  Future<SearchResult> execute(SearchFilters filters, {int page = 1}) async {
    return _repository.searchProperties(filters, page: page);
  }
}

// Placeholder for repository provider, will be moved/implemented in data layer
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  throw UnimplementedError();
});
