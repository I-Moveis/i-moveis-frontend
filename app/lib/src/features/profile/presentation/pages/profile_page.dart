import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Profile tab — user info, menu items, settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text('Usuário', style: theme.textTheme.titleLarge),
                Text('usuario@email.com', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.go('/profile/edit'),
                  child: const Text('Editar perfil'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Minhas propostas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Minhas visitas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Meus contratos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Meus imóveis'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/my-properties'),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Anunciar imóvel'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/my-properties/create'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Suporte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Sair', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => context.go('/login'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
