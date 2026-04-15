import 'package:flutter/material.dart';

/// Edit profile page — update name, phone, photo.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Salvar')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person, size: 48, color: theme.colorScheme.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: 'Nome completo')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Email'), enabled: false),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Telefone')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'CPF')),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
