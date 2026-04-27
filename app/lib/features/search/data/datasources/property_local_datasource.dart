import 'package:hive/hive.dart';
import '../../domain/entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_model.dart';
import 'property_datasources.dart';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  static const String _boxName = 'properties_cache';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<List<Property>> getCachedProperties(SearchFilters filters, {int page = 1}) async {
    try {
      final box = await _getBox();
      final key = _generateKey(filters, page);
      final dynamic cachedData = box.get(key);
      
      if (cachedData is! List) return [];
      
      return cachedData.map((m) {
        if (m is! Map) return null;
        return PropertyModel.fromMap(Map<String, dynamic>.from(m));
      }).whereType<Property>().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheProperties(SearchFilters filters, List<Property> properties, {int page = 1}) async {
    // Only cache first 2 pages to save space as per strategy
    if (page > 2) return;

    try {
      final box = await _getBox();
      final key = _generateKey(filters, page);
      final data = properties.map((e) => PropertyModel.toMap(e)).toList();
      
      await box.put(key, data);
    } catch (e) {
      // Fail silently for cache
    }
  }

  String _generateKey(SearchFilters filters, int page) {
    // Generate a unique key based on the filter state
    final transactionPart = filters.transactionTypes.join(',');
    final propertyPart = filters.propertyTypes.join(',');
    final locationPart = filters.location;
    return 'search_${locationPart}_${transactionPart}_${propertyPart}_p$page';
  }
}
