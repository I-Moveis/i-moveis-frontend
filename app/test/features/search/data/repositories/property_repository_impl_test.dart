import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/data/repositories/property_repository_impl.dart';
import 'package:app/features/search/data/datasources/property_datasources.dart';
import 'package:app/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';

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

  final tFilters = const SearchFilters();
  const tPage = 1;
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

  group('searchProperties', () {
    test('should return remote data when remote fetch is successful and cache it', () async {
      // arrange
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tProperties);
      when(() => mockLocalDataSource.cacheProperties(any(), any(), page: any(named: 'page')))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.searchProperties(tFilters, page: tPage);

      // assert
      verify(() => mockRemoteDataSource.searchProperties(tFilters, page: tPage));
      verify(() => mockLocalDataSource.cacheProperties(tFilters, tProperties, page: tPage));
      expect(result.properties, tProperties);
      expect(result.isOffline, false);
    });

    test('should return cached data when remote fetch fails with SocketException (offline fallback)', () async {
      // arrange
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const SocketException('No internet'));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tProperties);

      // act
      final result = await repository.searchProperties(tFilters, page: tPage);

      // assert
      verify(() => mockRemoteDataSource.searchProperties(tFilters, page: tPage));
      verify(() => mockLocalDataSource.getCachedProperties(tFilters, page: tPage));
      expect(result.properties, tProperties);
      expect(result.isOffline, true);
    });

    test('should throw NetworkFailure when remote fails with SocketException and cache is empty', () async {
      // arrange
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(const SocketException('No internet'));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => []);

      // act
      final call = repository.searchProperties;

      // assert
      expect(() => call(tFilters, page: tPage), throwsA(isA<NetworkFailure>()));
    });

    test('should throw ServerFailure when remote fails with generic exception and cache is empty', () async {
      // arrange
      when(() => mockRemoteDataSource.searchProperties(any(), page: any(named: 'page')))
          .thenThrow(Exception('Server Error'));
      when(() => mockLocalDataSource.getCachedProperties(any(), page: any(named: 'page')))
          .thenAnswer((_) async => []);

      // act
      final call = repository.searchProperties;

      // assert
      expect(() => call(tFilters, page: tPage), throwsA(isA<ServerFailure>()));
    });
  });
}
