import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../property/presentation/providers/property_detail_provider.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/domain/entities/property_input.dart';
import '../providers/edit_listing_notifier.dart';
import '../widgets/listing_form_fields.dart';

class EditListingPage extends ConsumerStatefulWidget {
  const EditListingPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _address = TextEditingController();
  final _bedrooms = TextEditingController();
  final _bathrooms = TextEditingController();
  final _parking = TextEditingController();
  final _area = TextEditingController();

  bool _initialized = false;
  String? _status;

  @override
  void dispose() {
    for (final c in [
      _title, _description, _price, _address,
      _bedrooms, _bathrooms, _parking, _area,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(Property property) {
    if (_initialized) return;
    _initialized = true;
    _title.text = property.title;
    _description.text = property.description;
    _price.text = property.priceValue > 0
        ? property.priceValue.toStringAsFixed(2)
        : '';
    _address.text = property.address;
    _bedrooms.text = property.bedrooms.toString();
    _bathrooms.text = property.bathrooms.toString();
    _parking.text = property.parkingSpots.toString();
    _area.text = property.area.toStringAsFixed(0);
    // Property entity doesn't carry the API status enum — default to AVAILABLE
    // when the user opens the editor. A future entity refactor can expose it.
    _status = 'AVAILABLE';
  }

  Future<void> _onSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        price == null ||
        price <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }

    try {
      await ref.read(editListingNotifierProvider.notifier).submit(
            widget.propertyId,
            PropertyInput(
              title: _title.text.trim(),
              description: _description.text.trim(),
              price: price,
              address: _address.text.trim(),
              bedrooms: int.tryParse(_bedrooms.text),
              bathrooms: int.tryParse(_bathrooms.text),
              parkingSpots: int.tryParse(_parking.text),
              area: double.tryParse(_area.text.replaceAll(',', '.')),
              status: _status,
            ),
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel atualizado.')),
      );
      router.pop();
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(propertyDetailProvider(widget.propertyId));
    final submitting = ref.watch(editListingNotifierProvider).submitting;

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Editar imóvel'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar imóvel.',
                    style: AppTypography.bodyMedium.copyWith(
                        color: BrutalistPalette.title(isDark)),
                  ),
                ),
              ),
              data: (property) {
                _hydrate(property);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
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
                      const ListingSectionLabel('Status'),
                      ListingChoiceRow<String>(
                        options: const [
                          'AVAILABLE',
                          'IN_NEGOTIATION',
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

  static String _statusLabel(String s) {
    switch (s) {
      case 'AVAILABLE':
        return 'Disponível';
      case 'IN_NEGOTIATION':
        return 'Em negociação';
      case 'RENTED':
        return 'Alugado';
      default:
        return s;
    }
  }
}
