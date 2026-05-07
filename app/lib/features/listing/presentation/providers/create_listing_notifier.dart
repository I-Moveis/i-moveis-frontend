import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/domain/entities/property_input.dart';

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
    double? condoFee,
    double? propertyTax,
    List<PropertyImageInput>? images,
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
        condoFee: condoFee,
        propertyTax: propertyTax,
        images: images,
      ));
      this.state = this.state.copyWith(
            submitting: false,
            lastCreated: created,
          );
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
