import 'package:flutter/material.dart';

/// Photo gallery page — fullscreen image carousel.
class PhotoGalleryPage extends StatelessWidget {
  const PhotoGalleryPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Fotos'),
      ),
      body: PageView.builder(
        itemCount: 5,
        itemBuilder: (_, i) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image, size: 120, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Foto ${i + 1} de 5',
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
