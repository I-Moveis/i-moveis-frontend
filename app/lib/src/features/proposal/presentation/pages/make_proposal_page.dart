import 'package:flutter/material.dart';

/// Make proposal page — offer value, contract duration, move-in date.
class MakeProposalPage extends StatelessWidget {
  const MakeProposalPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fazer proposta')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apartamento - Vila Madalena', style: theme.textTheme.titleSmall),
                        Text('Preço pedido: R\$ 2.500/mês', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Valor proposto', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'R\$',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Text('Prazo do contrato', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                ChoiceChip(label: Text('12 meses'), selected: false),
                ChoiceChip(label: Text('24 meses'), selected: true),
                ChoiceChip(label: Text('30 meses'), selected: false),
                ChoiceChip(label: Text('36 meses'), selected: false),
              ],
            ),
            const SizedBox(height: 24),
            Text('Data de mudança', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Selecionar data',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 24),
            Text('Mensagem ao proprietário', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Opcional'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Enviar proposta'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
