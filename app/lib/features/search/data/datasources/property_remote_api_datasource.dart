import 'dart:math' as math;

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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
      // Se location veio como "Cidade, UF" (deep link / manual),
      // envia apenas o nome da cidade para o parametro city.
      // O state ja vai separado no parametro state abaixo.
      String cityParam = filters.location;
      if (filters.location.contains(',') && filters.state.isNotEmpty) {
        cityParam = filters.location.split(',').first.trim();
      }
      params['city'] = cityParam;
    }
    if (filters.state.isNotEmpty) {
      params['state'] = filters.state;
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
    if (filters.bathrooms.isNotEmpty) {
      params['minBathrooms'] = filters.bathrooms.reduce(math.min);
    }

    final area = filters.areaRange;
    if (area != null) {
      if (area.start > 0) params['minArea'] = area.start;
      if (area.end > 0) params['maxArea'] = area.end;
    }

    if (filters.propertyTypes.length == 1) {
      final apiType = _uiTypeToApi(filters.propertyTypes.first);
      if (apiType != null) params['type'] = apiType;
    }
    // length >= 2: intentionally skip param, handled client-side below.

    if (filters.hasParking) params['minParkingSpots'] = 1;
    if (filters.isPetFriendly) params['petsAllowed'] = true;
    if (filters.isFurnished) params['isFurnished'] = true;
    if (filters.nearSubway) params['nearSubway'] = true;
    if (filters.isFeatured) params['isFeatured'] = true;

    if (filters.orderBy != null && filters.orderBy!.isNotEmpty) {
      params['orderBy'] = filters.orderBy;
    }

    if (filters.latitude != null &&
        filters.longitude != null &&
        filters.radiusKm != null) {
      params['lat'] = filters.latitude;
      params['lng'] = filters.longitude;
      params['radius'] = filters.radiusKm;
    }

    if (filters.landlordId != null && filters.landlordId!.isNotEmpty) {
      params['landlordId'] = filters.landlordId;
    }
    if (filters.tenantId != null && filters.tenantId!.isNotEmpty) {
      params['tenantId'] = filters.tenantId;
    }

    // NOTE (api-gap): transactionTypes, hasWifi, hasPool have no API equivalent.

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
    final photos = input.photos;
    final hasPhotos = photos != null && photos.isNotEmpty;

    // Dois caminhos no mesmo endpoint:
    //   sem photos → application/json (caminho legado)
    //   com photos → multipart/form-data, campo "photos" (convenção do
    //                backend; primeira foto vira capa automaticamente)
    if (!hasPhotos) {
      final response = await _dio.post<Map<String, dynamic>>(
        '/properties',
        data: propertyToCreateJson(input),
      );
      return propertyFromApiJson(response.data ?? const {});
    }

    final form = await _buildCreateFormData(input, photos);
    final response = await _dio.post<Map<String, dynamic>>(
      '/properties',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return propertyFromApiJson(response.data ?? const {});
  }

  /// Monta o FormData pro POST multipart. Campos escalares vão como string
  /// (convenção HTTP — multipart não carrega número/bool), arquivos vão no
  /// campo `photos`. Mantém a mesma lista de chaves do JSON (landlordId,
  /// title, etc.) — o backend reusa o validador.
  Future<FormData> _buildCreateFormData(
    PropertyInput input,
    List<XFile> photos,
  ) async {
    // `images` (URLs antigas) não faz sentido num POST multipart com fotos
    // novas — o backend gera as URLs a partir dos arquivos.
    final jsonBody = propertyToCreateJson(input)..remove('images');

    final fields = <MapEntry<String, String>>[];
    jsonBody.forEach((key, value) {
      if (value == null) return;
      fields.add(MapEntry(key, value.toString()));
    });

    final files = <MapEntry<String, MultipartFile>>[];
    for (final photo in photos) {
      final bytes = await photo.readAsBytes();
      final filename = photo.name.isNotEmpty
          ? photo.name
          : 'photo-${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Deduz o mime pela extensão do arquivo. Backend só aceita JPEG/PNG;
      // qualquer outra coisa cai no jpeg default e o backend rejeita com
      // mensagem clara de validação em vez de dar 500.
      final dot = filename.lastIndexOf('.');
      final ext = dot >= 0 ? filename.substring(dot + 1).toLowerCase() : '';
      final mime = switch (ext) {
        'png' => MediaType('image', 'png'),
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        _ => MediaType('image', 'jpeg'),
      };
      files.add(MapEntry(
        'photos',
        MultipartFile.fromBytes(bytes, filename: filename, contentType: mime),
      ));
    }

    return FormData()
      ..fields.addAll(fields)
      ..files.addAll(files);
  }

  @override
  Future<Property> update(String id, PropertyInput input) async {
    final photos = input.photos;
    final photosToRemove = input.photosToRemove;
    final hasNewPhotos = photos != null && photos.isNotEmpty;
    final hasRemoval =
        photosToRemove != null && photosToRemove.isNotEmpty;

    if (!hasNewPhotos && !hasRemoval) {
      final response = await _dio.put<Map<String, dynamic>>(
        '/properties/$id',
        data: propertyToPatchJson(input),
      );
      return propertyFromApiJson(response.data ?? const {});
    }

    final form = await _buildUpdateFormData(input, photos, photosToRemove);
    final response = await _dio.put<Map<String, dynamic>>(
      '/properties/$id',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return propertyFromApiJson(response.data ?? const {});
  }

  /// Monta FormData pro PUT multipart. Segue a mesma convenção do POST:
  /// campos escalares como string, arquivos no campo `photos`. Remoção
  /// de imagens existentes vai via campo `photosToRemove[]` (lista de URLs
  /// ou IDs — o backend decide qual formato aceita; por enquanto mandamos
  /// a URL, já que é o que a UI tem em mãos). Se o backend ainda não
  /// expôs isso, o campo é ignorado; o frontend não quebra.
  Future<FormData> _buildUpdateFormData(
    PropertyInput input,
    List<XFile>? photos,
    List<String>? photosToRemove,
  ) async {
    final jsonBody = propertyToPatchJson(input)..remove('images');

    final fields = <MapEntry<String, String>>[];
    jsonBody.forEach((key, value) {
      if (value == null) return;
      fields.add(MapEntry(key, value.toString()));
    });

    if (photosToRemove != null) {
      for (final url in photosToRemove) {
        fields.add(MapEntry('photosToRemove', url));
      }
    }

    final files = <MapEntry<String, MultipartFile>>[];
    if (photos != null) {
      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        final filename = photo.name.isNotEmpty
            ? photo.name
            : 'photo-${DateTime.now().millisecondsSinceEpoch}.jpg';
        final dot = filename.lastIndexOf('.');
        final ext =
            dot >= 0 ? filename.substring(dot + 1).toLowerCase() : '';
        final mime = switch (ext) {
          'png' => MediaType('image', 'png'),
          'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
          _ => MediaType('image', 'jpeg'),
        };
        files.add(MapEntry(
          'photos',
          MultipartFile.fromBytes(
            bytes,
            filename: filename,
            contentType: mime,
          ),
        ));
      }
    }

    return FormData()
      ..fields.addAll(fields)
      ..files.addAll(files);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<void>('/properties/$id');
  }

  @override
  Future<Property> moderate({
    required String id,
    required String decision,
    String? reason,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }
    final response = await _dio.put<Map<String, dynamic>>(
      '/properties/$id/moderation',
      data: body,
    );
    return propertyFromApiJson(response.data ?? const {});
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
