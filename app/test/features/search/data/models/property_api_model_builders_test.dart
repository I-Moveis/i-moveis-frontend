import 'package:app/features/search/data/models/property_api_model.dart';
import 'package:app/features/search/domain/entities/property_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('propertyToCreateJson', () {
    test('serialises required fields with price as two-decimal string', () {
      final body = propertyToCreateJson(const PropertyInput(
        landlordId: 'l1',
        title: 't',
        description: 'd',
        price: 2500,
        address: 'Rua A',
      ));

      expect(body, {
        'landlordId': 'l1',
        'title': 't',
        'description': 'd',
        'price': '2500.00',
        'address': 'Rua A',
      });
    });

    test('throws ArgumentError when required fields missing', () {
      expect(
        () => propertyToCreateJson(const PropertyInput(title: 'only title')),
        throwsArgumentError,
      );
    });

    test('includes optional fields only when non-null', () {
      final body = propertyToCreateJson(const PropertyInput(
        landlordId: 'l1',
        title: 't',
        description: 'd',
        price: 1000,
        address: 'A',
        type: 'HOUSE',
        bedrooms: 3,
        isFurnished: true,
        condoFee: 450,
      ));

      expect(body['type'], 'HOUSE');
      expect(body['bedrooms'], 3);
      expect(body['isFurnished'], true);
      expect(body['condoFee'], '450.00');
      expect(body.containsKey('petsAllowed'), false);
      expect(body.containsKey('latitude'), false);
    });

    test('propertyTax is serialised as stringified decimal', () {
      final body = propertyToCreateJson(const PropertyInput(
        landlordId: 'l1',
        title: 't',
        description: 'd',
        price: 1000,
        address: 'A',
        propertyTax: 99.5,
      ));
      expect(body['propertyTax'], '99.50');
    });
  });

  group('propertyToPatchJson', () {
    test('empty input → empty body', () {
      expect(propertyToPatchJson(const PropertyInput()), isEmpty);
    });

    test('only includes fields explicitly set', () {
      final body = propertyToPatchJson(const PropertyInput(
        title: 'Novo título',
        bedrooms: 2,
      ));
      expect(body, {'title': 'Novo título', 'bedrooms': 2});
    });

    test('price and money fields go as strings', () {
      final body = propertyToPatchJson(const PropertyInput(
        price: 3000,
        condoFee: 550.5,
        propertyTax: 150,
      ));
      expect(body['price'], '3000.00');
      expect(body['condoFee'], '550.50');
      expect(body['propertyTax'], '150.00');
    });

    test('status passes through unchanged', () {
      final body = propertyToPatchJson(const PropertyInput(status: 'RENTED'));
      expect(body, {'status': 'RENTED'});
    });
  });
}
