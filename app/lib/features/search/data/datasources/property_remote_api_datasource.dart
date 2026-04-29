import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../domain/entities/property.dart';
import '../../domain/entities/property_input.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../models/property_api_model.dart';
import '../models/property_search_page.dart';
import 'property_datasources.dart';

/// Real backend implementation hitting `GET /api/properties/search`.
///
/// `Dio` is expected to already be configured with the API baseUrl and the
/// standard interceptor stack (auth/logging/error mapper), so transport
/// errors surface as `NetworkException` to the repository layer.
class PropertyRemoteApiDataSource implements PropertyRemoteDataSource {
  PropertyRemoteApiDataSource(this._dio);

  final Dio _dio;

  static const _pageLimit = 10;
  static const _priceCeiling = 50000.0;

  @override
  Future<PropertySearchPage> searchProperties(
    SearchFilters filters,
    {int page = 1}) async {
    final params = _buildQueryParams(filters, page);
    final response = await _dio.get<Map<String, dynamic>>(
      '/properties/search',
      queryParameters: params,
    );

    final body = response.data ?? const <String, dynamic>{};
    final rawData = body['data'];
    final rawMeta = body['meta'];

    var properties = <Property>[];
    if (rawData is List) {
      properties = rawData
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => propertyFromApiJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Client-side fallback: when the UI has multiple property types selected
    // we don't send `type` (API only accepts one) and filter here instead.
    properties = _clientSideTypeFilter(properties, filters.propertyTypes);

    final meta = rawMeta is Map<dynamic, dynamic>
        ? Map<String, dynamic>.from(rawMeta)
        : const <String, dynamic>{};

    return PropertySearchPage(
      properties: properties,
      total: (meta['total'] as num?)?.toInt() ?? properties.length,
      page: (meta['page'] as num?)?.toInt() ?? page,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> _buildQueryParams(SearchFilters filters, int page) {
    final params = <String, dynamic>{
      'page': page,
      'limit': _pageLimit,
    };

    if (filters.location.isNotEmpty) {
      params['city'] = filters.location;
    }

    if (filters.priceRange.start > 0) {
      params['minPrice'] = filters.priceRange.start;
    }
    if (filters.priceRange.end < _priceCeiling) {
      params['maxPrice'] = filters.priceRange.end;
    }

    if (filters.bedrooms.isNotEmpty) {
      params['minBedrooms'] = filters.bedrooms.reduce(math.min);
    }

    if (filters.propertyTypes.length == 1) {
      final apiType = _uiTypeToApi(filters.propertyTypes.first);
      if (apiType != null) params['type'] = apiType;
    }
    // length >= 2: intentionally skip param, handled client-side below.

    if (filters.hasParking) params['minParkingSpots'] = 1;
    if (filters.isPetFriendly) params['petsAllowed'] = true;

    // TODO(api-gap): transactionTypes, hasWifi, hasPool have no API equivalent.

    return params;
  }

  List<Property> _clientSideTypeFilter(
    List<Property> items,
    List<String> selectedTypes,
  ) {
    if (selectedTypes.length < 2) return items;
    final accepted = selectedTypes.map(_uiTypeToDisplay).toSet();
    return items.where((p) => accepted.contains(p.type)).toList();
  }

  @override
  Future<Property> create(PropertyInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/properties',
      data: propertyToCreateJson(input),
    );
    return propertyFromApiJson(response.data ?? const {});
  }

  @override
  Future<Property> update(String id, PropertyInput input) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/properties/$id',
      data: propertyToPatchJson(input),
    );
    return propertyFromApiJson(response.data ?? const {});
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<void>('/properties/$id');
  }
}

String? _uiTypeToApi(String uiLabel) {
  switch (uiLabel) {
    case 'Apartamento':
      return 'APARTMENT';
    case 'Casa':
      return 'HOUSE';
    case 'Studio':
      return 'STUDIO';
    case 'Casa em condomínio':
      return 'CONDO_HOUSE';
  }
  return null;
}

String _uiTypeToDisplay(String uiLabel) => uiLabel;
