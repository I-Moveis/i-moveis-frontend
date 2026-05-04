import 'package:app/core/constants.dart';
import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_api_datasource.dart';
import '../datasources/admin_remote_datasource.dart';
import '../datasources/admin_remote_mock_datasource.dart';
import '../repositories/admin_repository_impl.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  if (kUseMockData) {
    return AdminRemoteMockDataSource();
  }
  return AdminRemoteApiDataSource(ref.watch(dioProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(adminRemoteDataSourceProvider));
});
