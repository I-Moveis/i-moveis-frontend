import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Admin dashboard — platform overview with metrics.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visão geral', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Usuários', value: '1.234', icon: Icons.people)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Imóveis', value: '567', icon: Icons.apartment)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Contratos', value: '89', icon: Icons.article)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Pendentes', value: '12', icon: Icons.pending_actions)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Acesso rápido', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Gerenciar usuários'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Moderar anúncios'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/listings'),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Gerenciar contratos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/contracts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
