import 'package:flutter/material.dart';

/// Schedule visit page — calendar + time slot selection.
class ScheduleVisitPage extends StatelessWidget {
  const ScheduleVisitPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar visita')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Text('Escolha a data', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (_, i) {
                  final day = DateTime.now().add(Duration(days: i + 1));
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${day.day}/${day.month}'),
                      selected: i == 0,
                      onSelected: (_) {},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Escolha o horário', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                ChoiceChip(label: Text('09:00 - 12:00 (Manhã)'), selected: false),
                ChoiceChip(label: Text('13:00 - 17:00 (Tarde)'), selected: true),
                ChoiceChip(label: Text('18:00 - 20:00 (Noite)'), selected: false),
              ],
            ),
            const SizedBox(height: 24),
            Text('Observações (opcional)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Alguma observação para o proprietário?'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Confirmar visita'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
