import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/search/presentation/widgets/filter_chip_bar.dart';

void main() {
  group('FilterChipBar Widget Tests', () {
    testWidgets('renders all required filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FilterChipBar(),
          ),
        ),
      );

      expect(find.text('Aluguel'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Quartos'), findsOneWidget);
      expect(find.text('Preço'), findsOneWidget);
      expect(find.text('Filtros'), findsOneWidget);
    });

    testWidgets('chips are scrollable horizontally', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Small width to force scrolling
              child: FilterChipBar(),
            ),
          ),
        ),
      );

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);

      final scrollable = tester.widget<SingleChildScrollView>(scrollableFinder);
      expect(scrollable.scrollDirection, Axis.horizontal);
    });

    testWidgets('tapping chips does not crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FilterChipBar(),
          ),
        ),
      );

      await tester.tap(find.text('Aluguel'));
      await tester.tap(find.text('Tipo'));
      await tester.tap(find.text('Quartos'));
      await tester.tap(find.text('Preço'));
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
    });
  });
}
