import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../search/domain/entities/property.dart';
import '../../data/mock_property_datasource.dart';

/// Fetches a single [Property] by ID from the mock datasource.
/// Will be replaced by a real repository call when the back-end is ready.
final propertyDetailProvider =
    FutureProvider.family<Property, String>((ref, propertyId) async {
  // Simulate network latency
  await Future<void>.delayed(const Duration(milliseconds: 400));

  final property = kMockProperties.firstWhere(
    (p) => p.id == propertyId,
    orElse: () => throw Exception('Imóvel não encontrado: $propertyId'),
  );

  return property;
});
