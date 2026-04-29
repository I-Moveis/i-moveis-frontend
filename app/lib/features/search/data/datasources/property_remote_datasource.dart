import '../../domain/entities/property.dart';
import '../../domain/entities/property_input.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_search_page.dart';
import 'property_datasources.dart';

/// Mock implementation used when `kUseMockData` is true (or as fallback while
/// the backend isn't available). Returns a fixed page of 10 synthetic items
/// and keeps an in-memory store for create/update/delete so the UI roundtrip
/// feels real.
class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  PropertyRemoteDataSourceImpl();

  static const _pageSize = 10;
  static const _totalPages = 3;

  final List<Property> _created = [];
  final List<String> _deletedIds = [];
  int _autoInc = 0;

  @override
  Future<PropertySearchPage> searchProperties(
    SearchFilters filters, {
    int page = 1,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final generated = List.generate(_pageSize, (index) {
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
        description: 'Property from Remote API.',
        imageUrls: const [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
        ],
      );
    });

    // Merge with in-memory stores so CRUD against the mock is visible.
    final merged = <Property>[
      if (page == 1) ..._created,
      ...generated,
    ].where((p) => !_deletedIds.contains(p.id)).toList();

    return PropertySearchPage(
      properties: merged,
      total: _pageSize * _totalPages + _created.length,
      page: page,
      totalPages: _totalPages,
    );
  }

  @override
  Future<Property> create(PropertyInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _autoInc++;
    final priceValue = input.price ?? 0;
    final created = Property(
      id: 'prop-new-$_autoInc',
      title: input.title ?? '',
      latitude: input.latitude ?? 0,
      longitude: input.longitude ?? 0,
      price: priceValue > 0
          ? 'R\$ ${priceValue.round()}'
          : 'Sob consulta',
      priceValue: priceValue,
      description: input.description ?? '',
      type: _typeDisplay(input.type),
      area: input.area ?? 0,
      bedrooms: input.bedrooms ?? 0,
      bathrooms: input.bathrooms ?? 0,
      parkingSpots: input.parkingSpots ?? 0,
      condoFee: input.condoFee ?? 0,
      taxes: input.propertyTax ?? 0,
      address: [input.address, input.city, input.state]
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .join(', '),
    );
    _created.insert(0, created);
    return created;
  }

  @override
  Future<Property> update(String id, PropertyInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final idx = _created.indexWhere((p) => p.id == id);
    if (idx == -1) {
      // Pretend the update succeeded on a read-only seed item by returning
      // an updated projection. Search mocks don't persist updates on the
      // generated pages — the UI will re-pull on next refresh.
      return Property(
        id: id,
        title: input.title ?? 'Property $id',
        latitude: input.latitude ?? 0,
        longitude: input.longitude ?? 0,
        price: input.price != null ? 'R\$ ${input.price!.round()}' : '—',
        priceValue: input.price ?? 0,
        description: input.description ?? '',
        type: _typeDisplay(input.type),
        area: input.area ?? 0,
        bedrooms: input.bedrooms ?? 0,
        bathrooms: input.bathrooms ?? 0,
        parkingSpots: input.parkingSpots ?? 0,
      );
    }
    final current = _created[idx];
    final updated = current.copyWith(
      title: input.title ?? current.title,
      description: input.description ?? current.description,
      priceValue: input.price ?? current.priceValue,
      price: input.price != null
          ? 'R\$ ${input.price!.round()}'
          : current.price,
      bedrooms: input.bedrooms ?? current.bedrooms,
      bathrooms: input.bathrooms ?? current.bathrooms,
      parkingSpots: input.parkingSpots ?? current.parkingSpots,
      area: input.area ?? current.area,
      condoFee: input.condoFee ?? current.condoFee,
      taxes: input.propertyTax ?? current.taxes,
    );
    _created[idx] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _created.removeWhere((p) => p.id == id);
    if (!_deletedIds.contains(id)) _deletedIds.add(id);
  }

  String _typeDisplay(String? apiType) {
    switch (apiType) {
      case 'HOUSE':
        return 'Casa';
      case 'STUDIO':
        return 'Studio';
      case 'CONDO_HOUSE':
        return 'Casa em condomínio';
      case 'APARTMENT':
      default:
        return 'Apartamento';
    }
  }
}
