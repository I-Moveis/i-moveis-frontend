import 'package:hive/hive.dart';
import '../../domain/entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_model.dart';
import 'property_datasources.dart';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  static const String _boxName = 'properties_cache';

  @override
  Future<List<Property>> getCachedProperties(SearchFilters filters, {int page = 1}) async {
    final box = await Hive.openBox(_boxName);
    final key = _generateKey(filters, page);
    final List? cachedData = box.get(key);
    
    if (cachedData == null) return [];
    
    return cachedData.cast<PropertyModel>().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> cacheProperties(SearchFilters filters, List<Property> properties, {int page = 1}) async {
    // Only cache first 2 pages to save space as per strategy
    if (page > 2) return;

    final box = await Hive.openBox(_boxName);
    final key = _generateKey(filters, page);
    final models = properties.map((e) => PropertyModel.fromEntity(e)).toList();
    
    await box.put(key, models);
  }

  String _generateKey(SearchFilters filters, int page) {
    // Simple key generation based on filter properties
    // In a real app, this would be a hash of the filters object
    return 'search_${filters.transactionType}_${filters.propertyType}_p$page';
  }
}
