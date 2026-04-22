import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/search/presentation/pages/map_search_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('MapSearchPage UI Tests', () {
    testWidgets('Garante que MapSearchPage possui GoogleMap e DraggableScrollableSheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapSearchPage(),
          ),
        ),
      );

      // Pode precisar de pumpAndSettle se houver animações
      // await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget); // O botão de filtro
    });
  });
}
