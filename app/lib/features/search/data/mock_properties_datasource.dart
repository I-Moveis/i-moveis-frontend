import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/entities/map_property.dart';

const LatLng kMapInitialCenter = LatLng(-23.5613, -46.6565);
const double kMapInitialZoom = 13.5;

final List<MapProperty> kMockMapProperties = <MapProperty>[
  const MapProperty(
    id: 'mp-1',
    position: LatLng(-23.5613, -46.6565),
    title: 'Cobertura Jardins',
    price: r'R$ 2.450.000',
    type: 'Cobertura · 3 suítes',
    thumbnailIcon: Icons.apartment_rounded,
    imageUrls: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0bb2a6c3e?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  const MapProperty(
    id: 'mp-2',
    position: LatLng(-23.5558, -46.6396),
    title: 'Apartamento Paulista',
    price: r'R$ 1.180.000',
    type: 'Apartamento · 2 quartos',
    thumbnailIcon: Icons.apartment_rounded,
    imageUrls: [
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  const MapProperty(
    id: 'mp-3',
    position: LatLng(-23.5672, -46.6921),
    title: 'Casa Pinheiros',
    price: r'R$ 3.100.000',
    type: 'Casa · 4 quartos',
    thumbnailIcon: Icons.home_rounded,
    imageUrls: [
      'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  const MapProperty(
    id: 'mp-4',
    position: LatLng(-23.5440, -46.6441),
    title: 'Studio Consolação',
    price: r'R$ 520.000',
    type: 'Studio · 1 dorm.',
    thumbnailIcon: Icons.weekend_rounded,
    imageUrls: [
      'https://images.unsplash.com/photo-1536376074432-bf12177d4f4f?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  const MapProperty(
    id: 'mp-5',
    position: LatLng(-23.5872, -46.6789),
    title: 'Loft Vila Madalena',
    price: r'R$ 890.000',
    type: 'Loft · 1 suíte',
    thumbnailIcon: Icons.king_bed_rounded,
  ),
  const MapProperty(
    id: 'mp-6',
    position: LatLng(-23.5729, -46.6420),
    title: 'Apartamento Bela Vista',
    price: r'R$ 745.000',
    type: 'Apartamento · 2 quartos',
    thumbnailIcon: Icons.apartment_rounded,
  ),
  const MapProperty(
    id: 'mp-7',
    position: LatLng(-23.5505, -46.6706),
    title: 'Casa Higienópolis',
    price: r'R$ 4.300.000',
    type: 'Casa · 5 quartos',
    thumbnailIcon: Icons.villa_rounded,
  ),
  const MapProperty(
    id: 'mp-8',
    position: LatLng(-23.5475, -46.6361),
    title: 'Apartamento República',
    price: r'R$ 620.000',
    type: 'Apartamento · 2 quartos',
    thumbnailIcon: Icons.apartment_rounded,
  ),
];
