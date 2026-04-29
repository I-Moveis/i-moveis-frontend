# AlphaToca — Guia de Integração Flutter (Dart)

Exemplos práticos de models Dart, chamadas HTTP e configuração Auth0 para o frontend.

---

## 🔧 Configuração Base

### Constantes
```dart
const String kBaseUrl = 'http://localhost:3000/api'; // dev
const String kAuth0Domain = 'your-tenant.auth0.com';
const String kAuth0ClientId = 'seu_client_id';
const String kAuth0Audience = 'https://alphatoca-api';
```

### Headers Helper
```dart
Map<String, String> authHeaders(String token) => {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};

Map<String, String> publicHeaders() => {
  'Content-Type': 'application/json',
};
```

---

## 📌 Enums Dart

```dart
enum Role { TENANT, LANDLORD, ADMIN }

enum PropertyStatus { AVAILABLE, IN_NEGOTIATION, RENTED }

enum PropertyType { APARTMENT, HOUSE, STUDIO, CONDO_HOUSE }

enum VisitStatus { SCHEDULED, CANCELLED, COMPLETED, NO_SHOW }

enum ChatStatus { ACTIVE_BOT, WAITING_HUMAN, RESOLVED }

enum ProcessStatus { TRIAGE, VISIT_SCHEDULED, CONTRACT_ANALYSIS, CLOSED }

enum MessageStatus { failed, sent, delivered, read }

enum SenderType { BOT, TENANT, LANDLORD }

enum DocumentType { IDENTITY, INCOME_PROOF, CONTRACT }
```

---

## 👤 UserModel

```dart
class UserModel {
  final String id;
  final String? auth0Sub;
  final String name;
  final String phoneNumber;
  final String role; // TENANT | LANDLORD | ADMIN
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.auth0Sub,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    auth0Sub: json['auth0Sub'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    role: json['role'] ?? 'TENANT',
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'role': role,
  };
}
```

---

## 🏠 PropertyModel

```dart
class PropertyImageModel {
  final String id;
  final String propertyId;
  final String url;
  final bool isCover;
  final String? caption;

  PropertyImageModel({
    required this.id,
    required this.propertyId,
    required this.url,
    required this.isCover,
    this.caption,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) =>
      PropertyImageModel(
        id: json['id'],
        propertyId: json['propertyId'] ?? json['property_id'] ?? '',
        url: json['url'],
        isCover: json['isCover'] ?? false,
        caption: json['caption'],
      );
}

class PropertyModel {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final double price;
  final String status;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String type;
  final int bedrooms;
  final int bathrooms;
  final int parkingSpots;
  final double area;
  final bool isFurnished;
  final bool petsAllowed;
  final double? latitude;
  final double? longitude;
  final bool nearSubway;
  final bool isFeatured;
  final int views;
  final double? condoFee;
  final double? propertyTax;
  final DateTime createdAt;
  final List<PropertyImageModel> images;

  PropertyModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.price,
    required this.status,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpots,
    required this.area,
    required this.isFurnished,
    required this.petsAllowed,
    this.latitude,
    this.longitude,
    required this.nearSubway,
    required this.isFeatured,
    required this.views,
    this.condoFee,
    this.propertyTax,
    required this.createdAt,
    this.images = const [],
  });

  /// Imagem de capa (ou primeira disponível)
  String? get coverImageUrl {
    final cover = images.where((img) => img.isCover).firstOrNull;
    return cover?.url ?? images.firstOrNull?.url;
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    id: json['id'],
    landlordId: json['landlordId'] ?? json['landlord_id'] ?? '',
    title: json['title'],
    description: json['description'],
    price: double.tryParse(json['price'].toString()) ?? 0,
    status: json['status'] ?? 'AVAILABLE',
    address: json['address'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'] ?? json['zip_code'],
    type: json['type'] ?? 'APARTMENT',
    bedrooms: json['bedrooms'] ?? 0,
    bathrooms: json['bathrooms'] ?? 0,
    parkingSpots: json['parkingSpots'] ?? json['parking_spots'] ?? 0,
    area: (json['area'] ?? 0).toDouble(),
    isFurnished: json['isFurnished'] ?? json['is_furnished'] ?? false,
    petsAllowed: json['petsAllowed'] ?? json['pets_allowed'] ?? false,
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    nearSubway: json['nearSubway'] ?? json['near_subway'] ?? false,
    isFeatured: json['isFeatured'] ?? json['is_featured'] ?? false,
    views: json['views'] ?? 0,
    condoFee: json['condoFee'] != null
        ? double.tryParse(json['condoFee'].toString())
        : (json['condo_fee'] != null
            ? double.tryParse(json['condo_fee'].toString())
            : null),
    propertyTax: json['propertyTax'] != null
        ? double.tryParse(json['propertyTax'].toString())
        : (json['property_tax'] != null
            ? double.tryParse(json['property_tax'].toString())
            : null),
    createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    images: (json['images'] as List<dynamic>?)
            ?.map((e) => PropertyImageModel.fromJson(e))
            .toList() ??
        [],
  );

  /// Body para POST /api/properties
  Map<String, dynamic> toCreateJson() => {
    'landlordId': landlordId,
    'title': title,
    'description': description,
    'price': price.toStringAsFixed(2), // ⚠️ ENVIAR COMO STRING
    'address': address,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (zipCode != null) 'zipCode': zipCode,
    'type': type,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'parkingSpots': parkingSpots,
    'area': area,
    'isFurnished': isFurnished,
    'petsAllowed': petsAllowed,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'nearSubway': nearSubway,
    'isFeatured': isFeatured,
  };
}
```

