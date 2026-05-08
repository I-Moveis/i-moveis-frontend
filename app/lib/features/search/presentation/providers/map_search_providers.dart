import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

// --- Mocks Data para exemplo ---
class PropertyMock {
  final String id;
  final String title;
  final double price;
  final LatLng location;
  final String imageUrl;

  PropertyMock({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
  });
}

// 1. O Estado do Filtro
class SearchFilter {
  final double? minPrice;
  final double? maxPrice;
  
  SearchFilter({this.minPrice, this.maxPrice});
}

class SearchFilterNotifier extends StateNotifier<SearchFilter> {
  SearchFilterNotifier() : super(SearchFilter());

  void updateFilter({double? min, double? max}) {
    state = SearchFilter(minPrice: min ?? state.minPrice, maxPrice: max ?? state.maxPrice);
  }
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, SearchFilter>((ref) {
  return SearchFilterNotifier();
});

// 2. Fetch da API (Mock) baseado no Filtro
final propertiesListProvider = FutureProvider<List<PropertyMock>>((ref) async {
  final filter = ref.watch(searchFilterProvider);
  
  // Simulando requisição na API Node.js atrasada
  await Future.delayed(const Duration(seconds: 1));
  
  final mockData = [
    PropertyMock(id: '1', title: 'Apartamento Centro', price: 2500, location: const LatLng(-23.550520, -46.633308), imageUrl: 'https://via.placeholder.com/150'),
    PropertyMock(id: '2', title: 'Studio Vila Madalena', price: 3200, location: const LatLng(-23.556520, -46.685308), imageUrl: 'https://via.placeholder.com/150'),
  ];

  return mockData.where((p) {
    if (filter.minPrice != null && p.price < filter.minPrice!) return false;
    if (filter.maxPrice != null && p.price > filter.maxPrice!) return false;
    return true;
  }).toList();
});

// 3. Transformação em Markers
final mapMarkersProvider = Provider<Set<Marker>>((ref) {
  final propertiesState = ref.watch(propertiesListProvider);
  
  return propertiesState.maybeWhen(
    data: (properties) {
      return properties.map((prop) {
        return Marker(
          markerId: MarkerId(prop.id),
          position: prop.location,
          // TODO(Feature): Converter MapPriceMarker (Widget) em BitmapDescriptor aqui
          // Atualmente usando os pinos padrões do Google como fallback até a injeção do render_box
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'R\$ \${prop.price}', snippet: prop.title),
        );
      }).toSet();
    },
    orElse: () => {},
  );
});
