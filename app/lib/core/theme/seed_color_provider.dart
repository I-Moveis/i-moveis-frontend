import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/tokens/brutalist_palette.dart';

/// Notifier that holds the current seed color for the design system.
///
/// This allows real-time color testing across the entire app.
class SeedColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    // Initial color is the current warm orange/yellow from BrutalistPalette
    return const Color(0xFFDEAD82);
  }

  // Notifier state is the getter; a paired getter would shadow it.
  // ignore: use_setters_to_change_properties
  void setColor(Color color) => state = color;

  void reset() {
    state = const Color(0xFFDEAD82);
  }
}

/// Provider for the app's seed color.
final seedColorProvider = NotifierProvider<SeedColorNotifier, Color>(
  SeedColorNotifier.new,
);

/// Provider for the dynamic brutalist palette.
final brutalistPaletteProvider = Provider<DynamicBrutalistPalette>((ref) {
  final seed = ref.watch(seedColorProvider);
  return DynamicBrutalistPalette(seed);
});
