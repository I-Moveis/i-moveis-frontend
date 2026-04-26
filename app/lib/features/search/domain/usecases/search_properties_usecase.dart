import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';

/// Provider for the SearchPropertiesUseCase.
/// This allows mocking the use case in tests.
final searchPropertiesUseCaseProvider = Provider<SearchPropertiesUseCase>((ref) {
  // For now returning a mock implementation, later will return real one
  return SearchPropertiesUseCaseImpl();
});

abstract class SearchPropertiesUseCase {
  Future<List<Property>> execute(SearchFilters filters, {int page = 1});
}

class SearchPropertiesUseCaseImpl implements SearchPropertiesUseCase {
  @override
  Future<List<Property>> execute(SearchFilters filters, {int page = 1}) async {
    // Mock implementation for Phase 8
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate pagination: 10 items per page
    return List.generate(10, (index) {
      final id = 'prop-${page}-${index}';
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
        imageUrls: ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80'],
      );
    });
  }
}
