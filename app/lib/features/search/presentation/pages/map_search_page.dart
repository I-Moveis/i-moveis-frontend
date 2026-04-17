import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../design_system/design_system.dart';
import '../../data/mock_properties_datasource.dart';
import '../../domain/entities/map_property.dart';
import '../map_style.dart';
import '../providers/map_providers.dart';
import '../widgets/map_location_fab.dart';
import '../widgets/map_property_preview.dart';
import '../widgets/map_search_top_bar.dart';

/// Map search — fullscreen Google Map with floating overlays.
class MapSearchPage extends ConsumerStatefulWidget {
  const MapSearchPage({super.key});

  @override
  ConsumerState<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends ConsumerState<MapSearchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final current = await Geolocator.checkPermission();
      if (!mounted) return;
      ref.read(locationPermissionStatusProvider.notifier).set(current);
    });
  }

  @override
  void dispose() {
    ref.read(mapControllerProvider.notifier).set(null);
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<MapProperty> properties, bool isDark) {
    final hue = isDark
        ? BitmapDescriptor.hueYellow
        : BitmapDescriptor.hueOrange;
    return properties
        .map(
          (p) => Marker(
            markerId: MarkerId(p.id),
            position: p.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            onTap: () =>
                ref.read(selectedPropertyIdProvider.notifier).set(p.id),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final properties = ref.watch(mockPropertiesProvider);
    final selectedId = ref.watch(selectedPropertyIdProvider);
    final permission = ref.watch(locationPermissionStatusProvider);
    final locationGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    final selected = selectedId == null
        ? null
        : properties.firstWhere(
            (p) => p.id == selectedId,
            orElse: () => properties.first,
          );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              key: ValueKey(isDark),
              initialCameraPosition: const CameraPosition(
                target: kMapInitialCenter,
                zoom: kMapInitialZoom,
              ),
              style: isDark ? kDarkMapStyleJson : kLightMapStyleJson,
              markers: _buildMarkers(properties, isDark),
              myLocationEnabled: locationGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) {
                ref.read(mapControllerProvider.notifier).set(controller);
              },
              onTap: (_) =>
                  ref.read(selectedPropertyIdProvider.notifier).set(null),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                MapSearchTopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onSearchTap: () {},
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: selected != null ? 180 : AppSpacing.xxl,
            child: const MapLocationFab(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: selected == null
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : MapPropertyPreview(
                      key: ValueKey(selected.id),
                      property: selected,
                      onClose: () => ref
                          .read(selectedPropertyIdProvider.notifier)
                          .set(null),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
