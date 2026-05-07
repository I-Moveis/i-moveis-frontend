import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_datasources.dart';
import '../datasources/favorite_remote_api_datasource.dart';
import '../datasources/favorite_remote_mock_datasource.dart';
import '../repositories/favorite_repository_impl.dart';

final favoriteRemoteDataSourceProvider =
    Provider<FavoriteRemoteDataSource>((ref) {
  if (kUseMockData) {
    return FavoriteRemoteMockDataSource();
  }
  return FavoriteRemoteApiDataSource(ref.watch(dioProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(ref.watch(favoriteRemoteDataSourceProvider));
});
