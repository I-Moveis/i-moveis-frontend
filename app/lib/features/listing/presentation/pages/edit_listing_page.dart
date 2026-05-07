import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/domain/entities/property_input.dart';
import '../providers/edit_listing_notifier.dart';
import '../providers/my_properties_notifier.dart';
import '../widgets/listing_form_fields.dart';
import '../widgets/listing_image_picker.dart';

class EditListingPage extends ConsumerStatefulWidget {
  const EditListingPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  // Controladores — paridade completa com CreateListingPage pra que o
  // landlord possa editar qualquer campo que a busca filtra.
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

  bool _initialized = false;
  String? _status;

  /// Enum real do backend (APARTMENT/HOUSE/STUDIO/CONDO_HOUSE).
  String? _selectedType;

  /// Tipo estendido UI-only (Kitnet/Cobertura/Terreno/Comercial).
  /// Ver BACKEND_HANDOFF.md §9.
  String? _extendedType;

  bool _isFurnished = false;
  bool _petsAllowed = false;
  bool _nearSubway = false;
  bool _isFeatured = false;
  // UI-only — ver BACKEND_HANDOFF.md §9.
  bool _hasWifi = false;
  bool _hasPool = false;

  // Fotos — lista atual (URLs já no backend) + novas (XFile).
  List<String> _existingPhotos = const [];
  final List<String> _removedExistingPhotos = [];
  List<XFile> _newPhotos = [];
  int _newCoverIndex = 0;

