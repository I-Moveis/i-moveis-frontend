import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model representing search filters with multi-selection support.
@immutable
class SearchFilters {
  const SearchFilters({
    this.location = '',
    this.bedrooms = const [], // Empty means "Any"
    this.priceRange = const RangeValues(0, 50000),
    this.transactionTypes = const [],
    this.propertyTypes = const [],
    this.hasWifi = false,
    this.hasPool = false,
    this.hasParking = false,
    this.isPetFriendly = false,
  });

  final String location;
  final List<int> bedrooms;
  final RangeValues priceRange;
  final List<String> transactionTypes;
  final List<String> propertyTypes;
  final bool hasWifi;
  final bool hasPool;
  final bool hasParking;
  final bool isPetFriendly;

  SearchFilters copyWith({
    String? location,
    List<int>? bedrooms,
    RangeValues? priceRange,
    List<String>? transactionTypes,
    List<String>? propertyTypes,
    bool? hasWifi,
    bool? hasPool,
    bool? hasParking,
    bool? isPetFriendly,
  }) {
    return SearchFilters(
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      priceRange: priceRange ?? this.priceRange,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
      hasParking: hasParking ?? this.hasParking,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          bedrooms == other.bedrooms &&
          priceRange == other.priceRange &&
          transactionTypes == other.transactionTypes &&
          propertyTypes == other.propertyTypes &&
          hasWifi == other.hasWifi &&
          hasPool == other.hasPool &&
          hasParking == other.hasParking &&
          isPetFriendly == other.isPetFriendly;

  @override
  int get hashCode =>
      location.hashCode ^
      bedrooms.hashCode ^
      priceRange.hashCode ^
      transactionTypes.hashCode ^
      propertyTypes.hashCode ^
      hasWifi.hashCode ^
      hasPool.hashCode ^
      hasParking.hashCode ^
      isPetFriendly.hashCode;
}

/// Notifier to manage search filters state.
class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void toggleBedroom(int count) {
    final current = List<int>.from(state.bedrooms);
    if (current.contains(count)) {
      current.remove(count);
    } else {
      current.add(count);
    }
    state = state.copyWith(bedrooms: current);
  }

  void updatePriceRange(RangeValues priceRange) {
    state = state.copyWith(priceRange: priceRange);
  }

  void toggleTransactionType(String type) {
    final current = List<String>.from(state.transactionTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(transactionTypes: current);
  }

  void togglePropertyType(String type) {
    final current = List<String>.from(state.propertyTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(propertyTypes: current);
  }

  void updateWifi(bool value) {
    state = state.copyWith(hasWifi: value);
  }

  void updatePool(bool value) {
    state = state.copyWith(hasPool: value);
  }

  void updateParking(bool value) {
    state = state.copyWith(hasParking: value);
  }

  void updatePetFriendly(bool value) {
    state = state.copyWith(isPetFriendly: value);
  }

  void reset() {
    state = const SearchFilters();
  }
}

/// Provider for the search filters state.
final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);
