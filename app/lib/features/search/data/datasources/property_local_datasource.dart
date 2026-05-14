import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_model.dart';
import 'property_datasources.dart';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  static const String _boxName = 'properties_cache';
  static const Duration _cacheDuration = Duration(hours: 2);

  Future<Box<dynamic>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return Hive.openBox<dynamic>(_boxName);
    }
    return Hive.box<dynamic>(_boxName);
  }

  @override
  Future<List<Property>> getCachedProperties(SearchFilters filters, {int page = 1}) async {
    try {
      final box = await _getBox();
      final key = _generateKey(filters, page);
      final dynamic cachedEntry = box.get(key);

      if (cachedEntry == null || cachedEntry is! Map) return [];

      // Check expiration
      final timestampStr = cachedEntry['timestamp'] as String?;
      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        if (DateTime.now().difference(timestamp) > _cacheDuration) {
          await box.delete(key);
          return [];
        }
      }

      final data = cachedEntry['data'] as List<dynamic>? ?? [];

      return data.map((m) {
        if (m is! Map) return null;
        final map = Map<String, dynamic>.from(m);
        return PropertyModel.fromMap(map);
      }).whereType<Property>().toList();
    } on Exception {
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
      final data = properties.map(PropertyModel.toMap).toList();

      final entry = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      await box.put(key, entry);
    } on Exception {
      // Fail silently for cache
    }
  }

  String _generateKey(SearchFilters filters, int page) {
    // Use jsonEncode to create a unique key based on all filter parameters
    final filtersJson = jsonEncode(filters.toJson());
    // We use the hash of the JSON to keep the key length manageable while staying unique
    return 'search_${filtersJson.hashCode}_p$page';
  }
}
