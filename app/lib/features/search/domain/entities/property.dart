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
    this.isFavorite = false,
    this.address = '',
    this.amenities = const [],
    this.badges = const [],
    this.ownerName = '',
    this.ownerMemberSince = '',
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
    bool? isFavorite,
    String? address,
    List<String>? amenities,
    List<String>? badges,
    String? ownerName,
    String? ownerMemberSince,
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
      isFavorite: isFavorite ?? this.isFavorite,
      address: address ?? this.address,
      amenities: amenities ?? this.amenities,
      badges: badges ?? this.badges,
      ownerName: ownerName ?? this.ownerName,
      ownerMemberSince: ownerMemberSince ?? this.ownerMemberSince,
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
