import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/visit_data_providers.dart';
import '../../domain/entities/visit.dart';

/// Fetches a single visit by id. Errors are surfaced as Failure subtypes
/// thrown from the repository; `AsyncValue.error` picks them up.
final visitDetailProvider =
    FutureProvider.family<Visit, String>((ref, visitId) async {
  final repo = ref.watch(visitRepositoryProvider);
  return repo.getById(visitId);
});
