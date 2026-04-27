import 'package:app/features/search/presentation/widgets/map_price_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapPriceMarker Widget', () {
    testWidgets('exibe o preco formatado corretamente',
        (WidgetTester tester) async {
      const priceText = r'R$ 2.500';

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

    testWidgets('dispara callback onTap quando pressionado',
        (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapPriceMarker(
              formattedPrice: r'R$ 1.000',
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
