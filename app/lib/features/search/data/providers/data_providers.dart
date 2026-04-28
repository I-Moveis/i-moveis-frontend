import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/property_datasources.dart';
import '../datasources/property_remote_datasource.dart';
import '../datasources/property_local_datasource.dart';
import '../repositories/property_repository_impl.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/search_properties_usecase.dart';

final propertyRemoteDataSourceProvider = Provider<PropertyRemoteDataSource>((ref) {
  return PropertyRemoteDataSourceImpl();
});

final propertyLocalDataSourceProvider = Provider<PropertyLocalDataSource>((ref) {
  return PropertyLocalDataSourceImpl();
});

// Implement the provider that was referenced in domain
final dataPropertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final remote = ref.watch(propertyRemoteDataSourceProvider);
  final local = ref.watch(propertyLocalDataSourceProvider);
  return PropertyRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

// Override the domain provider
final propertyRepositoryProviderOverride = propertyRepositoryProvider.overrideWith((ref) {
  return ref.watch(dataPropertyRepositoryProvider);
});
