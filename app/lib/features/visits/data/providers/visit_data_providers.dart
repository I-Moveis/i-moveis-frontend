import 'package:app/core/constants.dart';
import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_datasources.dart';
import '../datasources/visit_remote_api_datasource.dart';
import '../datasources/visit_remote_mock_datasource.dart';
import '../repositories/visit_repository_impl.dart';

final visitRemoteDataSourceProvider = Provider<VisitRemoteDataSource>((ref) {
  if (kUseMockData) {
    return VisitRemoteMockDataSource();
  }
  return VisitRemoteApiDataSource(ref.watch(dioProvider));
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return VisitRepositoryImpl(ref.watch(visitRemoteDataSourceProvider));
});
