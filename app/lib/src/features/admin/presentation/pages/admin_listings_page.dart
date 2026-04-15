import 'package:flutter/material.dart';

/// Admin listings page — moderate property listings.
class AdminListingsPage extends StatelessWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Moderar anúncios')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apartment),
              ),
              title: Text('Imóvel ${i + 1}'),
              subtitle: Text(i % 2 == 0 ? 'Pendente de aprovação' : 'Aprovado'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
