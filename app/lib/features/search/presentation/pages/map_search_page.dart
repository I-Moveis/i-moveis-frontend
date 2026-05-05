import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/property.dart';
import '../map_style.dart';
import '../providers/map_providers.dart';
import '../widgets/map_location_fab.dart';
import '../widgets/map_property_details_sheet.dart';
import '../widgets/map_search_top_bar.dart';

/// Map search — fullscreen Google Map com pins dos imóveis reais do
/// backend. Clicar num pin abre uma sheet estilo Google Maps com foto,
/// preço e três ações (Detalhes, Rotas, Street View).
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

  Set<Marker> _buildMarkers(List<Property> properties) {
    const hue = BitmapDescriptor.hueRed;
    return properties
        .map(
          (p) => Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.latitude, p.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            onTap: () {
              ref.read(selectedPropertyIdProvider.notifier).set(p.id);
              _animateToProperty(p);
            },
          ),
        )
        .toSet();
  }

  Future<void> _animateToProperty(Property p) async {
    final controller = ref.read(mapControllerProvider);
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 16),
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final propertiesAsync = ref.watch(mapPropertiesProvider);
    final properties = propertiesAsync.value ?? [];

    final permission = ref.watch(locationPermissionStatusProvider);
    final locationGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    final selectedId = ref.watch(selectedPropertyIdProvider);
    final selected = selectedId == null
        ? null
        : properties.cast<Property?>().firstWhere(
              (p) => p?.id == selectedId,
              orElse: () => null,
            );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
                markers: _buildMarkers(properties),
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
                    onBack: _handleBack,
                    onSearchTap: () {},
                  ),
                  const Spacer(),
                ],
              ),
            ),
            if (propertiesAsync.isLoading)
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            // Location FAB — agora embaixo à direita, acima da sheet quando
            // ela aparece, ou acima da bottom bar padrão quando não há
            // seleção.
            Positioned(
              right: AppSpacing.screenHorizontal,
              bottom: selected != null
                  ? AppSpacing.massive + 140
                  : AppSpacing.xl,
              child: const MapLocationFab(),
            ),
            // Sheet com detalhes do imóvel — só quando há pin selecionado.
            if (selected != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MapPropertyDetailsSheet(
                  property: selected,
                  onClose: () => ref
                      .read(selectedPropertyIdProvider.notifier)
                      .set(null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
