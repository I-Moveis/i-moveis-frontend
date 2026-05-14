import 'dart:async';

import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/visit_data_providers.dart';
import '../../domain/entities/visit.dart';

/// Loads the visits the current user has scheduled as a tenant, and supports
/// cancel/refresh actions. Exposed as an `AsyncNotifier<List<Visit>>` so the
/// UI can use `state.when(...)` to render loading/error/data uniformly.
class MyVisitsNotifier extends AsyncNotifier<List<Visit>> {
  @override
  Future<List<Visit>> build() async {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }
    final repo = ref.watch(visitRepositoryProvider);
    return repo.list(tenantId: userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null || userId.isEmpty) {
        throw const ServerFailure('Sessão expirada. Entre novamente.');
      }
      final repo = ref.read(visitRepositoryProvider);
      return repo.list(tenantId: userId);
    });
  }

  /// Cancels a visit. On success replaces the item locally so the list
  /// refreshes without a full refetch. Rethrows [Failure] so the page can
  /// snackbar the error.
  Future<void> cancel(String visitId) async {
    final current = state.value ?? const <Visit>[];
    await ref.read(visitRepositoryProvider).cancel(visitId);
    // The API soft-deletes (status=CANCELLED). Remove from the list since
    // by default we show only non-cancelled items.
    state = AsyncValue.data(
      current.where((v) => v.id != visitId).toList(),
    );
  }
}

final myVisitsNotifierProvider =
    AsyncNotifierProvider<MyVisitsNotifier, List<Visit>>(
  MyVisitsNotifier.new,
);
