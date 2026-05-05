import '../../domain/entities/property.dart';
import '../../domain/entities/property_input.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_search_page.dart';

abstract class PropertyRemoteDataSource {
  Future<PropertySearchPage> searchProperties(
    SearchFilters filters, {
    int page = 1,
  });

  Future<Property> create(PropertyInput input);

  Future<Property> update(String id, PropertyInput input);

  Future<void> delete(String id);

  /// `PUT /api/properties/:id/moderation` — ADMIN.
  /// [decision] deve ser `APPROVED` ou `REJECTED`.
  /// [reason] é obrigatório quando decision=REJECTED.
  Future<Property> moderate({
    required String id,
    required String decision,
    String? reason,
  });
}

abstract class PropertyLocalDataSource {
  Future<List<Property>> getCachedProperties(SearchFilters filters, {int page = 1});
  Future<void> cacheProperties(SearchFilters filters, List<Property> properties, {int page = 1});
}
