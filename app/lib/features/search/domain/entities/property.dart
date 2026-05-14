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
    this.hasWifi = false,
    this.hasPool = false,
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

  /// Status operacional: `AVAILABLE` | `NEGOTIATING` | `RENTED`. Null
  /// quando o endpoint não devolve (usar default `AVAILABLE` na UI).
  final String? status;

  /// Inquilino atualmente associado ao imóvel (só faz sentido quando
  /// [status] == `RENTED` ou `NEGOTIATING`). Null caso contrário.
  final PropertyTenant? currentTenant;

  /// Imóvel anuncia Wi-Fi como amenidade. Vai como `hasWifi` no
  /// `GET /properties/search` e nos POST/PUT.
  final bool hasWifi;

  /// Imóvel anuncia piscina como amenidade. Vai como `hasPool`.
  final bool hasPool;

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
    bool? hasWifi,
    bool? hasPool,
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
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
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

/// Shape do inquilino atualmente vinculado a um imóvel. Inclui o flag
/// de identidade verificada para a UI exibir o checkmark ao lado do
/// nome ("Meus Inquilinos"). `identityVerifiedAt` ajuda a diferenciar
/// verificações recentes vs antigas, se a UI precisar.
@immutable
class PropertyTenant {
  const PropertyTenant({
    required this.id,
    required this.name,
    this.isIdentityVerified = false,
    this.identityVerifiedAt,
  });
  final String id;
  final String name;
  final bool isIdentityVerified;
  final DateTime? identityVerifiedAt;
}
