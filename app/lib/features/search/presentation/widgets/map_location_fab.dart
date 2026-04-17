import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../design_system/design_system.dart';
import '../providers/map_providers.dart';

class MapLocationFab extends ConsumerWidget {
  const MapLocationFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final permission = ref.watch(locationPermissionStatusProvider);
    final isDisabled = permission == LocationPermission.deniedForever;

    return GestureDetector(
      onTap: () => _handleTap(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderFull,
          border: Border.all(color: borderColor),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        child: Icon(
          Icons.my_location_rounded,
          size: 20,
          color: isDisabled ? mutedColor.withValues(alpha: 0.4) : accentColor,
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final position = await requestAndFetchUserPosition(ref);
    if (!context.mounted) return;

    final permission = ref.read(locationPermissionStatusProvider);
    if (permission == LocationPermission.deniedForever) {
      await _showOpenSettingsSheet(context);
      return;
    }

    if (position == null) return;

    final controller = ref.read(mapControllerProvider);
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15),
    );
  }

  Future<void> _showOpenSettingsSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: BrutalistPalette.cardBg(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: BrutalistPalette.cardBorder(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permissão de localização',
                style: AppTypography.titleLargeBold.copyWith(
                  color: BrutalistPalette.title(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Habilite o acesso à localização nas configurações do sistema para centralizar o mapa em você.',
                style: AppTypography.bodyMedium.copyWith(
                  color: BrutalistPalette.muted(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Geolocator.openAppSettings();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: BrutalistPalette.accentOrange(isDark),
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Text(
                    'Abrir configurações',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
