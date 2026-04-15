import 'package:flutter/material.dart';

/// Admin contracts page — contract management and disputes.
class AdminContractsPage extends StatelessWidget {
  const AdminContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar contratos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, i) {
          final statuses = ['Ativo', 'Pendente assinatura', 'Rascunho', 'Ativo', 'Encerrado', 'Ativo'];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.article, color: theme.colorScheme.primary),
              title: Text('Contrato #${1000 + i}'),
              subtitle: Text(statuses[i]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
