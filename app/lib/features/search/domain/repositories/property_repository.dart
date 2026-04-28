import '../entities/property.dart';
import '../usecases/search_properties_usecase.dart';
import '../../presentation/providers/search_filters_provider.dart';

abstract class PropertyRepository {
  Future<SearchResult> searchProperties(SearchFilters filters, {int page = 1});
}
