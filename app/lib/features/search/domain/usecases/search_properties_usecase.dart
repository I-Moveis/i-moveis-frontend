import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';
import '../../presentation/providers/search_filters_provider.dart';

/// Provider for the SearchPropertiesUseCase.
final searchPropertiesUseCaseProvider = Provider<SearchPropertiesUseCase>((ref) {
  // Repository will be provided by another provider
  final repository = ref.watch(propertyRepositoryProvider);
  return SearchPropertiesUseCaseImpl(repository);
});

// Interface is already defined in repositories/property_repository.dart
// But for consistency with the existing code, I'll keep it here if needed or just use the one from repository.
// Actually, the original file had the abstract class. I'll move it to repository.dart and leave it here as a re-export or just use the one from there.

class SearchResult {
  final List<Property> properties;
  final bool isOffline;

  SearchResult({required this.properties, required this.isOffline});
}

abstract class SearchPropertiesUseCase {
  Future<SearchResult> execute(SearchFilters filters, {int page = 1});
}

class SearchPropertiesUseCaseImpl implements SearchPropertiesUseCase {
  final PropertyRepository _repository;

  SearchPropertiesUseCaseImpl(this._repository);

  @override
  Future<SearchResult> execute(SearchFilters filters, {int page = 1}) async {
    return _repository.searchProperties(filters, page: page);
  }
}

// Placeholder for repository provider, will be moved/implemented in data layer
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  throw UnimplementedError();
});
