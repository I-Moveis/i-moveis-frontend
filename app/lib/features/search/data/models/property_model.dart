import '../../domain/entities/property.dart';

class PropertyModel {
  static Map<String, dynamic> toMap(Property entity) {
    return {
      'id': entity.id,
      'title': entity.title,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
      'price': entity.price,
      'priceValue': entity.priceValue,
      'description': entity.description,
      'type': entity.type,
      'area': entity.area,
      'bedrooms': entity.bedrooms,
      'bathrooms': entity.bathrooms,
      'parkingSpots': entity.parkingSpots,
      'condoFee': entity.condoFee,
      'taxes': entity.taxes,
      'thumbnailIconCode': entity.thumbnailIconCode,
      'imageUrls': entity.imageUrls,
      'isFavorite': entity.isFavorite,
    };
  }

  static Property fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as String,
      title: map['title'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      price: map['price'] as String,
      priceValue: (map['priceValue'] as num).toDouble(),
      description: map['description'] as String,
      type: map['type'] as String,
      area: (map['area'] as num).toDouble(),
      bedrooms: map['bedrooms'] as int,
      bathrooms: map['bathrooms'] as int,
      parkingSpots: map['parkingSpots'] as int,
      condoFee: (map['condoFee'] as num?)?.toDouble() ?? 0.0,
      taxes: (map['taxes'] as num?)?.toDouble() ?? 0.0,
      thumbnailIconCode: map['thumbnailIconCode'] as int? ?? 0xe06a,
      imageUrls: (map['imageUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
