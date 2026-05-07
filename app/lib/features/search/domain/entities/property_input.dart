import 'package:flutter/foundation.dart';

/// Input shape for creating or updating a property. Fields mirror the API
/// payload (not the display entity), so booleans are booleans and price is
/// a numeric double — the data layer converts to the `"2500.00"` string the
/// backend expects.
///
/// All fields are nullable so the same class can be used for PATCH (partial
/// update, null = "don't change"). On create, `landlordId`, `title`,
/// `description`, `price`, and `address` must be non-null — enforced by the
/// notifier / repository.
@immutable
class PropertyInput {
  const PropertyInput({
    this.landlordId,
    this.title,
    this.description,
    this.price,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.type,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpots,
    this.area,
    this.isFurnished,
    this.petsAllowed,
    this.latitude,
    this.longitude,
    this.nearSubway,
    this.isFeatured,
    this.status,
    this.condoFee,
    this.propertyTax,
    this.images,
  });

  final String? landlordId;
  final String? title;
  final String? description;
  final double? price;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;

  /// API enum: `APARTMENT`, `HOUSE`, `STUDIO`, `CONDO_HOUSE`.
  final String? type;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpots;
  final double? area;
  final bool? isFurnished;
  final bool? petsAllowed;
  final double? latitude;
  final double? longitude;
  final bool? nearSubway;
  final bool? isFeatured;

  /// API enum: `AVAILABLE`, `IN_NEGOTIATION`, `RENTED`.
  final String? status;
  final double? condoFee;
  final double? propertyTax;
  final List<PropertyImageInput>? images;
}

@immutable
class PropertyImageInput {
  const PropertyImageInput({
    required this.url,
    this.isCover = false,
    this.caption,
  });

  final String url;
  final bool isCover;
  final String? caption;

  Map<String, dynamic> toJson() => {
        'url': url,
        'isCover': isCover,
        if (caption != null) 'caption': caption,
      };
}
