import 'package:app/features/search/data/models/property_api_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('propertyFromApiJson', () {
    test('parses camelCase payload (default /search response)', () {
      final json = <String, dynamic>{
        'id': 'prop-1',
        'title': 'Apartamento Paulista',
        'description': 'Lindo apartamento no centro.',
        'price': '4500',
        'address': 'Rua Augusta, 100',
        'city': 'São Paulo',
        'state': 'SP',
        'type': 'APARTMENT',
        'bedrooms': 2,
        'bathrooms': 1,
        'parkingSpots': 1,
        'area': 65.5,
        'latitude': -23.5489,
        'longitude': -46.6388,
        'isFurnished': true,
        'petsAllowed': false,
        'nearSubway': true,
        'isFeatured': true,
        'condoFee': '450',
        'propertyTax': '150',
        'images': [
          {'url': 'https://cdn/img1.jpg', 'isCover': false},
          {'url': 'https://cdn/cover.jpg', 'isCover': true},
        ],
      };

      final property = propertyFromApiJson(json);

      expect(property.id, 'prop-1');
      expect(property.priceValue, 4500);
      expect(property.price, r'R$ 4500');
      expect(property.type, 'Apartamento');
      expect(property.parkingSpots, 1);
      expect(property.condoFee, 450);
      expect(property.taxes, 150);
      expect(property.address, 'Rua Augusta, 100, São Paulo, SP');
      expect(property.amenities, containsAll(['Mobiliado', 'Próximo ao metrô']));
      expect(property.amenities, isNot(contains('Aceita pets')));
      expect(property.badges, ['Destaque']);
      // Cover image should come first regardless of input order.
      expect(property.imageUrls.first, 'https://cdn/cover.jpg');
    });

    test('parses snake_case payload (orderBy=nearest response)', () {
      final json = <String, dynamic>{
        'id': 'prop-2',
        'title': 'Casa Morumbi',
        'description': 'Espaçosa.',
        'price': '7200',
        'address': 'Alameda X, 10',
        'city': 'São Paulo',
        'state': 'SP',
        'type': 'HOUSE',
        'bedrooms': 3,
        'bathrooms': 2,
        'parking_spots': 2,
        'area': 180,
        'is_furnished': false,
        'pets_allowed': true,
        'near_subway': false,
        'is_featured': false,
        'condo_fee': null,
        'property_tax': '820',
        'images': [
          {'url': 'https://cdn/house.jpg', 'is_cover': true},
        ],
      };

      final property = propertyFromApiJson(json);

      expect(property.parkingSpots, 2);
      expect(property.type, 'Casa');
      expect(property.condoFee, 0);
      expect(property.taxes, 820);
      expect(property.amenities, ['Aceita pets']);
      expect(property.badges, isEmpty);
      expect(property.imageUrls, ['https://cdn/house.jpg']);
    });

    test('handles missing optional fields with safe defaults', () {
      final json = <String, dynamic>{
        'id': 'prop-3',
        'title': 'Studio',
        'description': '',
        'price': 'abc', // not parseable
        'address': '',
        'type': 'STUDIO',
      };

      final property = propertyFromApiJson(json);

      expect(property.priceValue, 0);
      expect(property.price, 'Sob consulta');
      expect(property.type, 'Studio');
      expect(property.imageUrls, isEmpty);
      expect(property.amenities, isEmpty);
      expect(property.badges, isEmpty);
      expect(property.address, isEmpty);
    });

    test('derives apartment thumbnail icon for APARTMENT type', () {
      final p = propertyFromApiJson({
        'id': '1',
        'title': 't',
        'description': 'd',
        'price': '1',
        'address': 'a',
        'type': 'APARTMENT',
      });
      expect(p.thumbnailIconCode, 0xe06a);
    });
  });
}
