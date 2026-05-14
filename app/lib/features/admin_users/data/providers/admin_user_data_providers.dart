import 'package:app/core/constants.dart';
import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/admin_user_datasources.dart';
import '../datasources/admin_user_remote_api_datasource.dart';
import '../datasources/admin_user_remote_mock_datasource.dart';
import '../repositories/admin_user_repository_impl.dart';

final adminUserRemoteDataSourceProvider =
    Provider<AdminUserRemoteDataSource>((ref) {
  if (kUseMockData) {
    return AdminUserRemoteMockDataSource();
  }
  return AdminUserRemoteApiDataSource(ref.watch(dioProvider));
});

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserRepositoryImpl(ref.watch(adminUserRemoteDataSourceProvider));
});
