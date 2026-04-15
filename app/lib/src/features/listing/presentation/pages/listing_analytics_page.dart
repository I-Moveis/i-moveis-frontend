import 'package:flutter/material.dart';

/// Listing analytics page — views, favorites, proposals metrics.
class ListingAnalyticsPage extends StatelessWidget {
  const ListingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Desempenho do anúncio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Métricas', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MetricCard(icon: Icons.visibility, label: 'Visualizações', value: '142')),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(icon: Icons.favorite, label: 'Favoritos', value: '23')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MetricCard(icon: Icons.description, label: 'Propostas', value: '5')),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(icon: Icons.calendar_today, label: 'Visitas', value: '8')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
