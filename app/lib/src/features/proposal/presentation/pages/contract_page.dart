import 'package:flutter/material.dart';

/// Contract page — stepper status, PDF preview, sign button.
class ContractPage extends StatelessWidget {
  const ContractPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contrato digital')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Stepper(
              currentStep: 2,
              controlsBuilder: (_, _) => const SizedBox.shrink(),
              steps: const [
                Step(title: Text('Proposta aceita'), content: SizedBox.shrink(), isActive: true),
                Step(title: Text('Contrato gerado'), content: SizedBox.shrink(), isActive: true),
                Step(title: Text('Assinatura inquilino'), content: SizedBox.shrink(), isActive: true),
                Step(title: Text('Assinatura proprietário'), content: SizedBox.shrink()),
                Step(title: Text('Contrato ativo'), content: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Preview do contrato (PDF)', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.draw),
              label: const Text('Assinar contrato'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
