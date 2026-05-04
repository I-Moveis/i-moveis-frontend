import '../../domain/entities/property.dart';
import '../../domain/entities/property_input.dart';

/// Parses a JSON object returned by `GET /properties/search` or
/// `GET /properties/:id` into a domain [Property].
///
/// The API returns camelCase keys for all endpoints EXCEPT when the search
/// uses `orderBy=nearest`, which returns snake_case. This reader falls back
/// between both variants on every field that has a snake-case name.
Property propertyFromApiJson(Map<String, dynamic> json) {
  final priceValue =
      double.tryParse((json['price'] ?? '0').toString()) ?? 0;
  final type = (json['type'] ?? 'APARTMENT').toString();
  final address = _buildAddress(json);
  final images = _imageUrls(json['images']);

  return Property(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    latitude: _toDouble(json['latitude']) ?? 0,
    longitude: _toDouble(json['longitude']) ?? 0,
    price: _formatPrice(priceValue),
    priceValue: priceValue,
    description: json['description'] as String? ?? '',
    type: _typeLabel(type),
    area: _toDouble(json['area']) ?? 0,
    bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
    bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
    parkingSpots:
        (_pick(json, 'parkingSpots', 'parking_spots') as num?)?.toInt() ?? 0,
    condoFee: _toDouble(_pick(json, 'condoFee', 'condo_fee')) ?? 0,
    taxes: _toDouble(_pick(json, 'propertyTax', 'property_tax')) ?? 0,
    thumbnailIconCode: _thumbnailIcon(type),
    imageUrls: images,
    address: address,
    amenities: _deriveAmenities(json),
    badges: _deriveBadges(json),
    landlordId: _pick(json, 'landlordId', 'landlord_id') as String?,
    moderationStatus:
        _pick(json, 'moderationStatus', 'moderation_status') as String?,
  );
}

/// Builds the body for `POST /api/properties`. Required fields
/// (`landlordId`, `title`, `description`, `price`, `address`) throw
/// `ArgumentError` if absent — callers should validate before reaching
/// this layer. Price is serialised as a string per the API contract.
Map<String, dynamic> propertyToCreateJson(PropertyInput input) {
  final landlordId = input.landlordId;
  final title = input.title;
  final description = input.description;
  final price = input.price;
  final address = input.address;

  if (landlordId == null || title == null || description == null ||
      price == null || address == null) {
    throw ArgumentError(
        'landlordId, title, description, price and address are required '
        'for property creation');
  }

  final body = <String, dynamic>{
    'landlordId': landlordId,
    'title': title,
    'description': description,
    'price': price.toStringAsFixed(2),
    'address': address,
  };

  _putIfNotNull(body, 'city', input.city);
  _putIfNotNull(body, 'state', input.state);
  _putIfNotNull(body, 'zipCode', input.zipCode);
  _putIfNotNull(body, 'type', input.type);
  _putIfNotNull(body, 'bedrooms', input.bedrooms);
  _putIfNotNull(body, 'bathrooms', input.bathrooms);
  _putIfNotNull(body, 'parkingSpots', input.parkingSpots);
  _putIfNotNull(body, 'area', input.area);
  _putIfNotNull(body, 'isFurnished', input.isFurnished);
  _putIfNotNull(body, 'petsAllowed', input.petsAllowed);
  _putIfNotNull(body, 'latitude', input.latitude);
  _putIfNotNull(body, 'longitude', input.longitude);
  _putIfNotNull(body, 'nearSubway', input.nearSubway);
  _putIfNotNull(body, 'isFeatured', input.isFeatured);
  _putIfNotNull(body, 'status', input.status);
  if (input.condoFee != null) {
    body['condoFee'] = input.condoFee!.toStringAsFixed(2);
  }
  if (input.propertyTax != null) {
    body['propertyTax'] = input.propertyTax!.toStringAsFixed(2);
  }

  return body;
}

