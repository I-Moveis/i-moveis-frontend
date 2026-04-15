import 'package:flutter/material.dart';

/// Settings page — notifications, dark mode, language.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificações push'),
            subtitle: const Text('Receba alertas sobre seus imóveis'),
            value: true,
            onChanged: (_) {},
            secondary: const Icon(Icons.notifications_outlined),
          ),
          SwitchListTile(
            title: const Text('Modo escuro'),
            subtitle: const Text('Alternar tema do app'),
            value: true,
            onChanged: (_) {},
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Termos de uso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o app'),
            subtitle: const Text('Versão 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
