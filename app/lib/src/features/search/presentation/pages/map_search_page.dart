import 'package:flutter/material.dart';
import 'package:app/src/design_system/design_system.dart';

/// Map search — cozy fullscreen map placeholder with floating overlays.
class MapSearchPage extends StatelessWidget {
  const MapSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Stack(children: [
      const Positioned.fill(child: RepaintBoundary(child: CosmicBackground())),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: Column(children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderMd, border: Border.all(color: borderColor)), child: Icon(Icons.arrow_back_rounded, size: 18, color: mutedColor)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderXl, border: Border.all(color: borderColor)),
                child: Row(children: [
                  Icon(Icons.search_rounded, size: 16, color: mutedColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Buscar no mapa...', style: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.faint(isDark))),
                ]),
              )),
            ]),
          ),
          const Spacer(),
          // Placeholder
          Column(children: [
            Icon(Icons.map_rounded, size: 40, color: accentColor.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text('Mapa interativo', style: AppTypography.titleLarge.copyWith(color: mutedColor.withValues(alpha: 0.5))),
          ]),
          const Spacer(),
          // Bottom card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
              child: Row(children: [
                Icon(Icons.touch_app_rounded, size: 20, color: accentColor.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selecione um imóvel', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('Toque em um marcador no mapa', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ])),
      ),
    ]);
  }
}
