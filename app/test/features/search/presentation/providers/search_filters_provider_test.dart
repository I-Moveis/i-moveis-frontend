import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:app/core/providers/shared_preferences_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SearchFiltersNotifier', () {
    late ProviderContainer container;
    late MockSharedPreferences mockPrefs;
    const filtersKey = 'search_filters';

    setUp(() {
      mockPrefs = MockSharedPreferences();
      
      // Default behavior: no saved filters
      when(() => mockPrefs.getString(filtersKey)).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be default when no filters are saved', () {
      final filters = container.read(searchFiltersProvider);
      expect(filters.location, '');
      expect(filters.bedrooms, isEmpty);
      expect(filters.priceRange, const RangeValues(0, 50000));
    });

    test('initial state should load from SharedPreferences when available', () {
      final savedFilters = {
        'location': 'Sao Paulo',
        'bedrooms': [2, 3],
        'minPrice': 1000.0,
        'maxPrice': 5000.0,
        'hasWifi': true,
      };
      
      when(() => mockPrefs.getString(filtersKey)).thenReturn(jsonEncode(savedFilters));

      // Re-initialize container to trigger load
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      final filters = container.read(searchFiltersProvider);
      expect(filters.location, 'Sao Paulo');
      expect(filters.bedrooms, [2, 3]);
      expect(filters.priceRange.start, 1000.0);
      expect(filters.priceRange.end, 5000.0);
      expect(filters.hasWifi, true);
    });

    test('initial state should be default if SharedPreferences has corrupted data', () {
      when(() => mockPrefs.getString(filtersKey)).thenReturn('invalid json');

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      final filters = container.read(searchFiltersProvider);
      expect(filters.location, '');
    });

    test('updateLocation should persist change', () async {
      container.read(searchFiltersProvider.notifier).updateLocation('New York');
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).location, 'New York');
    });

    test('toggleBedroom should persist change', () async {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.toggleBedroom(2);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).bedrooms, [2]);
      
      notifier.toggleBedroom(2);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).bedrooms, isEmpty);
    });

    test('updatePriceRange should persist change', () async {
      const newRange = RangeValues(500, 10000);
      container.read(searchFiltersProvider.notifier).updatePriceRange(newRange);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).priceRange, newRange);
    });

    test('toggleTransactionType should persist change', () async {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.toggleTransactionType('Rent');
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).transactionTypes, ['Rent']);
    });

    test('togglePropertyType should persist change', () async {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.togglePropertyType('House');
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).propertyTypes, ['House']);
    });

    test('updateWifi should persist change', () async {
      container.read(searchFiltersProvider.notifier).updateWifi(true);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).hasWifi, true);
    });

    test('updatePool should persist change', () async {
      container.read(searchFiltersProvider.notifier).updatePool(true);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).hasPool, true);
    });

    test('updateParking should persist change', () async {
      container.read(searchFiltersProvider.notifier).updateParking(true);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).hasParking, true);
    });

    test('updatePetFriendly should persist change', () async {
      container.read(searchFiltersProvider.notifier).updatePetFriendly(true);
      verify(() => mockPrefs.setString(filtersKey, any())).called(1);
      expect(container.read(searchFiltersProvider).isPetFriendly, true);
    });

    test('reset should persist default state to SharedPreferences', () async {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.updateWifi(true);
      notifier.reset();
      
      verify(() => mockPrefs.setString(filtersKey, any())).called(2);
      
      final filters = container.read(searchFiltersProvider);
      expect(filters.hasWifi, false);
    });
  });
}