  @override
  void dispose() {
    for (final c in [
      _title, _description, _price, _address,
      _city, _state, _zipCode,
      _bedrooms, _bathrooms, _parking, _area,
      _condoFee, _propertyTax,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Hidrata o form com o valor atual do imóvel. A API devolve `type`
  /// como enum (`APARTMENT`, `HOUSE`, ...) mas a entity `Property` guarda
  /// o label PT-BR — o form precisa do enum, então fazemos o reverso
  /// aqui pra manter o ChoiceRow selecionando corretamente na primeira
  /// render.
  void _hydrate(Property property) {
    if (_initialized) return;
    _initialized = true;
    _title.text = property.title;
    _description.text = property.description;
    _price.text =
        property.priceValue > 0 ? property.priceValue.toStringAsFixed(2) : '';
    _address.text = property.address;
    _bedrooms.text = property.bedrooms > 0 ? property.bedrooms.toString() : '';
    _bathrooms.text =
        property.bathrooms > 0 ? property.bathrooms.toString() : '';
    _parking.text =
        property.parkingSpots > 0 ? property.parkingSpots.toString() : '';
    _area.text = property.area > 0 ? property.area.toStringAsFixed(0) : '';
    _condoFee.text =
        property.condoFee > 0 ? property.condoFee.toStringAsFixed(2) : '';
    _propertyTax.text =
        property.taxes > 0 ? property.taxes.toStringAsFixed(2) : '';
    _status = property.status ?? 'AVAILABLE';
    _selectedType = _labelToApiType(property.type);
    _isFurnished = property.amenities.contains('Mobiliado');
    _petsAllowed = property.amenities.contains('Aceita pets');
    _nearSubway = property.amenities.contains('Próximo ao metrô');
    _isFeatured = property.badges.contains('Destaque');
    _existingPhotos = List.of(property.imageUrls);
  }

  /// Atualiza o tipo selecionado (real ou estendido). Mesma regra do
  /// CreateListingPage — selecionar estendido força o enum real pro
  /// default APARTMENT pra não quebrar o PUT.
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

  String? _currentTypeKey() => _extendedType ?? _selectedType;

  void _removeExistingPhoto(String url) {
    setState(() {
      _existingPhotos.remove(url);
      _removedExistingPhotos.add(url);
    });
  }

  Future<void> _onSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final titleText = _title.text.trim();
    final addressText = _address.text.trim();
    final price = double.tryParse(
        _price.text.replaceAll(',', '.').replaceAll(r'R$', '').trim());

    if (titleText.isEmpty || addressText.isEmpty || price == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, preencha Título, Endereço e Preço corretamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(editListingNotifierProvider.notifier).submit(
            widget.propertyId,
            PropertyInput(
              title: titleText,
              description: _description.text.trim(),
              price: price,
              address: addressText,
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
              status: _status,
              photos: _newPhotosWithCoverFirst(),
              photosToRemove: _removedExistingPhotos.isEmpty
                  ? null
                  : List.of(_removedExistingPhotos),
              extendedType: _extendedType,
              hasWifi: _hasWifi,
              hasPool: _hasPool,
            ),
          );

      ref.invalidate(myPropertiesNotifierProvider);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Imóvel atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );

      if (mounted) router.pop();
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  /// Reordena novas fotos para que o `_newCoverIndex` vá para índice 0
  /// (convenção do backend — `photos[0]` vira capa automaticamente).
  /// Retorna null quando não há novas fotos.
  List<XFile>? _newPhotosWithCoverFirst() {
    if (_newPhotos.isEmpty) return null;
    if (_newCoverIndex <= 0 || _newCoverIndex >= _newPhotos.length) {
      return List.of(_newPhotos);
    }
    final ordered = List<XFile>.of(_newPhotos);
    final cover = ordered.removeAt(_newCoverIndex);
    ordered.insert(0, cover);
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);
    final submitting = ref.watch(editListingNotifierProvider).submitting;

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Editar imóvel'),
          Expanded(
            child: propertiesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar dados.',
                    style: AppTypography.bodyMedium.copyWith(
                        color: BrutalistPalette.title(isDark)),
                  ),
                ),
              ),
              data: (properties) {
                final property = properties.firstWhere(
                  (p) => p.id == widget.propertyId,
                  orElse: () => properties.first,
                );
                _hydrate(property);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      const ListingSectionLabel('Tipo'),
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

                      const ListingSectionLabel('Fotos atuais'),
                      _ExistingPhotosGallery(
                        urls: _existingPhotos,
                        onRemove: _removeExistingPhoto,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const ListingSectionLabel('Adicionar novas fotos'),
                      ListingImagePicker(
                        onImagesChanged: (imgs) =>
                            setState(() => _newPhotos = imgs),
                        onCoverChanged: (idx) =>
                            setState(() => _newCoverIndex = idx),
                      ),
                      if (_newPhotos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'A foto marcada como CAPA substituirá a capa atual.',
                            style: AppTypography.bodySmall.copyWith(
                                color: BrutalistPalette.muted(isDark)),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),

                      const ListingSectionLabel('Título'),
                      ListingTextInput(controller: _title, hint: 'Título'),
                      const SizedBox(height: AppSpacing.md),
                      const ListingSectionLabel('Descrição'),
                      ListingTextInput(
                        controller: _description,
                        hint: 'Descrição',
                        maxLines: 4,
                        height: 96,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const ListingSectionLabel(r'Preço mensal (R$)'),
                      ListingTextInput(
                        controller: _price,
                        hint: '2500.00',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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
                            child: ListingTextInput(
                                controller: _state, hint: 'UF')),
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
                      const SizedBox(height: AppSpacing.xl),

                      const ListingSectionLabel('Status'),
                      ListingChoiceRow<String>(
                        options: const [
                          'AVAILABLE',
                          'NEGOTIATING',
                          'RENTED'
                        ],
                        selected: _status,
                        onSelect: (v) => setState(() => _status = v),
                        labelOf: _statusLabel,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      BrutalistGradientButton(
                        label: submitting ? 'SALVANDO...' : 'SALVAR',
                        icon: Icons.check_rounded,
                        onTap: submitting ? null : _onSave,
                      ),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  /// Converte o label PT-BR que a entity `Property` guarda de volta no
  /// enum da API, pra que o `ListingTypeChipsRow` selecione o chip certo
  /// quando hidrata do backend.
  static String? _labelToApiType(String ptLabel) {
    switch (ptLabel) {
      case 'Apartamento':
        return 'APARTMENT';
      case 'Casa':
        return 'HOUSE';
      case 'Studio':
        return 'STUDIO';
      case 'Casa em condomínio':
      case 'Condomínio':
        return 'CONDO_HOUSE';
      default:
        return null;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'AVAILABLE':
        return 'Disponível';
      case 'NEGOTIATING':
        return 'Em negociação';
      case 'RENTED':
        return 'Alugado';
      default:
        return s;
    }
  }
}

/// Galeria horizontal das fotos já hospedadas, com botão X pra marcar
/// remoção. Remoção é local até o usuário clicar em SALVAR — aí vai no
/// multipart como `photosToRemove`.
class _ExistingPhotosGallery extends StatelessWidget {
  const _ExistingPhotosGallery({
    required this.urls,
    required this.onRemove,
    required this.isDark,
  });

  final List<String> urls;
  final void Function(String url) onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    if (urls.isEmpty) {
      return Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'Este imóvel ainda não tem fotos.',
            style: AppTypography.bodySmall.copyWith(color: mutedColor),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) {
          final url = urls[i];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(color: borderColor),
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () => onRemove(url),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Icon(Icons.close,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
