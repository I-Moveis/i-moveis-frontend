import 'dart:convert';

import 'package:app/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model representing search filters with multi-selection support.
@immutable
class SearchFilters {
  const SearchFilters({
    this.location = '',
    this.state = '',
    this.bedrooms = const [], // Empty means "Any"
    this.bathrooms = const [],
    this.priceRange = const RangeValues(0, 50000),
    this.areaRange,
    this.transactionTypes = const [],
    this.propertyTypes = const [],
    this.hasWifi = false,
    this.hasPool = false,
    this.hasParking = false,
    this.isPetFriendly = false,
    this.isFurnished = false,
    this.nearSubway = false,
    this.isFeatured = false,
    this.orderBy,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.landlordId,
    this.tenantId,
  });

  /// Constrói [SearchFilters] a partir de query parameters de um deep link.
  /// Exemplo vindo do bot WhatsApp:
  ///   /search?state=RJ&city=Rio+de+Janeiro&maxPrice=5000
  ///
  /// `city` e `state` são concatenados em `location` (ex: "Rio de Janeiro, RJ").
  /// Parâmetros não reconhecidos são ignorados.
  factory SearchFilters.fromQueryParams(Map<String, String> params) {
    final city = params['city']?.trim() ?? '';
    final stateParam = params['state']?.trim().toUpperCase() ?? '';
    final location = [city, stateParam]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return SearchFilters(
      location: location,
      state: stateParam,
      bedrooms: params['bedrooms']
              ?.split(',')
              .map((s) => int.tryParse(s.trim()))
              .whereType<int>()
              .toList() ??
          const [],
      priceRange: RangeValues(
        double.tryParse(params['minPrice'] ?? '') ?? 0.0,
        double.tryParse(params['maxPrice'] ?? '') ?? 50000.0,
      ),
      transactionTypes:
          params['transactionTypes']?.split(',').toList() ?? const [],
      propertyTypes:
          params['propertyTypes']?.split(',').toList() ?? const [],
      hasWifi: params['hasWifi'] == 'true',
      hasPool: params['hasPool'] == 'true',
      hasParking: params['hasParking'] == 'true',
      isPetFriendly: params['isPetFriendly'] == 'true',
    );
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    try {
      final areaStart = (json['minArea'] as num?)?.toDouble();
      final areaEnd = (json['maxArea'] as num?)?.toDouble();
      return SearchFilters(
        location: json['location'] as String? ?? '',
        state: json['state'] as String? ?? '',
        bedrooms: (json['bedrooms'] as List<dynamic>?)?.cast<int>() ?? const [],
        bathrooms:
            (json['bathrooms'] as List<dynamic>?)?.cast<int>() ?? const [],
        priceRange: RangeValues(
          (json['minPrice'] as num?)?.toDouble() ?? 0.0,
          (json['maxPrice'] as num?)?.toDouble() ?? 50000.0,
        ),
        areaRange: (areaStart != null || areaEnd != null)
            ? RangeValues(areaStart ?? 0, areaEnd ?? 1000)
            : null,
        transactionTypes: (json['transactionTypes'] as List<dynamic>?)?.cast<String>() ?? const [],
        propertyTypes: (json['propertyTypes'] as List<dynamic>?)?.cast<String>() ?? const [],
        hasWifi: json['hasWifi'] as bool? ?? false,
        hasPool: json['hasPool'] as bool? ?? false,
        hasParking: json['hasParking'] as bool? ?? false,
        isPetFriendly: json['isPetFriendly'] as bool? ?? false,
        isFurnished: json['isFurnished'] as bool? ?? false,
        nearSubway: json['nearSubway'] as bool? ?? false,
        isFeatured: json['isFeatured'] as bool? ?? false,
        orderBy: json['orderBy'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        radiusKm: (json['radiusKm'] as num?)?.toDouble(),
      );
    } on Object {
      return const SearchFilters();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'state': state,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'minPrice': priceRange.start,
      'maxPrice': priceRange.end,
      if (areaRange != null) 'minArea': areaRange!.start,
      if (areaRange != null) 'maxArea': areaRange!.end,
      'transactionTypes': transactionTypes,
      'propertyTypes': propertyTypes,
      'hasWifi': hasWifi,
      'hasPool': hasPool,
      'hasParking': hasParking,
      'isPetFriendly': isPetFriendly,
      'isFurnished': isFurnished,
      'nearSubway': nearSubway,
      'isFeatured': isFeatured,
      if (orderBy != null) 'orderBy': orderBy,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusKm != null) 'radiusKm': radiusKm,
    };
  }

