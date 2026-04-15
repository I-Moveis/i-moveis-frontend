import 'package:flutter/material.dart';

/// Map search page — fullscreen map with property markers.
class MapSearchPage extends StatelessWidget {
  const MapSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Busca no mapa')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Mapa interativo', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Markers com preço dos imóveis', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