> ⚠️ **ATENÇÃO:** O campo `price` no JSON de resposta pode vir como string (Decimal do Prisma). Use `double.tryParse()`. No envio (POST/PUT), **deve ser string**: `"2500.00"`.

> ⚠️ **ATENÇÃO 2:** Na busca por proximidade (`orderBy=nearest`), os nomes dos campos retornam em **snake_case** (ex: `parking_spots`, `is_furnished`). O `fromJson` acima trata ambos os formatos.

---

## 📅 VisitModel

```dart
class VisitModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final String? rentalProcessId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisitModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    this.rentalProcessId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) => VisitModel(
    id: json['id'],
    propertyId: json['propertyId'],
    tenantId: json['tenantId'],
    landlordId: json['landlordId'],
    rentalProcessId: json['rentalProcessId'],
    scheduledAt: DateTime.parse(json['scheduledAt']),
    durationMinutes: json['durationMinutes'] ?? 45,
    status: json['status'] ?? 'SCHEDULED',
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  /// Body para POST /api/visits
  Map<String, dynamic> toCreateJson() => {
    'propertyId': propertyId,
    'tenantId': tenantId,
    'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    'durationMinutes': durationMinutes,
    if (rentalProcessId != null) 'rentalProcessId': rentalProcessId,
    if (notes != null) 'notes': notes,
  };

  /// Body para PATCH /api/visits/:id
  Map<String, dynamic> toUpdateJson({
    DateTime? newScheduledAt,
    int? newDuration,
    String? newStatus,
    String? newNotes,
  }) {
    final map = <String, dynamic>{};
    if (newScheduledAt != null) map['scheduledAt'] = newScheduledAt.toUtc().toIso8601String();
    if (newDuration != null) map['durationMinutes'] = newDuration;
    if (newStatus != null) map['status'] = newStatus;
    if (newNotes != null) map['notes'] = newNotes;
    return map;
  }
}

class AvailableSlot {
  final DateTime startsAt;
  final DateTime endsAt;

  AvailableSlot({required this.startsAt, required this.endsAt});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    startsAt: DateTime.parse(json['startsAt']),
    endsAt: DateTime.parse(json['endsAt']),
  );
}
```

---

## 📦 PaginatedResponse (para busca de properties)

```dart
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      PaginatedResponse(
        data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
        total: json['meta']['total'],
        page: json['meta']['page'],
        limit: json['meta']['limit'],
        totalPages: json['meta']['totalPages'],
      );
}
```

