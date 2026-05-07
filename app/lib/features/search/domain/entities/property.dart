import 'package:flutter/foundation.dart';

/// Pure domain entity for Property, independent of UI frameworks.
@immutable
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.price, // Display price (e.g. "R$ 2.500")
    required this.priceValue, // Numeric price for calculations
    required this.description,
    required this.type,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpots,
    this.condoFee = 0,
    this.taxes = 0,
    this.thumbnailIconCode = 0xe06a, // Default to apartment icon
    this.imageUrls = const [],
    this.coverImageUrl,
    this.isFavorite = false,
    this.address = '',
    this.amenities = const [],
    this.badges = const [],
    this.ownerName = '',
    this.ownerMemberSince = '',
    this.landlordId,
    this.moderationStatus,
    this.status,
    this.currentTenant,
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String price;
  final double priceValue;
  final String description;
  final String type;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final int parkingSpots;
  final double condoFee;
  final double taxes;
  final int thumbnailIconCode;
  final List<String> imageUrls;

  /// URL da foto explicitamente marcada como capa no backend. Se nenhuma
  /// foto vier com `isCover=true`, cai pra primeira de [imageUrls]. Null
  /// quando o imóvel não tem foto nenhuma — a UI decide o placeholder.
  final String? coverImageUrl;

  final bool isFavorite;

  /// Display address (e.g. "Vila Madalena, São Paulo - SP")
  final String address;

  /// Amenities list (e.g. ["Piscina", "Academia", "Portaria 24h"])
  final List<String> amenities;

  /// Highlight badges shown in the header (e.g. ["Exclusivo", "Novo"])
  final List<String> badges;

  /// Owner display name
  final String ownerName;

  /// Owner membership info (e.g. "Membro desde 2023")
  final String ownerMemberSince;

  /// UUID do proprietário (LANDLORD). Só é preenchido quando o endpoint
  /// retorna o campo (ex: /properties/:id, /admin/properties).
  /// GET /properties/search historicamente não devolve.
  final String? landlordId;

  /// `PENDING` | `APPROVED` | `REJECTED`. Null para fontes públicas que
  /// filtram internamente para APPROVED.
  final String? moderationStatus;

  /// Status operacional: `AVAILABLE` | `IN_NEGOTIATION` | `RENTED`. Null
  /// quando o endpoint não devolve (usar default `AVAILABLE` na UI).
  final String? status;

  /// Inquilino atualmente associado ao imóvel (só faz sentido quando
  /// [status] == `RENTED` ou `IN_NEGOTIATION`). Null caso contrário.
  /// Hoje o backend não devolve esse shape ainda — ver docs/BACKEND_*.md.
  final PropertyTenant? currentTenant;

  double get totalPrice => priceValue + condoFee + taxes;

  Property copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    String? price,
    double? priceValue,
    String? description,
    String? type,
    double? area,
    int? bedrooms,
    int? bathrooms,
    int? parkingSpots,
    double? condoFee,
    double? taxes,
    int? thumbnailIconCode,
    List<String>? imageUrls,
    String? coverImageUrl,
    bool? isFavorite,
    String? address,
    List<String>? amenities,
    List<String>? badges,
    String? ownerName,
    String? ownerMemberSince,
    String? landlordId,
    String? moderationStatus,
    String? status,
    PropertyTenant? currentTenant,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      description: description ?? this.description,
      type: type ?? this.type,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      condoFee: condoFee ?? this.condoFee,
      taxes: taxes ?? this.taxes,
      thumbnailIconCode: thumbnailIconCode ?? this.thumbnailIconCode,
      imageUrls: imageUrls ?? this.imageUrls,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      address: address ?? this.address,
      amenities: amenities ?? this.amenities,
      badges: badges ?? this.badges,
      ownerName: ownerName ?? this.ownerName,
      ownerMemberSince: ownerMemberSince ?? this.ownerMemberSince,
      landlordId: landlordId ?? this.landlordId,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      status: status ?? this.status,
      currentTenant: currentTenant ?? this.currentTenant,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isFavorite == other.isFavorite; // Important for UI updates

  @override
  int get hashCode => id.hashCode ^ isFavorite.hashCode;
}

/// Shape mínimo pra linkar um inquilino a um imóvel — só o que a UI
/// do landlord precisa pra mostrar o nome e abrir chat. Expandir quando
/// o backend definir o shape real do relacionamento property↔tenant.
@immutable
class PropertyTenant {
  const PropertyTenant({required this.id, required this.name});
  final String id;
  final String name;
}
