import '../../presentation/providers/search_filters_provider.dart';
import '../entities/property.dart';
import '../entities/property_input.dart';
import '../usecases/search_properties_usecase.dart';

abstract class PropertyRepository {
  Future<SearchResult> searchProperties(SearchFilters filters, {int page = 1});

  Future<Property> create(PropertyInput input);

  Future<Property> update(String id, PropertyInput input);

  Future<void> delete(String id);
}
