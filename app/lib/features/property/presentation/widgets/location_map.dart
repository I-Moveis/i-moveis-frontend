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
  static const _zoom = 15.0;

  late final CameraPosition _initialCamera;
  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    final position = LatLng(widget.property.latitude, widget.property.longitude);
    _initialCamera = CameraPosition(target: position, zoom: _zoom);
    _markers = {
      Marker(
        markerId: MarkerId(widget.property.id),
        position: position,
        infoWindow: InfoWindow(title: widget.property.title),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localização', style: AppTypography.titleMedium),
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
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              // Needed on web to avoid swallowing scroll events from the parent
              gestureRecognizers: kIsWeb
                  ? {const Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)}
                  : const {},
            ),
          ),
        ),
      ],
    );
  }
}
