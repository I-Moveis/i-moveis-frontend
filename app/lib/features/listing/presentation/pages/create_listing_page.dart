import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../providers/create_listing_notifier.dart';
import '../widgets/listing_form_fields.dart';
import '../widgets/listing_image_picker.dart';

/// Single-page listing form that dispatches POST /api/properties.
///
/// Required fields (title, description, price, address) are enforced
/// client-side — anything else is nullable and only sent to the backend
/// when the user filled it.
class CreateListingPage extends ConsumerStatefulWidget {
  const CreateListingPage({super.key});

  @override
  ConsumerState<CreateListingPage> createState() =>
      _CreateListingPageState();
}

class _CreateListingPageState extends ConsumerState<CreateListingPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zipCode = TextEditingController();
  final _bedrooms = TextEditingController();
  final _bathrooms = TextEditingController();
  final _parking = TextEditingController();
  final _area = TextEditingController();
  final _condoFee = TextEditingController();
  final _propertyTax = TextEditingController();

  /// Enum real aceito pelo backend — APARTMENT/HOUSE/STUDIO/CONDO_HOUSE.
  /// Valor null = usuário selecionou um [_extendedType] sem contraparte
  /// no backend, e o POST manda o default APARTMENT.
  String? _selectedType = 'APARTMENT';

  /// Tipo estendido marcado na UI (Kitnet, Cobertura, Terreno, Comercial).
  /// Sem contraparte no schema do backend hoje — ver BACKEND_HANDOFF.md §9.
  /// Se não-nulo, mostra visualmente como selecionado mas o POST manda
  /// `type: 'APARTMENT'` (default) pra não quebrar a validação do enum.
  String? _extendedType;

  bool _isFurnished = false;
  bool _petsAllowed = false;
  bool _nearSubway = false;
  bool _isFeatured = false;
  // Amenities extras da UI sem backend — ver BACKEND_HANDOFF.md §9.
  bool _hasWifi = false;
  bool _hasPool = false;

  List<XFile> _selectedImages = [];
  int _coverIndex = 0;

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _price,
      _address,
      _city,
      _state,
      _zipCode,
      _bedrooms,
      _bathrooms,
      _parking,
      _area,
      _condoFee,
      _propertyTax,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onPublish() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        price == null ||
        price <= 0) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text(
                'Preencha título, descrição, endereço e um preço válido.')),
      );
      return;
    }

    try {
      await ref.read(createListingNotifierProvider.notifier).submit(
            title: _title.text.trim(),
            description: _description.text.trim(),
            price: price,
            address: _address.text.trim(),
            city: _emptyToNull(_city.text),
            state: _emptyToNull(_state.text),
            zipCode: _emptyToNull(_zipCode.text),
            type: _selectedType,
            bedrooms: int.tryParse(_bedrooms.text),
            bathrooms: int.tryParse(_bathrooms.text),
            parkingSpots: int.tryParse(_parking.text),
            area: double.tryParse(_area.text.replaceAll(',', '.')),
            isFurnished: _isFurnished,
            petsAllowed: _petsAllowed,
            nearSubway: _nearSubway,
            isFeatured: _isFeatured,
            condoFee: double.tryParse(_condoFee.text.replaceAll(',', '.')),
            propertyTax:
                double.tryParse(_propertyTax.text.replaceAll(',', '.')),
            photos: _photosWithCoverFirst(),
            extendedType: _extendedType,
            hasWifi: _hasWifi,
            hasPool: _hasPool,
          );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel publicado com sucesso!')),
      );
      navigator.pop();
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  /// Reordena a lista de fotos pra que a marcada como capa vire o índice 0.
  /// O backend convenciona que `photos[0]` é a capa automaticamente — em vez
  /// de mandar flag `isCover` por foto, a gente encaixa na ordem esperada.
  /// Retorna `null` se não houver fotos, para o datasource seguir a via JSON.
  List<XFile>? _photosWithCoverFirst() {
    if (_selectedImages.isEmpty) return null;
    if (_coverIndex <= 0 || _coverIndex >= _selectedImages.length) {
      return List.of(_selectedImages);
    }
    final ordered = List<XFile>.of(_selectedImages);
    final cover = ordered.removeAt(_coverIndex);
    ordered.insert(0, cover);
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(createListingNotifierProvider).submitting;

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Anunciar imóvel'),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListingSectionLabel('Tipo'),
                  // Exibe todos os tipos em uma linha só — inclui os 4
                  // suportados pelo backend e os extras (Kitnet, Cobertura,
                  // Terreno, Comercial) que são UI-only por ora. A fonte de
                  // verdade visual é `_currentTypeKey()`: ele devolve o que
                  // está selecionado de fato entre os 8.
                  ListingTypeChipsRow(
                    selected: _currentTypeKey(),
                    onSelect: _onSelectType,
                  ),
                  if (_extendedType != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Esse tipo ainda não filtra na busca — backend em expansão.',
                        style: AppTypography.bodySmall.copyWith(
                          color: BrutalistPalette.muted(isDark),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const ListingSectionLabel('Fotos'),
                  ListingImagePicker(
                    onImagesChanged: (imgs) => setState(() => _selectedImages = imgs),
                    onCoverChanged: (idx) => setState(() => _coverIndex = idx),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const ListingSectionLabel('Título'),
                  ListingTextInput(
                      controller: _title,
                      hint: 'Ex: Apto na Vila Mariana'),
                  const SizedBox(height: AppSpacing.md),
                  const ListingSectionLabel('Descrição'),
                  ListingTextInput(
                    controller: _description,
                    hint: 'Conte sobre o imóvel...',
                    maxLines: 4,
                    height: 96,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const ListingSectionLabel(r'Preço mensal (R$)'),
                  ListingTextInput(
                    controller: _price,
                    hint: '2500.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const ListingSectionLabel('Endereço'),
                  ListingTextInput(
                      controller: _address, hint: 'Rua, número, bairro'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    Expanded(
                        flex: 3,
                        child: ListingTextInput(
                            controller: _city, hint: 'Cidade')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child:
                            ListingTextInput(controller: _state, hint: 'UF')),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  ListingTextInput(controller: _zipCode, hint: 'CEP'),
                  const SizedBox(height: AppSpacing.xl),
                  const ListingSectionLabel('Características'),
                  Row(children: [
                    Expanded(
                        child: ListingTextInput(
                            controller: _bedrooms,
                            hint: 'Quartos',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: ListingTextInput(
                            controller: _bathrooms,
                            hint: 'Banheiros',
                            keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    Expanded(
                        child: ListingTextInput(
                            controller: _parking,
                            hint: 'Vagas',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: ListingTextInput(
                            controller: _area,
                            hint: 'Área (m²)',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true))),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  const ListingSectionLabel('Taxas mensais (opcional)'),
                  Row(children: [
                    Expanded(
                        child: ListingTextInput(
                            controller: _condoFee,
                            hint: 'Condomínio',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: ListingTextInput(
                            controller: _propertyTax,
                            hint: 'IPTU',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true))),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  const ListingSectionLabel('Comodidades'),
                  ListingToggle(
                    label: 'Mobiliado',
                    value: _isFurnished,
                    onChanged: (v) => setState(() => _isFurnished = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListingToggle(
                    label: 'Aceita pets',
                    value: _petsAllowed,
                    onChanged: (v) => setState(() => _petsAllowed = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListingToggle(
                    label: 'Próximo ao metrô',
                    value: _nearSubway,
                    onChanged: (v) => setState(() => _nearSubway = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Wi-Fi e Piscina ainda não estão no schema do backend.
                  // UI-only por ora — ver BACKEND_HANDOFF.md §9.
                  ListingUiOnlyToggle(
                    label: 'Wi-Fi incluso',
                    value: _hasWifi,
                    onChanged: (v) => setState(() => _hasWifi = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListingUiOnlyToggle(
                    label: 'Piscina',
                    value: _hasPool,
                    onChanged: (v) => setState(() => _hasPool = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const ListingSectionLabel('Destaque'),
                  ListingToggle(
                    label: 'Anúncio em destaque',
                    value: _isFeatured,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      'Imóveis em destaque aparecem no topo da busca.',
                      style: AppTypography.bodySmall.copyWith(
                        color: BrutalistPalette.muted(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  BrutalistGradientButton(
                    label: submitting ? 'PUBLICANDO...' : 'PUBLICAR',
                    icon: Icons.check_rounded,
                    onTap: submitting ? null : _onPublish,
                  ),
                  const SizedBox(height: AppSpacing.massive),
                ],
              ),
            ),
          ),
        ]);
      },
    );
  }

  /// Chave corrente da seleção de tipo pra pintar o chip certo — ou o
  /// enum real (`APARTMENT` etc.) ou o extended ('KITNET' etc.).
  String? _currentTypeKey() => _extendedType ?? _selectedType;

  /// Regras:
  /// - Selecionar um tipo **real** limpa `_extendedType` e seta `_selectedType`.
  /// - Selecionar um tipo **estendido** seta `_extendedType` e faz o
  ///   `_selectedType` cair pro default APARTMENT (pra o backend aceitar
  ///   o POST — ver BACKEND_HANDOFF.md §9).
  void _onSelectType(String key) {
    setState(() {
      if (ListingTypeChipsRow.realTypes.contains(key)) {
        _selectedType = key;
        _extendedType = null;
      } else {
        _extendedType = key;
        _selectedType = 'APARTMENT';
      }
    });
  }

}