  final String location;

  /// UF (ex: `SP`). Query param `state` do backend exige 2 letras uppercase.
  final String state;

  final List<int> bedrooms;
  final List<int> bathrooms;
  final RangeValues priceRange;

  /// Faixa de área em m². `null` = sem filtro.
  final RangeValues? areaRange;

  final List<String> transactionTypes;
  final List<String> propertyTypes;
  final bool hasWifi;
  final bool hasPool;
  final bool hasParking;
  final bool isPetFriendly;

  /// Mapeados diretamente para `isFurnished`, `nearSubway`, `isFeatured`
  /// no backend. Quando `false`, param é omitido (default do backend).
  final bool isFurnished;
  final bool nearSubway;
  final bool isFeatured;

  /// Ordenação (`createdAt` | `views` | `priceAsc` | `priceDesc` |
  /// `isFeatured` | `nearest`). `null` = backend default (`isFeatured`).
  final String? orderBy;

  /// Busca por proximidade. Quando todos os 3 presentes, backend ordena
  /// por distância (haversine). Setados pelo botão "perto de mim".
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  /// Filtra o resultado de `/properties/search` para imóveis de um dono
  /// específico (usado em "Meus imóveis"). Não é persistido no
  /// shared_preferences — é um filtro de sessão, não de UX.
  final String? landlordId;

  /// Filtra imóveis onde o inquilino tem visita agendada.
  final String? tenantId;

