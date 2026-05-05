import 'package:flutter/foundation.dart';

import '../../../search/domain/entities/property.dart';

/// Página retornada por `GET /api/admin/properties`.
@immutable
class PaginatedProperties {
  const PaginatedProperties({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Property> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
