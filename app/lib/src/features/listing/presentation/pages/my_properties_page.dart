import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// My properties page — owner's property list.
class MyPropertiesPage extends StatelessWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus imóveis')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/profile/my-properties/create'),
        icon: const Icon(Icons.add),
        label: const Text('Anunciar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apartment),
              ),
              title: Text('Imóvel ${i + 1}'),
              subtitle: Text(i == 0 ? 'Disponível' : 'Alugado'),
              trailing: IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => context.go('/profile/my-properties/analytics'),
              ),
            ),
          );
        },
      ),
    );
  }
}