---

## 🌐 Exemplos de Chamadas HTTP

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// ========================
// PROPERTIES (públicas)
// ========================

// Busca com filtros
Future<PaginatedResponse<PropertyModel>> searchProperties({
  String? type,
  double? maxPrice,
  int? minBedrooms,
  String? city,
  int page = 1,
  int limit = 10,
}) async {
  final params = <String, String>{
    'page': '$page',
    'limit': '$limit',
    if (type != null) 'type': type,
    if (maxPrice != null) 'maxPrice': '$maxPrice',
    if (minBedrooms != null) 'minBedrooms': '$minBedrooms',
    if (city != null) 'city': city,
  };

  final uri = Uri.parse('$kBaseUrl/properties/search')
      .replace(queryParameters: params);

  final res = await http.get(uri, headers: publicHeaders());
  final json = jsonDecode(res.body);
  return PaginatedResponse.fromJson(json, PropertyModel.fromJson);
}

// Detalhe do imóvel
Future<PropertyModel> getProperty(String id) async {
  final res = await http.get(
    Uri.parse('$kBaseUrl/properties/$id'),
    headers: publicHeaders(),
  );
  return PropertyModel.fromJson(jsonDecode(res.body));
}

// ========================
// USER (autenticada)
// ========================

// Perfil do usuário logado
Future<UserModel> getMyProfile(String token) async {
  final res = await http.get(
    Uri.parse('$kBaseUrl/users/me'),
    headers: authHeaders(token),
  );
  return UserModel.fromJson(jsonDecode(res.body));
}

// ========================
// VISITS (autenticada)
// ========================

// Agendar visita
Future<VisitModel> createVisit({
  required String token,
  required String propertyId,
  required String tenantId,
  required DateTime scheduledAt,
  int durationMinutes = 45,
  String? notes,
}) async {
  final res = await http.post(
    Uri.parse('$kBaseUrl/visits'),
    headers: authHeaders(token),
    body: jsonEncode({
      'propertyId': propertyId,
      'tenantId': tenantId,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes,
      if (notes != null) 'notes': notes,
    }),
  );

  if (res.statusCode == 409) {
    throw Exception('Conflito de agenda');
  }
  return VisitModel.fromJson(jsonDecode(res.body));
}

// Consultar disponibilidade
Future<List<AvailableSlot>> getAvailability({
  required String token,
  required String propertyId,
  required DateTime from,
  required DateTime to,
  int slotMinutes = 45,
}) async {
  final params = {
    'propertyId': propertyId,
    'from': from.toUtc().toIso8601String(),
    'to': to.toUtc().toIso8601String(),
    'slotMinutes': '$slotMinutes',
  };

  final uri = Uri.parse('$kBaseUrl/visits/availability')
      .replace(queryParameters: params);

  final res = await http.get(uri, headers: authHeaders(token));
  final list = jsonDecode(res.body) as List;
  return list.map((e) => AvailableSlot.fromJson(e)).toList();
}

// Cancelar visita
Future<void> cancelVisit(String token, String visitId) async {
  await http.delete(
    Uri.parse('$kBaseUrl/visits/$visitId'),
    headers: authHeaders(token),
  );
}
```

---

## ⚡ Checklist de Integração

- [ ] Configurar Auth0 no Flutter (`flutter_appauth` ou `auth0_flutter`)
- [ ] Implementar models Dart (acima)
- [ ] Criar service/repository layer com as chamadas HTTP
- [ ] Tratar erros padrão (`status`, `code`, `messages`)
- [ ] `price` sempre como **string** no POST, parse com `double.tryParse` no GET
- [ ] `scheduledAt` sempre em **UTC ISO-8601**
- [ ] Tratar `409 CONFLICT` no agendamento de visitas
- [ ] Tratar `401 UNAUTHORIZED` com refresh token do Auth0
- [ ] Tratar `403 FORBIDDEN` para features admin-only
- [ ] Tratar campos snake_case na busca por proximidade (`nearest`)
