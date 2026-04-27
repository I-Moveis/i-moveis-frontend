import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Solicita permissão (se necessário) e retorna a posição atual.
  /// Lança [LocationServiceDisabledException] se o GPS estiver desligado.
  /// Lança [PermissionDeniedException] se o usuário negar definitivamente.
  static Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Permissão de localização negada permanentemente.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Stream de atualizações contínuas de posição para sincronização em tempo real.
  static Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // metros mínimos para emitir novo evento
      ),
    );
  }
}
