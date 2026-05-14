import 'package:app/core/error/failures.dart';

import '../../../search/domain/entities/property.dart';

/// Contract for fetching the full detail of a single property.
// ignore: one_member_abstracts
abstract class PropertyDetailRepository {
  /// Throws [ServerFailure] when the property does not exist or the backend
  /// returns an error; [NetworkFailure] on connectivity/timeout issues.
  Future<Property> getById(String id);
}
