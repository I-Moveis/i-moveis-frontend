import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/presentation/widgets/property_list_tile.dart';

void main() {
  final mockProperty = Property(
    id: 'test-1',
    title: 'Apartamento de Luxo',
    latitude: 0,
    longitude: 0,
    price: 'R\$ 5.000',
    priceValue: 5000,
    description: 'Um belo apartamento.',
    type: 'Apartamento',
    area: 120.0,
    bedrooms: 3,
    bathrooms: 2,
    parkingSpots: 2,
    condoFee: 800,
    taxes: 200,
    imageUrls: ['https://example.com/image.jpg'],
  );

  Widget createTestableWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PropertyListTile(property: mockProperty),
          ),
        ),
      ),
    );
  }

  testWidgets('PropertyListTile should render key property information', (tester) async {
    // Increase surface size to avoid overflow in test environment
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestableWidget());

    expect(find.text('Apartamento de Luxo'), findsOneWidget);
    expect(find.text('R\$ 5.000'), findsOneWidget);
    expect(find.text('120 m²'), findsOneWidget); // Precise area match
    expect(find.text('3'), findsOneWidget); // Precise bedrooms match
    expect(find.text('2'), findsNWidgets(2)); // Bathrooms and Parking spots
    // Match the current implementation: 'R$ 6000' (5000 + 800 + 200)
    expect(find.textContaining('6000'), findsOneWidget); 
    
    // Reset view
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('PropertyListTile should show favorite icon state', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestableWidget());

    // Initial state: not favorite (border icon)
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    
    // Tap favorite button
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    // Should now be favorite (filled icon)
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    
    addTearDown(tester.view.resetPhysicalSize);
  });
}
