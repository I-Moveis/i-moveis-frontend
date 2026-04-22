import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Model representing search filters.

@immutable
class SearchFilters {

  const SearchFilters({
    this.location = '',
    this.bedrooms = 0, // 0 means "Any"
    this.priceRange = const RangeValues(0, 50000),
    this.transactionType = 'Aluguel',
    this.propertyType,
  });


  final String location;
  final int bedrooms;
  final RangeValues priceRange;
  final String transactionType;
  final String? propertyType;

  SearchFilters copyWith({
    String? location,
    int? bedrooms,
    RangeValues? priceRange,
    String? transactionType,
    String? propertyType,
  }) {
    return SearchFilters(
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      priceRange: priceRange ?? this.priceRange,
      transactionType: transactionType ?? this.transactionType,
      propertyType: propertyType ?? this.propertyType,
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
          transactionType == other.transactionType &&
          propertyType == other.propertyType;

  @override
  int get hashCode => 
      location.hashCode ^ 
      bedrooms.hashCode ^ 
      priceRange.hashCode ^ 
      transactionType.hashCode ^ 
      propertyType.hashCode;
}

/// Notifier to manage search filter state.
class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateBedrooms(int bedrooms) {
    state = state.copyWith(bedrooms: bedrooms);
  }

  void updatePriceRange(RangeValues priceRange) {
    state = state.copyWith(priceRange: priceRange);
  }

  void updateTransactionType(String type) {
    state = state.copyWith(transactionType: type);
  }

  void updatePropertyType(String? type) {
    state = state.copyWith(propertyType: type);
  }

  void reset() {
    state = const SearchFilters();
  }
}

/// Riverpod provider for search filters.
final searchFiltersProvider = NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);
