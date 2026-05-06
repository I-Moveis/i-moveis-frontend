import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../providers/create_listing_notifier.dart';
import '../widgets/listing_form_fields.dart';
import '../widgets/listing_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/search/domain/entities/property_input.dart';

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

  String? _selectedType = 'APARTMENT';
  bool _isFurnished = false;
  bool _petsAllowed = false;
  bool _nearSubway = false;
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
            condoFee: double.tryParse(_condoFee.text.replaceAll(',', '.')),
            propertyTax:
                double.tryParse(_propertyTax.text.replaceAll(',', '.')),
            images: _buildImageInputs(),
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

  List<PropertyImageInput> _buildImageInputs() {
    return _selectedImages.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      // In a real production app, you would upload the file to S3/Cloudinary first
      // and get the URL. For this integration, we'll send a placeholder or data URI
      // if the backend supports it, but here we'll use a descriptive placeholder
      // to demonstrate the 'isCover' logic works.
      return PropertyImageInput(
        url: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800', // Placeholder
        isCover: index == _coverIndex,
        caption: index == _coverIndex ? 'Capa' : 'Imagem ${index + 1}',
      );
    }).toList();
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
                  ListingChoiceRow<String>(
                    options: const [
                      'APARTMENT',
                      'HOUSE',
                      'STUDIO',
                      'CONDO_HOUSE'
                    ],
                    selected: _selectedType,
                    onSelect: (v) => setState(() => _selectedType = v),
                    labelOf: _typeLabel,
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
                  const ListingSectionLabel('Amenities'),
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

  static String _typeLabel(String apiType) {
    switch (apiType) {
      case 'APARTMENT':
        return 'Apartamento';
      case 'HOUSE':
        return 'Casa';
      case 'STUDIO':
        return 'Studio';
      case 'CONDO_HOUSE':
        return 'Condomínio';
      default:
        return apiType;
    }
  }
}
