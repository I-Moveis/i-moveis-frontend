import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/favorite_datasources.dart';
import '../datasources/favorite_remote_api_datasource.dart';

final favoriteRemoteDataSourceProvider = Provider<FavoriteRemoteDataSource>((ref) {
  return FavoriteApiDataSource(ref.watch(dioProvider));
});
