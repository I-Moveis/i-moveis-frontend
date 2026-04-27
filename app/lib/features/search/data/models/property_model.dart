import 'package:hive/hive.dart';
import '../../domain/entities/property.dart';

part 'property_model.g.dart';

@HiveType(typeId: 0)
class PropertyModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double latitude;
  @HiveField(3)
  final double longitude;
  @HiveField(4)
  final String price;
  @HiveField(5)
  final double priceValue;
  @HiveField(6)
  final String description;
  @HiveField(7)
  final String type;
  @HiveField(8)
  final double area;
  @HiveField(9)
  final int bedrooms;
  @HiveField(10)
  final int bathrooms;
  @HiveField(11)
  final int parkingSpots;
  @HiveField(12)
  final double condoFee;
  @HiveField(13)
  final double taxes;
  @HiveField(14)
  final int thumbnailIconCode;
  @HiveField(15)
  final List<String> imageUrls;
  @HiveField(16)
  final bool isFavorite;

  PropertyModel({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.priceValue,
    required this.description,
    required this.type,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpots,
    required this.condoFee,
    required this.taxes,
    required this.thumbnailIconCode,
    required this.imageUrls,
    required this.isFavorite,
  });

  factory PropertyModel.fromEntity(Property entity) {
    return PropertyModel(
      id: entity.id,
      title: entity.title,
      latitude: entity.latitude,
      longitude: entity.longitude,
      price: entity.price,
      priceValue: entity.priceValue,
      description: entity.description,
      type: entity.type,
      area: entity.area,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      parkingSpots: entity.parkingSpots,
      condoFee: entity.condoFee,
      taxes: entity.taxes,
      thumbnailIconCode: entity.thumbnailIconCode,
      imageUrls: entity.imageUrls,
      isFavorite: entity.isFavorite,
    );
  }

  Property toEntity() {
    return Property(
      id: id,
      title: title,
      latitude: latitude,
      longitude: longitude,
      price: price,
      priceValue: priceValue,
      description: description,
      type: type,
      area: area,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      parkingSpots: parkingSpots,
      condoFee: condoFee,
      taxes: taxes,
      thumbnailIconCode: thumbnailIconCode,
      imageUrls: imageUrls,
      isFavorite: isFavorite,
    );
  }
}
