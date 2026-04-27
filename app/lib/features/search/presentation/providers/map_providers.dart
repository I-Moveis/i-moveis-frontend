// Notifier state acts as the getter; standalone setters would require a
// corresponding getter which would shadow the inherited `state` property.
// ignore_for_file: use_setters_to_change_properties
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/mock_properties_datasource.dart';
import '../../domain/entities/map_property.dart';

// Filtros de Busca
class SearchFilter {
  final double? minPrice;
  final double? maxPrice;
  SearchFilter({this.minPrice, this.maxPrice});
}

class SearchFilterNotifier extends Notifier<SearchFilter> {
  @override
  SearchFilter build() => SearchFilter();
  
  void updateFilter({double? min, double? max}) {
    state = SearchFilter(
      minPrice: min ?? state.minPrice, 
      maxPrice: max ?? state.maxPrice,
    );
  }
}

final searchFilterProvider = NotifierProvider<SearchFilterNotifier, SearchFilter>(
  SearchFilterNotifier.new,
);

// Puxa as propriedades baseado no filtro (Simulando API NODE)
final mockPropertiesProvider = FutureProvider<List<MapProperty>>((ref) async {
  final filter = ref.watch(searchFilterProvider);
  
  // Simula a ida na API Node.js
  await Future.delayed(const Duration(milliseconds: 800));

  var filteredList = kMockMapProperties.toList();

  if (filter.minPrice != null) {
    filteredList = filteredList.where((p) {
      final priceNum = double.tryParse(p.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
      return priceNum >= filter.minPrice!;
    }).toList();
  }
  if (filter.maxPrice != null) {
    filteredList = filteredList.where((p) {
      final priceNum = double.tryParse(p.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
      return priceNum <= filter.maxPrice!;
    }).toList();
  }

  return filteredList;
});

class SelectedPropertyIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedPropertyIdProvider =
    NotifierProvider<SelectedPropertyIdNotifier, String?>(
  SelectedPropertyIdNotifier.new,
);

class UserPositionNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;
  void set(LatLng? value) => state = value;
}

final userPositionProvider = NotifierProvider<UserPositionNotifier, LatLng?>(
  UserPositionNotifier.new,
);

class MapControllerNotifier extends Notifier<GoogleMapController?> {
  @override
  GoogleMapController? build() => null;
  void set(GoogleMapController? value) => state = value;
}

final mapControllerProvider =
    NotifierProvider<MapControllerNotifier, GoogleMapController?>(
  MapControllerNotifier.new,
);

class LocationPermissionNotifier extends Notifier<LocationPermission> {
  @override
  LocationPermission build() => LocationPermission.denied;
  void set(LocationPermission value) => state = value;
}

final locationPermissionStatusProvider =
    NotifierProvider<LocationPermissionNotifier, LocationPermission>(
  LocationPermissionNotifier.new,
);

/// Runs the permission flow and fetches the current position.
/// Returns the resolved [LatLng] or null if permission was not granted.
Future<LatLng?> requestAndFetchUserPosition(WidgetRef ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  ref.read(locationPermissionStatusProvider.notifier).set(permission);

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  final position = await Geolocator.getCurrentPosition();
  final latLng = LatLng(position.latitude, position.longitude);
  ref.read(userPositionProvider.notifier).set(latLng);
  return latLng;
}
