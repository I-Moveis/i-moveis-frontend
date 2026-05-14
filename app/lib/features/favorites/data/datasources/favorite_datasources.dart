/// Abstract interface for the favorites remote data source.
abstract class FavoriteRemoteDataSource {
  Future<void> toggleFavorite(String propertyId);
  Future<void> removeFavorite(String propertyId);
  Future<bool> isPropertyFavorited(String propertyId);
  Future<List<String>> listFavoriteIds();
  Future<List<Map<String, dynamic>>> listFavoritesWithProperties();
}
