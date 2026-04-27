import '../../domain/entities/property.dart';
import '../../presentation/providers/search_filters_provider.dart';
import 'property_datasources.dart';

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  @override
  Future<List<Property>> searchProperties(SearchFilters filters, {int page = 1}) async {
    // Simulated API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For now, returning the same mock data as before
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
        description: 'Property from Remote API.',
        imageUrls: ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80'],
      );
    });
  }
}
