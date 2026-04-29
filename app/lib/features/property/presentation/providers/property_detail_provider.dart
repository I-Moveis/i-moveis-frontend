import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/domain/entities/property.dart';
import '../../data/providers/property_detail_data_providers.dart';

/// Fetches a single [Property] by ID through the detail repository.
/// Swaps between mock and API based on `kUseMockData`.
final propertyDetailProvider =
    FutureProvider.family<Property, String>((ref, propertyId) async {
  final repository = ref.watch(propertyDetailRepositoryProvider);
  return repository.getById(propertyId);
});
