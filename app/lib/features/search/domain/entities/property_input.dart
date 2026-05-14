import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

/// Input shape for creating or updating a property. Fields mirror the API
/// payload (not the display entity), so booleans are booleans and price is
/// a numeric double — the data layer converts to the `"2500.00"` string the
/// backend expects.
///
/// All fields are nullable so the same class can be used for PATCH (partial
/// update, null = "don't change"). On create, `landlordId`, `title`,
/// `description`, `price`, and `address` must be non-null — enforced by the
/// notifier / repository.
@immutable
class PropertyInput {
  const PropertyInput({
    this.landlordId,
    this.title,
    this.description,
    this.price,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.type,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpots,
    this.area,
    this.isFurnished,
    this.petsAllowed,
    this.latitude,
    this.longitude,
    this.nearSubway,
    this.isFeatured,
    this.status,
    this.condoFee,
    this.propertyTax,
    this.images,
    this.photos,
    this.photosToRemove,
    this.extendedType,
    this.hasWifi,
    this.hasPool,
  });

  final String? landlordId;
  final String? title;
  final String? description;
  final double? price;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;

  /// API enum: `APARTMENT`, `HOUSE`, `STUDIO`, `CONDO_HOUSE`.
  final String? type;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpots;
  final double? area;
  final bool? isFurnished;
  final bool? petsAllowed;
  final double? latitude;
  final double? longitude;
  final bool? nearSubway;
  final bool? isFeatured;

  /// API enum: `AVAILABLE`, `NEGOTIATING`, `RENTED`.
  final String? status;
  final double? condoFee;
  final double? propertyTax;

  /// Extended property types marcados na UI mas ainda não aceitos pelo
  /// backend no enum `PropertyType`. Guardamos aqui pra manter o state do
  /// form coeso enquanto o backend não expande. Quando expandir, basta
  /// mapear esses valores em `type` e remover este campo.
  /// Ver BACKEND_HANDOFF.md §9.
  final String? extendedType;

  /// Amenities extras da UI de busca sem contraparte no schema de
  /// Property hoje (`hasWifi`, `hasPool`). Mantidos no state pra o form
  /// parecer consistente com a busca; não vão pro backend.
  /// Ver BACKEND_HANDOFF.md §9.
  final bool? hasWifi;
  final bool? hasPool;
  /// URLs de imagens já hospedadas (ex: vindo de um editor que mantém
  /// imagens antigas). Serializado como campo `images` no JSON.
  final List<PropertyImageInput>? images;

  /// Arquivos locais recém-selecionados pelo usuário. Quando não-nulo, o
  /// datasource monta `multipart/form-data` com o campo `photos` (convenção
  /// do backend: `POST /properties` aceita até 20 JPEGs/PNGs de 10MB cada,
  /// e a primeira foto do array é automaticamente marcada como capa).
  ///
  /// O `cover` é determinado pela ordem — quem for `photos[0]` vira capa.
  /// A UI reordena antes de submeter.
  final List<XFile>? photos;

  /// URLs de imagens **já hospedadas** que devem ser removidas do imóvel
  /// neste update. O datasource serializa como campo `photosToRemove` no
  /// multipart. Backend atual pode ignorar — ver
  /// `BACKEND_LANDLORD_GAPS.md` para o contrato pendente.
  final List<String>? photosToRemove;
}

@immutable
class PropertyImageInput {
  const PropertyImageInput({
    required this.url,
    this.isCover = false,
    this.caption,
  });

  final String url;
  final bool isCover;
  final String? caption;

  Map<String, dynamic> toJson() => {
        'url': url,
        'isCover': isCover,
        if (caption != null) 'caption': caption,
      };
}
