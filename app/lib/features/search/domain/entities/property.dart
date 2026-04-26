/// Pure domain entity for Property, independent of UI frameworks.
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.description,
    required this.type,
    this.thumbnailIconCode = 0xe06a, // Default to apartment icon
    this.imageUrls = const [],
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String price;
  final String description;
  final String type;
  final int thumbnailIconCode;
  final List<String> imageUrls;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
