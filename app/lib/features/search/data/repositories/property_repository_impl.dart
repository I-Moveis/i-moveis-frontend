import 'dart:io';
import 'package:app/core/error/failures.dart';
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
      // Network-First strategy
      final remoteProperties = await remoteDataSource.searchProperties(filters, page: page);
      
      // Update cache
      await localDataSource.cacheProperties(filters, remoteProperties, page: page);
      
      return SearchResult(
        properties: remoteProperties, 
        isOffline: false,
        currentPage: page,
        hasNextPage: remoteProperties.length >= 10, // Assuming 10 is the page size
      );
    } on SocketException {
      return await _handleOfflineFallback(filters, page, isNetworkError: true);
    } catch (e) {
      // For any other error (e.g. 500), also try fallback
      try {
        return await _handleOfflineFallback(filters, page, isNetworkError: false);
      } catch (fallbackError) {
        // If fallback also fails or cache is empty, map the original error
        if (fallbackError is Failure) rethrow;
        throw const ServerFailure();
      }
    }
  }

  Future<SearchResult> _handleOfflineFallback(
    SearchFilters filters, 
    int page, 
    {required bool isNetworkError}
  ) async {
    final cachedProperties = await localDataSource.getCachedProperties(filters, page: page);
    
    if (cachedProperties.isNotEmpty) {
      return SearchResult(
        properties: cachedProperties, 
        isOffline: true,
        currentPage: page,
        hasNextPage: false, // Limited info in cache fallback
      );
    }
    
    // If cache is empty, throw specific failure based on the original cause
    if (isNetworkError) {
      throw const NetworkFailure();
    } else {
      throw const ServerFailure();
    }
  }
}
