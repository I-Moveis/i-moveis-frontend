import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../datasources/property_datasources.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<SearchResult> searchProperties(SearchFilters filters, {int page = 1}) async {
    try {
      final remoteProperties = await remoteDataSource.searchProperties(filters, page: page);
      
      // Update cache
      await localDataSource.cacheProperties(filters, remoteProperties, page: page);
      
      return SearchResult(properties: remoteProperties, isOffline: false);
    } catch (e) {
      // Fallback to local cache
      final cachedProperties = await localDataSource.getCachedProperties(filters, page: page);
      
      if (cachedProperties.isNotEmpty) {
        return SearchResult(properties: cachedProperties, isOffline: true);
      }
      
      // If cache is also empty, rethrow error
      rethrow;
    }
  }
}
