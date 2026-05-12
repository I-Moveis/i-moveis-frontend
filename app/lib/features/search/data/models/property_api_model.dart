import '../../../../core/constants.dart';
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
  final imagesResult = _parseImages(json['images']);

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
    imageUrls: imagesResult.urls,
    coverImageUrl: imagesResult.cover,
    address: address,
    amenities: _deriveAmenities(json),
    badges: _deriveBadges(json),
    landlordId: _pick(json, 'landlordId', 'landlord_id') as String?,
    moderationStatus:
        _pick(json, 'moderationStatus', 'moderation_status') as String?,
    status: json['status'] as String?,
    currentTenant: _parseTenant(
      _pick(json, 'currentTenant', 'current_tenant') ?? json['tenant'],
    ),
    hasWifi: _pick(json, 'hasWifi', 'has_wifi') == true,
    hasPool: _pick(json, 'hasPool', 'has_pool') == true,
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
  _putIfNotNull(body, 'hasWifi', input.hasWifi);
  _putIfNotNull(body, 'hasPool', input.hasPool);
  if (input.condoFee != null) {
    body['condoFee'] = input.condoFee!.toStringAsFixed(2);
  }
  if (input.propertyTax != null) {
    body['propertyTax'] = input.propertyTax!.toStringAsFixed(2);
  }
  if (input.images != null) {
    body['images'] = input.images!.map((i) => i.toJson()).toList();
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
  _putIfNotNull(body, 'hasWifi', input.hasWifi);
  _putIfNotNull(body, 'hasPool', input.hasPool);
  if (input.condoFee != null) {
    body['condoFee'] = input.condoFee!.toStringAsFixed(2);
  }
  if (input.propertyTax != null) {
    body['propertyTax'] = input.propertyTax!.toStringAsFixed(2);
  }
  if (input.images != null) {
    body['images'] = input.images!.map((i) => i.toJson()).toList();
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
    case 'KITNET':
      return 'Kitnet';
    case 'PENTHOUSE':
      return 'Cobertura';
    case 'LAND':
      return 'Terreno';
    case 'COMMERCIAL':
      return 'Comercial';
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
    case 'KITNET':
      return 0xe1bd; // Icons.bed_rounded
    case 'PENTHOUSE':
      return 0xe7d8; // Icons.holiday_village_rounded
    case 'LAND':
      return 0xe22e; // Icons.terrain_rounded
    case 'COMMERCIAL':
      return 0xe0af; // Icons.business_rounded
    case 'APARTMENT':
    default:
      return 0xe06a; // Icons.apartment_rounded
  }
}

String _buildAddress(Map<String, dynamic> json) {
  // Try multiple common keys for the main address/street part
  final mainAddress = json['address'] ?? 
                     json['street'] ?? 
                     json['street_address'] ?? 
                     json['location'] ?? 
                     '';
                     
  final parts = <String>[
    mainAddress.toString(),
    (json['city'] as String?) ?? '',
    (json['state'] as String?) ?? '',
  ].where((s) => s.isNotEmpty && s != 'null').toList();
  return parts.join(', ');
}

/// Resultado do parse de `images[]` — lista ordenada (capa primeiro) +
/// URL da capa explicitamente marcada. Quando nenhum item vem com
/// `isCover=true`, `cover` é `null` e a UI decide usar `urls.first` ou
/// um placeholder.
class _ImagesParseResult {
  const _ImagesParseResult({required this.urls, required this.cover});
  final List<String> urls;
  final String? cover;
}

_ImagesParseResult _parseImages(Object? raw) {
  // Aceita dois shapes do backend:
  //   - `images: [{ url, isCover }]` — caminho atual (US-006/007);
  //   - `images: ["url1", "url2"]`   — caso legado/simplificado.
  // Em ambos os casos, URL pode ser relativa (`/uploads/...`) ou
  // absoluta (CDN). Hidrata com `absoluteImageUrl` pra que `Image.network`
  // consiga carregar — backend serve as fotos em `/api/uploads/*` via
  // express-static (path incluso no `kApiBaseUrl`).
  if (raw is! List) return const _ImagesParseResult(urls: [], cover: null);
  // Hidratação em dois passos: `absoluteImageUrl` resolve path relativo →
  // URL absoluta usando `kApiBaseUrl`; `_normalizeLocalHost` troca hosts
  // de emulador (`10.0.2.2`, `127.0.0.1`) por `localhost` pra funcionar
  // também em dispositivo físico conectado via `adb reverse`.
  String hydrate(String url) => _normalizeLocalHost(absoluteImageUrl(url));
  final entries = <_ImageEntry>[];
  for (final item in raw) {
    if (item is Map) {
      final url = (item['url'] ?? '').toString();
      if (url.isEmpty) continue;
      final isCover = item['isCover'] == true || item['is_cover'] == true;
      entries.add(_ImageEntry(url: hydrate(url), isCover: isCover));
    } else if (item is String) {
      if (item.isEmpty) continue;
      // No shape de array de strings, não há marcador `isCover` — o primeiro
      // é tratado como capa por convenção.
      entries.add(_ImageEntry(
        url: hydrate(item),
        isCover: entries.isEmpty,
      ));
    }
  }
  entries.sort((a, b) => (a.isCover ? 0 : 1).compareTo(b.isCover ? 0 : 1));

  final cover = entries.firstWhere(
    (e) => e.isCover,
    orElse: () => const _ImageEntry(url: '', isCover: false),
  ).url;

  return _ImagesParseResult(
    urls: entries.map((e) => e.url).toList(),
    cover: cover.isEmpty ? null : cover,
  );
}

class _ImageEntry {
  const _ImageEntry({required this.url, required this.isCover});
  final String url;
  final bool isCover;
}

/// Reescreve hosts de emulador (10.0.2.2, 127.0.0.1) para o host
/// configurado em `kApiBaseUrl`. Emulador usa `adb reverse` e precisa
/// de `localhost`; dispositivo físico na mesma rede WiFi usa o IP real.
String _normalizeLocalHost(String url) {
  if (url.isEmpty) return url;
  try {
    final uri = Uri.parse(url);
    if (uri.host == '10.0.2.2' || uri.host == '127.0.0.1') {
      final apiUri = Uri.tryParse(kApiBaseUrl);
      if (apiUri != null) {
        return uri.replace(host: apiUri.host, port: apiUri.port).toString();
      }
    }
  } on FormatException {
    // URL malformada — devolve como veio; a UI já lida com carga falha.
  }
  return url;
}

/// Lê o shape do inquilino atual do imóvel. Aceita dois formatos:
/// `{"id": "...", "name": "..."}` e uma variante achatada onde o backend
/// devolve `tenantId` + `tenantName` direto no objeto Property — ambos
/// dão no mesmo pra UI. Retorna `null` se faltar dado essencial.
PropertyTenant? _parseTenant(Object? raw) {
  if (raw is Map) {
    final id = (raw['id'] ?? raw['userId'] ?? raw['tenantId'])?.toString();
    final name = (raw['name'] ?? raw['fullName'])?.toString();
    if (id != null && id.isNotEmpty && name != null && name.isNotEmpty) {
      final verifiedAtRaw = (raw['identityVerifiedAt'] ??
              raw['identity_verified_at'])
          ?.toString();
      return PropertyTenant(
        id: id,
        name: name,
        isIdentityVerified: (raw['isIdentityVerified'] ??
                raw['is_identity_verified']) ==
            true,
        identityVerifiedAt: verifiedAtRaw == null
            ? null
            : DateTime.tryParse(verifiedAtRaw)?.toLocal(),
      );
    }
  }
  return null;
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
