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
    
    // Agora o provider retorna um AsyncValue (simulando API)
    final propertiesAsync = ref.watch(mockPropertiesProvider);
    final properties = propertiesAsync.value ?? [];
    
    final selectedId = ref.watch(selectedPropertyIdProvider);
    final permission = ref.watch(locationPermissionStatusProvider);
    final locationGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

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
          // Botão flutuante de filtro (Task especificação)
          Positioned(
            right: AppSpacing.screenHorizontal,
            top: 100, // Logo abaixo do TopBar
            child: FloatingActionButton.small(
              heroTag: 'filter_fab',
              onPressed: () => _showFilterModal(context, ref),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: 300, // Acima do bottom sheet
            child: const MapLocationFab(),
          ),
          // Novo component: Bottom Sheet Draggable
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
               height: MediaQuery.of(context).size.height * 0.7, // Altura max do content limit
               child: DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.1,
                maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 0)
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Loading State e Listagem
                        Expanded(
                          child: propertiesAsync.when(
                            data: (data) {
                              if (data.isEmpty) {
                                return const Center(child: Text("Nenhum imóvel encontrado."));
                              }
                              return ListView.builder(
                                controller: scrollController,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final prop = data[index];
                                  return MapPropertyPreview(
                                    key: ValueKey(prop.id),
                                    property: prop,
                                    onClose: () {},
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Erro: $err')),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filtros", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text("Até R\$ 4.000"),
                onTap: () {
                  ref.read(searchFilterProvider.notifier).updateFilter(max: 4000);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text("Limpar Filtros"),
                onTap: () {
                  ref.read(searchFilterProvider.notifier).updateFilter(max: null, min: null);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
