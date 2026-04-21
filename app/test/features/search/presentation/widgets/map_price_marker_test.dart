import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/search/presentation/widgets/map_price_marker.dart';

void main() {
  group('MapPriceMarker Widget', () {
    testWidgets('exibe o preco formatado corretamente', (WidgetTester tester) async {
      const priceText = 'R\$ 2.500';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapPriceMarker(
              formattedPrice: priceText,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text(priceText), findsOneWidget);
    });

    testWidgets('dispara callback onTap quando pressionado', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapPriceMarker(
              formattedPrice: 'R\$ 1.000',
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MapPriceMarker));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });
  });
}
