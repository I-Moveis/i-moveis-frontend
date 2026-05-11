import 'favorite_datasources.dart';

/// Implementação em memória usada quando `kUseMockData` está ligado.
class FavoriteRemoteMockDataSource implements FavoriteRemoteDataSource {
  final Map<String, DateTime> _store = {};

  @override
  Future<void> toggleFavorite(String propertyId) async {
    if (_store.containsKey(propertyId)) {
      _store.remove(propertyId);
    } else {
      _store[propertyId] = DateTime.now();
    }
  }

  @override
  Future<void> removeFavorite(String propertyId) async {
    _store.remove(propertyId);
  }

  @override
  Future<bool> isPropertyFavorited(String propertyId) async {
    return _store.containsKey(propertyId);
  }

  @override
  Future<List<String>> listFavoriteIds() async {
    return _store.keys.toList();
  }

  @override
  Future<List<Map<String, dynamic>>> listFavoritesWithProperties() async {
    return _store.entries.map((e) => {
      'propertyId': e.key,
      'createdAt': e.value.toIso8601String(),
    }).toList()
      ..sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
  }
}