/// Builds the body for `PUT /api/properties/:id`. Only includes fields
/// explicitly set on [input] — null means "keep what the backend has".
Map<String, dynamic> propertyToPatchJson(PropertyInput input) {
  final body = <String, dynamic>{};

  _putIfNotNull(body, 'title', input.title);
  _putIfNotNull(body, 'description', input.description);
  if (input.price != null) {
    body['price'] = input.price!.toStringAsFixed(2);
  }
  _putIfNotNull(body, 'address', input.address);
  _putIfNotNull(body, 'city', input.city);
  _putIfNotNull(body, 'state', input.state);
  _putIfNotNull(body, 'zipCode', input.zipCode);
  _putIfNotNull(body, 'type', input.type);
  _putIfNotNull(body, 'bedrooms', input.bedrooms);
  _putIfNotNull(body, 'bathrooms', input.bathrooms);
  _putIfNotNull(body, 'parkingSpots', input.parkingSpots);
  _putIfNotNull(body, 'area', input.area);
  _putIfNotNull(body, 'isFurnished', input.isFurnished);
  _putIfNotNull(body, 'petsAllowed', input.petsAllowed);
  _putIfNotNull(body, 'latitude', input.latitude);
  _putIfNotNull(body, 'longitude', input.longitude);
  _putIfNotNull(body, 'nearSubway', input.nearSubway);
  _putIfNotNull(body, 'isFeatured', input.isFeatured);
  _putIfNotNull(body, 'status', input.status);
  if (input.condoFee != null) {
    body['condoFee'] = input.condoFee!.toStringAsFixed(2);
  }
  if (input.propertyTax != null) {
    body['propertyTax'] = input.propertyTax!.toStringAsFixed(2);
  }

  return body;
}

void _putIfNotNull(Map<String, dynamic> map, String key, Object? value) {
  if (value != null) map[key] = value;
}

// Helpers ------------------------------------------------------------------

Object? _pick(Map<String, dynamic> json, String camel, String snake) {
  return json[camel] ?? json[snake];
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _formatPrice(double value) {
  if (value <= 0) return 'Sob consulta';
  return 'R\$ ${value.round()}';
}

// NOTE (presentation-leak): `_typeLabel` and `_thumbnailIcon` translate API
// enums into PT-BR labels and Material icon codepoints. That's a presentation
// concern currently living inside the domain entity's fields (type is a free
// String, thumbnailIconCode is an int). Move to a formatter in the
// presentation layer when the entity is split from the API DTO.
String _typeLabel(String apiType) {
  switch (apiType) {
    case 'APARTMENT':
      return 'Apartamento';
    case 'HOUSE':
      return 'Casa';
    case 'STUDIO':
      return 'Studio';
    case 'CONDO_HOUSE':
      return 'Casa em condomínio';
    default:
      return 'Imóvel';
  }
}

int _thumbnailIcon(String apiType) {
  switch (apiType) {
    case 'HOUSE':
      return 0xe318; // Icons.home_rounded
    case 'STUDIO':
      return 0xe63d; // Icons.weekend_rounded
    case 'CONDO_HOUSE':
      return 0xe586; // Icons.villa_rounded
    case 'APARTMENT':
    default:
      return 0xe06a; // Icons.apartment_rounded
  }
}

String _buildAddress(Map<String, dynamic> json) {
  final parts = <String>[
    (json['address'] as String?) ?? '',
    (json['city'] as String?) ?? '',
    (json['state'] as String?) ?? '',
  ].where((s) => s.isNotEmpty).toList();
  return parts.join(', ');
}

List<String> _imageUrls(Object? raw) {
  if (raw is! List) return const [];
  final entries = raw.whereType<Map<dynamic, dynamic>>().map((m) {
    final url = (m['url'] ?? '').toString();
    final isCover = m['isCover'] == true || m['is_cover'] == true;
    return _ImageEntry(url: url, isCover: isCover);
  }).where((e) => e.url.isNotEmpty).toList()
    ..sort((a, b) => (a.isCover ? 0 : 1).compareTo(b.isCover ? 0 : 1));
  return entries.map((e) => e.url).toList();
}

class _ImageEntry {
  const _ImageEntry({required this.url, required this.isCover});
  final String url;
  final bool isCover;
}

List<String> _deriveAmenities(Map<String, dynamic> json) {
  final out = <String>[];
  if (_pick(json, 'isFurnished', 'is_furnished') == true) out.add('Mobiliado');
  if (_pick(json, 'petsAllowed', 'pets_allowed') == true) {
    out.add('Aceita pets');
  }
  if (_pick(json, 'nearSubway', 'near_subway') == true) {
    out.add('Próximo ao metrô');
  }
  return out;
}

List<String> _deriveBadges(Map<String, dynamic> json) {
  final out = <String>[];
  if (_pick(json, 'isFeatured', 'is_featured') == true) out.add('Destaque');
  return out;
}
