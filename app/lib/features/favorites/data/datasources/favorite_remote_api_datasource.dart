import 'package:dio/dio.dart';

import 'favorite_datasources.dart';

/// Talks to the I-Moveis favorites API endpoints.
///
/// * `POST   /favorites`          — add a favorite
/// * `GET    /favorites`          — list favorites (with property details)
/// * `DELETE /favorites/:id`      — remove a favorite
/// * `GET    /favorites/:id/check`— check if favorited
class FavoriteApiDataSource implements FavoriteRemoteDataSource {
  FavoriteApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<void> toggleFavorite(String propertyId) async {
    await _dio.post<void>(
      '/favorites',
      data: {'propertyId': propertyId},
    );
  }

  @override
  Future<void> removeFavorite(String propertyId) async {
    await _dio.delete<void>('/favorites/$propertyId');
  }

  @override
  Future<bool> isPropertyFavorited(String propertyId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/favorites/$propertyId/check',
    );
    return response.data?['favorited'] == true;
  }

  @override
  Future<List<String>> listFavoriteIds() async {
    final response = await _dio.get<List<dynamic>>('/favorites');
    final data = response.data ?? [];
    return data
        .map((f) => (f as Map<String, dynamic>)['propertyId'] as String)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> listFavoritesWithProperties() async {
    final response = await _dio.get<List<dynamic>>('/favorites');
    final data = response.data ?? [];
    return data.cast<Map<String, dynamic>>();
  }
}
