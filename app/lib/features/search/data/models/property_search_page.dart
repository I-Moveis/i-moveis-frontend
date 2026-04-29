import '../../domain/entities/property.dart';

/// Data-layer DTO that carries a page of properties alongside the pagination
/// metadata returned by `GET /properties/search`. The domain layer consumes
/// this via `SearchResult`; the datasource interface returns it directly so
/// meta isn't smuggled through a side channel.
class PropertySearchPage {
  const PropertySearchPage({
    required this.properties,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<Property> properties;
  final int total;
  final int page;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
}
