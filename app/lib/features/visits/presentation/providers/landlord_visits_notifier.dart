import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/visit_data_providers.dart';
import '../../domain/entities/visit.dart';

/// Loads the visits scheduled on properties owned by the current user (as
/// landlord). Mirrors MyVisitsNotifier but filters by `landlordId`.
class LandlordVisitsNotifier extends AsyncNotifier<List<Visit>> {
  @override
  Future<List<Visit>> build() async {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }
    final repo = ref.watch(visitRepositoryProvider);
    return repo.list(landlordId: userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null || userId.isEmpty) {
        throw const ServerFailure('Sessão expirada. Entre novamente.');
      }
      final repo = ref.read(visitRepositoryProvider);
      return repo.list(landlordId: userId);
    });
  }
}

final landlordVisitsNotifierProvider =
    AsyncNotifierProvider<LandlordVisitsNotifier, List<Visit>>(
  LandlordVisitsNotifier.new,
);
