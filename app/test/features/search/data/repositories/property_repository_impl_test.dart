import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:app/features/search/data/datasources/property_datasources.dart';
import 'package:app/features/search/data/models/property_search_page.dart';
import 'package:app/features/search/data/repositories/property_repository_impl.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements PropertyRemoteDataSource {}
class MockLocalDataSource extends Mock implements PropertyLocalDataSource {}

void main() {
  late PropertyRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = PropertyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tFilters = SearchFilters();
  final tProperties = [
    const Property(
      id: '1',
      title: 'Test Property',
      latitude: 0,
      longitude: 0,
      price: r'R$ 1.000',
      priceValue: 1000,
      description: 'Test description',
      type: 'Apartamento',
      area: 50,
      bedrooms: 1,
      bathrooms: 1,
      parkingSpots: 1,
    ),
  ];
  final tPage = PropertySearchPage(
    properties: tProperties,
    total: 1,
    page: 1,
    totalPages: 1,
  );

  group('searchProperties', () {
    test('returns remote data on success and caches it', () async {
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tPage);
      when(() => mockLocalDataSource.cacheProperties(any(), any(), page: any(named: 'page')))
          .thenAnswer((_) async => {});

      final result = await repository.searchProperties(tFilters);

      verify(() => mockRemoteDataSource.searchProperties(tFilters));
      verify(() => mockLocalDataSource.cacheProperties(tFilters, tProperties));
      expect(result.properties, tProperties);
      expect(result.isOffline, false);
      expect(result.totalResults, 1);
      expect(result.hasNextPage, false);
    });

    test('falls back to cache on noConnection and flags offline', () async {
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const NetworkException(
        kind: NetworkErrorKind.noConnection,
        message: 'offline',
      ));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tProperties);

      final result = await repository.searchProperties(tFilters);

      verify(() => mockLocalDataSource.getCachedProperties(tFilters));
      expect(result.properties, tProperties);
      expect(result.isOffline, true);
    });

    test('throws NetworkFailure when noConnection and cache empty', () async {
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const NetworkException(
        kind: NetworkErrorKind.noConnection,
        message: 'offline',
      ));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => []);

      expect(
        () => repository.searchProperties(tFilters),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('throws ServerFailure on serverError and cache empty', () async {
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const NetworkException(
        kind: NetworkErrorKind.serverError,
        message: '500',
      ));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => []);

      expect(
        () => repository.searchProperties(tFilters),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('falls back to cache on serverError without offline flag? (serves stale as offline)', () async {
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const NetworkException(
        kind: NetworkErrorKind.serverError,
        message: '500',
      ));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tProperties);

      final result = await repository.searchProperties(tFilters);

      expect(result.properties, tProperties);
      expect(result.isOffline, true);
    });
  });
}