  SearchFilters copyWith({
    String? location,
    String? state,
    List<int>? bedrooms,
    List<int>? bathrooms,
    RangeValues? priceRange,
    RangeValues? areaRange,
    List<String>? transactionTypes,
    List<String>? propertyTypes,
    bool? hasWifi,
    bool? hasPool,
    bool? hasParking,
    bool? isPetFriendly,
    bool? isFurnished,
    bool? nearSubway,
    bool? isFeatured,
    String? orderBy,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? landlordId,
    String? tenantId,
  }) {
    return SearchFilters(
      location: location ?? this.location,
      state: state ?? this.state,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      priceRange: priceRange ?? this.priceRange,
      areaRange: areaRange ?? this.areaRange,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
      hasParking: hasParking ?? this.hasParking,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      isFurnished: isFurnished ?? this.isFurnished,
      nearSubway: nearSubway ?? this.nearSubway,
      isFeatured: isFeatured ?? this.isFeatured,
      orderBy: orderBy ?? this.orderBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      landlordId: landlordId ?? this.landlordId,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  /// Remove os params de geolocalização (usado ao desligar "perto de mim").
  SearchFilters withoutGeo() {
    return SearchFilters(
      location: location,
      state: state,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      priceRange: priceRange,
      areaRange: areaRange,
      transactionTypes: transactionTypes,
      propertyTypes: propertyTypes,
      hasWifi: hasWifi,
      hasPool: hasPool,
      hasParking: hasParking,
      isPetFriendly: isPetFriendly,
      isFurnished: isFurnished,
      nearSubway: nearSubway,
      isFeatured: isFeatured,
      orderBy: orderBy == 'nearest' ? null : orderBy,
      landlordId: landlordId,
      tenantId: tenantId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          state == other.state &&
          bedrooms == other.bedrooms &&
          bathrooms == other.bathrooms &&
          priceRange == other.priceRange &&
          areaRange == other.areaRange &&
          transactionTypes == other.transactionTypes &&
          propertyTypes == other.propertyTypes &&
          hasWifi == other.hasWifi &&
          hasPool == other.hasPool &&
          hasParking == other.hasParking &&
          isPetFriendly == other.isPetFriendly &&
          isFurnished == other.isFurnished &&
          nearSubway == other.nearSubway &&
          isFeatured == other.isFeatured &&
          orderBy == other.orderBy &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          landlordId == other.landlordId &&
          tenantId == other.tenantId;

  @override
  int get hashCode => Object.hashAll([
        location,
        state,
        bedrooms,
        bathrooms,
        priceRange,
        areaRange,
        transactionTypes,
        propertyTypes,
        hasWifi,
        hasPool,
        hasParking,
        isPetFriendly,
        isFurnished,
        nearSubway,
        isFeatured,
        orderBy,
        latitude,
        longitude,
        radiusKm,
        landlordId,
        tenantId,
      ]);
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
      } on Object {
        // Silently fail and use default state
      }
    }
    return const SearchFilters();
  }

  void _persist() {
    try {
      ref
          .read(sharedPreferencesProvider)
          .setString(_kFiltersKey, json.encode(state.toJson()));
    } on Object {
      // Silently fail persistence
    }
  }

  void updateLocation(String location) {
    // Se usuario digitar "Cidade, UF", separamos location e state.
    if (location.contains(', ')) {
      final parts = location.split(', ');
      if (parts.length == 2 && parts.last.length == 2) {
        final possibleState = parts.last.toUpperCase();
        if (_isBrState(possibleState)) {
          state = state.copyWith(location: parts.first, state: possibleState);
          _persist();
          return;
        }
      }
    }
    state = state.copyWith(location: location);
    _persist();
  }

  static bool _isBrState(String s) {
    const states = {
      'AC','AL','AP','AM','BA','CE','DF','ES','GO',
      'MA','MT','MS','MG','PA','PB','PR','PE','PI',
      'RJ','RN','RS','RO','RR','SC','SP','SE','TO',
    };
    return states.contains(s);
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

  void updateFurnished(bool value) {
    state = state.copyWith(isFurnished: value);
    _persist();
  }

  void updateNearSubway(bool value) {
    state = state.copyWith(nearSubway: value);
    _persist();
  }

  void updateFeatured(bool value) {
    state = state.copyWith(isFeatured: value);
    _persist();
  }

  void updateState(String value) {
    state = state.copyWith(state: value.toUpperCase());
    _persist();
  }

  void toggleBathroom(int count) {
    final current = List<int>.from(state.bathrooms);
    if (current.contains(count)) {
      current.remove(count);
    } else {
      current.add(count);
    }
    state = state.copyWith(bathrooms: current);
    _persist();
  }

  void updateAreaRange(RangeValues? range) {
    // Nota: copyWith não consegue "apagar" (null coalesce), então para
    // limpar o filtro reconstruo o objeto preservando o resto.
    final s = state;
    state = SearchFilters(
      location: s.location,
      state: s.state,
      bedrooms: s.bedrooms,
      bathrooms: s.bathrooms,
      priceRange: s.priceRange,
      areaRange: range,
      transactionTypes: s.transactionTypes,
      propertyTypes: s.propertyTypes,
      hasWifi: s.hasWifi,
      hasPool: s.hasPool,
      hasParking: s.hasParking,
      isPetFriendly: s.isPetFriendly,
      isFurnished: s.isFurnished,
      nearSubway: s.nearSubway,
      isFeatured: s.isFeatured,
      orderBy: s.orderBy,
      latitude: s.latitude,
      longitude: s.longitude,
      radiusKm: s.radiusKm,
      landlordId: s.landlordId,
      tenantId: s.tenantId,
    );
    _persist();
  }

  /// `createdAt` | `views` | `priceAsc` | `priceDesc` | `isFeatured` | `nearest`.
  void updateOrderBy(String? orderBy) {
    state = state.copyWith(orderBy: orderBy);
    _persist();
  }

  /// Aciona busca por proximidade. O backend exige lat+lng+radius juntos.
  void setNearbySearch({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      orderBy: 'nearest',
    );
    _persist();
  }

  /// Desliga a busca por proximidade.
  void clearNearbySearch() {
    state = state.withoutGeo();
    _persist();
  }

  void reset() {
    state = const SearchFilters();
    _persist();
  }

  void clearFilters() => reset();

  /// Aplica um conjunto completo de filtros de uma vez — usado quando um
  /// deep link (ex: WhatsApp bot) manda a URL com parâmetros já prontos.
  void applyAll(SearchFilters filters) {
    state = filters;
    _persist();
  }
}

/// Provider for the search filters state.
final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);
