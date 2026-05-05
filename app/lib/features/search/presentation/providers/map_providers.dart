// Notifier state acts as the getter; standalone setters would require a
// corresponding getter which would shadow the inherited `state` property.
// ignore_for_file: use_setters_to_change_properties
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/property.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_filters_provider.dart';

/// Puxa imóveis reais do backend pra plotar no mapa. Reusa o
/// `SearchPropertiesUseCase` + os filtros atuais. Filtra fora os imóveis sem
/// coordenadas (lat/lng == 0), que não fazem sentido no mapa.
final mapPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final usecase = ref.watch(searchPropertiesUseCaseProvider);
  final filters = ref.watch(searchFiltersProvider);
  final result = await usecase.execute(filters);
  return result.properties
      .where((p) => p.latitude != 0 && p.longitude != 0)
      .toList();
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
