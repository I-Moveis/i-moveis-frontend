import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';

void main() {
  group('SearchFiltersNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be default', () {
      final filters = container.read(searchFiltersProvider);
      expect(filters.location, '');
      expect(filters.bedrooms, 0);
      expect(filters.hasWifi, false);
      expect(filters.hasPool, false);
      expect(filters.hasParking, false);
      expect(filters.isPetFriendly, false);
    });

    test('updateWifi should change state', () {
      container.read(searchFiltersProvider.notifier).updateWifi(true);
      final filters = container.read(searchFiltersProvider);
      expect(filters.hasWifi, true);
    });

    test('updatePool should change state', () {
      container.read(searchFiltersProvider.notifier).updatePool(true);
      final filters = container.read(searchFiltersProvider);
      expect(filters.hasPool, true);
    });

    test('updateParking should change state', () {
      container.read(searchFiltersProvider.notifier).updateParking(true);
      final filters = container.read(searchFiltersProvider);
      expect(filters.hasParking, true);
    });

    test('updatePetFriendly should change state', () {
      container.read(searchFiltersProvider.notifier).updatePetFriendly(true);
      final filters = container.read(searchFiltersProvider);
      expect(filters.isPetFriendly, true);
    });

    test('reset should revert to default state', () {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.updateWifi(true);
      notifier.updatePool(true);
      notifier.reset();
      
      final filters = container.read(searchFiltersProvider);
      expect(filters.hasWifi, false);
      expect(filters.hasPool, false);
    });
  });
}
