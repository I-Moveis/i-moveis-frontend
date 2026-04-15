import 'package:flutter/material.dart';

/// Admin users page — user management list.
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar usuários')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text('${i + 1}'),
              ),
              title: Text('Usuário ${i + 1}'),
              subtitle: Text(i % 3 == 0 ? 'Proprietário' : 'Inquilino'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'view', child: Text('Ver detalhes')),
                  const PopupMenuItem(value: 'block', child: Text('Bloquear')),
                ],
                onSelected: (_) {},
              ),
            ),
          );
        },
      ),
    );
  }
}
