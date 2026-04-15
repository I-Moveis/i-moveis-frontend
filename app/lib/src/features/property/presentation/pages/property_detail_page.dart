import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Property detail page — photos, info, price, amenities, owner, actions.
class PropertyDetailPage extends StatelessWidget {
  const PropertyDetailPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: theme.colorScheme.primaryContainer,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/property/$propertyId/photos'),
                        child: const Text('Ver todas as fotos'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Chip(label: const Text('Exclusivo'), backgroundColor: theme.colorScheme.primaryContainer),
                    const SizedBox(width: 8),
                    Chip(label: const Text('Novo'), backgroundColor: theme.colorScheme.secondaryContainer),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Apartamento - Vila Madalena', style: theme.textTheme.headlineSmall),
                Text('São Paulo, SP', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoCard(icon: Icons.square_foot, label: '51 m²'),
                    _InfoCard(icon: Icons.bed, label: '2 quartos'),
                    _InfoCard(icon: Icons.shower, label: '1 banh.'),
                    _InfoCard(icon: Icons.directions_car, label: '1 vaga'),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Preços', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                _PriceRow(label: 'Aluguel', value: 'R\$ 2.500,00'),
                _PriceRow(label: 'Condomínio', value: 'R\$ 450,00'),
                _PriceRow(label: 'IPTU', value: 'R\$ 250,00'),
                const Divider(),
                _PriceRow(label: 'Total/mês', value: 'R\$ 3.200,00', bold: true),
                const SizedBox(height: 24),
                Text('Sobre', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Apartamento amplo e bem iluminado, com vista para o parque. '
                  'Localização privilegiada, próximo a transporte público e comércio.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text('Amenidades', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Piscina')),
                    Chip(label: Text('Academia')),
                    Chip(label: Text('Portaria 24h')),
                    Chip(label: Text('Elevador')),
                    Chip(label: Text('Varanda')),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Localização', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.map, size: 48)),
                ),
                const SizedBox(height: 24),
                Text('Proprietário', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('Mariana'),
                  subtitle: const Text('Membro desde 2023'),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Mensagem'),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/property/$propertyId/schedule'),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Agendar visita'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/property/$propertyId/proposal'),
                icon: const Icon(Icons.description),
                label: const Text('Fazer proposta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style?.copyWith(fontWeight: bold ? FontWeight.bold : null)),
        ],
      ),
    );
  }
}
