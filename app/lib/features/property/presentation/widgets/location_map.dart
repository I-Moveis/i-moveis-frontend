import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({required this.property, super.key});

  final Property property;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  static const _mapHeight = 220.0;
  static const _zoom = 14.5;

  // Raio do círculo exibido (área aproximada do imóvel).
  static const _circleRadiusMeters = 300.0;

  // Deslocamento máximo do centro em relação à lat/lng real, para evitar
  // que o usuário deduza o endereço exato dando zoom no centro do círculo.
  static const _maxOffsetMeters = 80.0;

  late final CameraPosition _initialCamera;
  late final Set<Circle> _circles;

  @override
  void initState() {
    super.initState();
    final fuzzedCenter = _deterministicallyOffset(
      LatLng(widget.property.latitude, widget.property.longitude),
      seed: widget.property.id,
    );
    _initialCamera = CameraPosition(target: fuzzedCenter, zoom: _zoom);
    _circles = {
      Circle(
        circleId: CircleId(widget.property.id),
        center: fuzzedCenter,
        radius: _circleRadiusMeters,
        fillColor: AppColors.iridescent5.withValues(alpha: 0.18),
        strokeColor: AppColors.iridescent5,
        strokeWidth: 2,
      ),
    };
  }

  /// Desloca o ponto em até [_maxOffsetMeters] usando o id da property como
  /// seed — garante que o mesmo imóvel sempre renderiza no mesmo lugar entre
  /// sessões e usuários (o que dá consistência visual), mas o centro do
  /// círculo nunca é o endereço real.
  LatLng _deterministicallyOffset(LatLng origin, {required String seed}) {
    final rng = math.Random(seed.hashCode);
    // Direção uniforme + distância sqrt(rng) para distribuir uniformemente
    // dentro de um disco em vez de concentrar perto da borda.
    final angle = rng.nextDouble() * 2 * math.pi;
    final distance = math.sqrt(rng.nextDouble()) * _maxOffsetMeters;

    const metersPerLatDegree = 111320.0;
    final metersPerLngDegree =
        metersPerLatDegree * math.cos(origin.latitude * math.pi / 180);

    final dLat = (distance * math.sin(angle)) / metersPerLatDegree;
    final dLng = (distance * math.cos(angle)) / metersPerLngDegree;

    return LatLng(origin.latitude + dLat, origin.longitude + dLng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localização aproximada', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (widget.property.address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.whiteMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.property.address,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.whiteMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            height: _mapHeight,
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              circles: _circles,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              gestureRecognizers: kIsWeb
                  ? {const Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)}
                  : const {},
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Por segurança, o endereço exato só é compartilhado após contato com o anunciante.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.whiteMuted),
        ),
      ],
    );
  }
}
