import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/providers/shared_preferences_provider.dart';

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

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    try {
      return SearchFilters(
        location: json['location'] as String? ?? '',
        bedrooms: (json['bedrooms'] as List<dynamic>?)?.cast<int>() ?? const [],
        priceRange: RangeValues(
          (json['minPrice'] as num?)?.toDouble() ?? 0.0,
          (json['maxPrice'] as num?)?.toDouble() ?? 50000.0,
        ),
        transactionTypes: (json['transactionTypes'] as List<dynamic>?)?.cast<String>() ?? const [],
        propertyTypes: (json['propertyTypes'] as List<dynamic>?)?.cast<String>() ?? const [],
        hasWifi: json['hasWifi'] as bool? ?? false,
        hasPool: json['hasPool'] as bool? ?? false,
        hasParking: json['hasParking'] as bool? ?? false,
        isPetFriendly: json['isPetFriendly'] as bool? ?? false,
      );
    } catch (e) {
      // Return default filters if parsing fails (silently)
      return const SearchFilters();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'bedrooms': bedrooms,
      'minPrice': priceRange.start,
      'maxPrice': priceRange.end,
      'transactionTypes': transactionTypes,
      'propertyTypes': propertyTypes,
      'hasWifi': hasWifi,
      'hasPool': hasPool,
      'hasParking': hasParking,
      'isPetFriendly': isPetFriendly,
    };
  }

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
  static const _kFiltersKey = 'search_filters';

  @override
  SearchFilters build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonString = prefs.getString(_kFiltersKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return SearchFilters.fromJson(jsonMap);
      } catch (_) {
        // Silently fail and use default state
      }
    }
    return const SearchFilters();
  }

  void _persist() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setString(_kFiltersKey, json.encode(state.toJson()));
    } catch (_) {
      // Silently fail persistence
    }
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
    _persist();
  }

  void toggleBedroom(int count) {
    final current = List<int>.from(state.bedrooms);
    if (current.contains(count)) {
      current.remove(count);
    } else {
      current.add(count);
    }
    state = state.copyWith(bedrooms: current);
    _persist();
  }

  void updatePriceRange(RangeValues priceRange) {
    state = state.copyWith(priceRange: priceRange);
    _persist();
  }

  void toggleTransactionType(String type) {
    final current = List<String>.from(state.transactionTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(transactionTypes: current);
    _persist();
  }

  void togglePropertyType(String type) {
    final current = List<String>.from(state.propertyTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(propertyTypes: current);
    _persist();
  }

  void updateWifi(bool value) {
    state = state.copyWith(hasWifi: value);
    _persist();
  }

  void updatePool(bool value) {
    state = state.copyWith(hasPool: value);
    _persist();
  }

  void updateParking(bool value) {
    state = state.copyWith(hasParking: value);
    _persist();
  }

  void updatePetFriendly(bool value) {
    state = state.copyWith(isPetFriendly: value);
    _persist();
  }

  void reset() {
    state = const SearchFilters();
    _persist();
  }

  void clearFilters() => reset();
}

/// Provider for the search filters state.
final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);
