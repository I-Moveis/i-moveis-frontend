import '../../domain/entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';

abstract class PropertyRemoteDataSource {
  Future<List<Property>> searchProperties(SearchFilters filters, {int page = 1});
}

abstract class PropertyLocalDataSource {
  Future<List<Property>> getCachedProperties(SearchFilters filters, {int page = 1});
  Future<void> cacheProperties(SearchFilters filters, List<Property> properties, {int page = 1});
}
