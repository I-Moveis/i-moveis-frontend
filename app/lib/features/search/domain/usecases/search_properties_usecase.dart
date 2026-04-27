import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/search_filters_provider.dart';
import '../entities/property.dart';

/// Provider for the SearchPropertiesUseCase.
/// This allows mocking the use case in tests.
final searchPropertiesUseCaseProvider =
    Provider<SearchPropertiesUseCase>((ref) {
  return SearchPropertiesUseCaseImpl();
});

// Contract for search use case — abstract to allow mocking in tests and
// swapping mock impl for a real API-backed one without touching callers.
// ignore: one_member_abstracts
abstract class SearchPropertiesUseCase {
  Future<List<Property>> execute(SearchFilters filters, {int page = 1});
}

class SearchPropertiesUseCaseImpl implements SearchPropertiesUseCase {
  @override
  Future<List<Property>> execute(SearchFilters filters, {int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return List.generate(10, (index) {
      final id = 'prop-$page-$index';
      final basePrice = (2000 + index * 100).toDouble();
      return Property(
        id: id,
        title: 'Property $id',
        latitude: -23.5613 + (index * 0.001),
        longitude: -46.6565 + (index * 0.001),
        price: 'R\$ ${basePrice.toInt()}',
        priceValue: basePrice,
        type: 'Apartamento',
        area: 50.0 + (index * 5),
        bedrooms: 1 + (index % 3),
        bathrooms: 1 + (index % 2),
        parkingSpots: index % 2,
        condoFee: 400,
        taxes: 150,
        description: 'Mock property for testing pagination.',
        imageUrls: const [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
        ],
      );
    });
  }
}
