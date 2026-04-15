import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Chat tab — list of conversations.
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Conversas')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3,
        itemBuilder: (_, i) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text('${i + 1}'),
            ),
            title: Text('Proprietário ${i + 1}'),
            subtitle: const Text('Última mensagem...'),
            trailing: Text('10:${30 + i}', style: theme.textTheme.labelSmall),
            onTap: () => context.go('/chat/conversation-$i'),
          );
        },
      ),
    );
  }
}
