import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/presentation/providers/search_filters_provider.dart';

/// Lista os imóveis do usuário corrente via
/// `GET /properties/search?landlordId=<uuid>` — o backend devolve todos os
/// status (AVAILABLE/IN_NEGOTIATION/RENTED) quando o filtro é aplicado.
class MyPropertiesNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() async {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }
    return _load(userId);
  }

  Future<List<Property>> _load(String userId) async {
    final repo = ref.read(dataPropertyRepositoryProvider);
    final result = await repo.searchProperties(
      SearchFilters(landlordId: userId),
    );
    return result.properties;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null || userId.isEmpty) {
        throw const ServerFailure('Sessão expirada.');
      }
      return _load(userId);
    });
  }

  Future<void> delete(String propertyId) async {
    final current = state.value ?? const <Property>[];
    await ref.read(dataPropertyRepositoryProvider).delete(propertyId);
    state = AsyncValue.data(
      current.where((p) => p.id != propertyId).toList(),
    );
  }
}

final myPropertiesNotifierProvider =
    AsyncNotifierProvider<MyPropertiesNotifier, List<Property>>(
  MyPropertiesNotifier.new,
);
