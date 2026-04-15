import 'package:flutter/material.dart';

/// Favorites tab — saved properties list.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded, size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Nenhum favorito ainda', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Comece a explorar e salve imóveis!', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
