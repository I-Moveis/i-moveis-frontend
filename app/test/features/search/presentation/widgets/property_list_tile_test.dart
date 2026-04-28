import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/presentation/widgets/property_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mockProperty = Property(
    id: 'test-1',
    title: 'Apartamento de Luxo',
    latitude: 0,
    longitude: 0,
    price: r'R$ 5.000',
    priceValue: 5000,
    description: 'Um belo apartamento.',
    type: 'Apartamento',
    area: 120,
    bedrooms: 3,
    bathrooms: 2,
    parkingSpots: 2,
    condoFee: 800,
    taxes: 200,
    imageUrls: ['https://example.com/image.jpg'],
  );

  Widget createTestableWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PropertyListTile(property: mockProperty),
          ),
        ),
      ),
    );
  }

  testWidgets('PropertyListTile should render key property information',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(createTestableWidget());

    expect(find.text('Apartamento de Luxo'), findsOneWidget);
    expect(find.text(r'R$ 5.000'), findsOneWidget);
    expect(find.text('120 m²'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));
    expect(find.textContaining('6000'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('PropertyListTile should show favorite icon state',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(createTestableWidget());

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
