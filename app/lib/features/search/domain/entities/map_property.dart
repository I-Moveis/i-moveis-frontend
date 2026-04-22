import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProperty {
  const MapProperty({
    required this.id,
    required this.position,
    required this.title,
    required this.price,
    required this.type,
    required this.thumbnailIcon,
    this.imageUrls = const [],
  });

  final String id;
  final LatLng position;
  final String title;
  final String price;
  final String type;
  final IconData thumbnailIcon;
  final List<String> imageUrls;
}
