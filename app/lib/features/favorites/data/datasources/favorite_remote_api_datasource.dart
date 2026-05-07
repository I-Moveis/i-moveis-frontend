import 'package:dio/dio.dart';

import '../../domain/entities/favorite.dart';
import '../models/favorite_api_model.dart';
import 'favorite_datasources.dart';

/// Implementação real contra `/api/favorites*`. Dio é esperado já
/// configurado com baseUrl + AuthInterceptor (Bearer JWT).
class FavoriteRemoteApiDataSource implements FavoriteRemoteDataSource {
  FavoriteRemoteApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<Favorite>> list() async {
    final res = await _dio.get<List<dynamic>>('/favorites');
    final data = res.data ?? const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => favoriteFromApiJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Favorite> add(String propertyId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/favorites',
      data: {'propertyId': propertyId},
    );
    return favoriteFromApiJson(res.data ?? const {});
  }

  @override
  Future<void> remove(String propertyId) async {
    await _dio.delete<void>('/favorites/$propertyId');
  }

  @override
  Future<bool> check(String propertyId) async {
    final res =
        await _dio.get<Map<String, dynamic>>('/favorites/$propertyId/check');
    return (res.data?['favorited'] as bool?) ?? false;
  }
}
