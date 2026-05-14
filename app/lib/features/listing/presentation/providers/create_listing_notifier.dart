import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/domain/entities/property_input.dart';
import 'my_properties_notifier.dart';

/// Form state carried by [CreateListingNotifier]. Immutable so we can rebuild
/// the page on every mutation via `state = state.copyWith(...)`.
@immutable
class CreateListingState {
  const CreateListingState({
    this.submitting = false,
    this.lastCreated,
  });

  final bool submitting;
  final Property? lastCreated;

  CreateListingState copyWith({
    bool? submitting,
    Property? lastCreated,
  }) {
    return CreateListingState(
      submitting: submitting ?? this.submitting,
      lastCreated: lastCreated ?? this.lastCreated,
    );
  }
}

/// Submits `POST /api/properties`. The page owns the form controllers; this
/// notifier only tracks the async lifecycle of the POST itself. Throws
/// [Failure] so the page can surface snackbars.
class CreateListingNotifier extends Notifier<CreateListingState> {
  @override
  CreateListingState build() => const CreateListingState();

  Future<Property> submit({
    required String title,
    required String description,
    required double price,
    required String address,
    String? city,
    String? state,
    String? zipCode,
    String? type,
    int? bedrooms,
    int? bathrooms,
    int? parkingSpots,
    double? area,
    bool? isFurnished,
    bool? petsAllowed,
    bool? nearSubway,
    bool? isFeatured,
    double? condoFee,
    double? propertyTax,
    List<XFile>? photos,
    // Campos UI-only (sem backend) — o PropertyInput carrega como
    // metadata pra o form manter estado, mas o datasource ignora no
    // JSON. Quando o backend adicionar, liga só aqui.
    String? extendedType,
    bool? hasWifi,
    bool? hasPool,
  }) async {
    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }

    this.state = this.state.copyWith(submitting: true);
    try {
      final repo = ref.read(dataPropertyRepositoryProvider);
      final created = await repo.create(PropertyInput(
        landlordId: userId,
        title: title,
        description: description,
        price: price,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        type: type,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        parkingSpots: parkingSpots,
        area: area,
        isFurnished: isFurnished,
        petsAllowed: petsAllowed,
        nearSubway: nearSubway,
        isFeatured: isFeatured,
        condoFee: condoFee,
        propertyTax: propertyTax,
        photos: photos,
        extendedType: extendedType,
        hasWifi: hasWifi,
        hasPool: hasPool,
      ));
      this.state = this.state.copyWith(
            submitting: false,
            lastCreated: created,
          );
      // Invalida o cache de "meus imóveis" pra que, quando a MyPropertiesPage
      // voltar ao topo da pilha (após pop do create), o notifier refetche e
      // a nova propriedade apareça. Sem isso, o usuário cria e acha que nada
      // aconteceu porque o cache antigo continua sendo exibido.
      ref.invalidate(myPropertiesNotifierProvider);
      return created;
    } on Failure {
      this.state = this.state.copyWith(submitting: false);
      rethrow;
    }
  }
}

final createListingNotifierProvider =
    NotifierProvider<CreateListingNotifier, CreateListingState>(
  CreateListingNotifier.new,
);
