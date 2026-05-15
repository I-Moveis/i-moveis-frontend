import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../property/presentation/providers/property_detail_provider.dart';

/// Tenant manda uma proposta para um imóvel via `POST /proposals`. Os
/// campos extras (prazo do contrato, data de entrada) ainda não têm
/// coluna própria no backend — entram concatenados no `message`.
class MakeProposalPage extends ConsumerStatefulWidget {
  const MakeProposalPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  ConsumerState<MakeProposalPage> createState() => _MakeProposalPageState();
}

class _MakeProposalPageState extends ConsumerState<MakeProposalPage> {
  static const _termOptions = [12, 24, 30, 36];

  final _priceController = TextEditingController();
  final _messageController = TextEditingController();
  int? _selectedTerm = 12;
  DateTime? _selectedDate;
  bool _submitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  double? _parsePrice() {
    final raw = _priceController.text
        .replaceAll(RegExp(r'[^0-9,]'), '')
        .replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _submit() async {
    final price = _parsePrice();
    if (price == null || price <= 0) {
      _toast('Informe um valor válido.');
      return;
    }
    if (_selectedTerm == null) {
      _toast('Selecione o prazo do contrato.');
      return;
    }
    if (_selectedDate == null) {
      _toast('Selecione a data de entrada.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final tenantId = await ref.read(currentUserIdProvider.future);
      if (tenantId == null || tenantId.isEmpty) {
        throw StateError('sem usuário logado');
      }

      final extras = <String>[
        'Prazo: $_selectedTerm meses',
        'Data de entrada: ${_formatDate(_selectedDate!)}',
      ];
      final message = _messageController.text.trim();
      final fullMessage =
          message.isEmpty ? extras.join(' • ') : '$message\n\n${extras.join(' • ')}';

      final dio = ref.read(dioProvider);
      await dio.post<Map<String, dynamic>>(
        '/proposals',
        data: {
          'propertyId': widget.propertyId,
          'tenantId': tenantId,
          'proposedPrice': price,
          'message': fullMessage,
        },
      );

      if (!mounted) return;
      _toast('Proposta enviada!');
      context.pop();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      _toast(code == 409
          ? 'Você já tem uma proposta ativa para este imóvel.'
          : 'Não foi possível enviar a proposta.');
    } on Object {
      _toast('Erro inesperado ao enviar a proposta.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync =
        ref.watch(propertyDetailProvider(widget.propertyId));

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
        ));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final propertyTitle = propertyAsync.maybeWhen(
          data: (p) => p.title,
          orElse: () => 'Imóvel',
        );
        final propertyPrice = propertyAsync.maybeWhen(
          data: (p) => p.price.isNotEmpty ? '${p.price}/mês' : '',
          orElse: () => '',
        );

        return Opacity(
          opacity: fade.value,
          child: Column(children: [
            const BrutalistAppBar(title: 'Proposta'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: BrutalistPalette.imagePlaceholderBg(isDark),
                            borderRadius: AppRadius.borderMd,
                          ),
                          child: Icon(Icons.home_rounded,
                              size: 24,
                              color: accentColor.withValues(alpha: 0.3)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(propertyTitle,
                                  style: AppTypography.titleLargeBold
                                      .copyWith(color: titleColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              if (propertyPrice.isNotEmpty)
                                Text(propertyPrice,
                                    style: AppTypography.bodySmallBold
                                        .copyWith(color: accentColor)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionLabel('Valor proposto', titleColor),
                    const SizedBox(height: AppSpacing.sm),
                    _PriceField(
                      controller: _priceController,
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionLabel('Prazo do contrato', titleColor),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final months in _termOptions)
                          _TermChip(
                            label: '$months meses',
                            selected: _selectedTerm == months,
                            accent: accentColor,
                            isDark: isDark,
                            onTap: () =>
                                setState(() => _selectedTerm = months),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionLabel('Data de entrada', titleColor),
                    const SizedBox(height: AppSpacing.sm),
                    _DateField(
                      value: _selectedDate,
                      onTap: _pickDate,
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionLabel('Mensagem (opcional)', titleColor),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        expands: true,
                        style: AppTypography.bodyLarge
                            .copyWith(color: titleColor),
                        cursorColor: accentColor,
                        cursorWidth: 1.5,
                        decoration: InputDecoration(
                          hintText: 'Escreva algo para o proprietário...',
                          hintStyle: AppTypography.bodyLarge
                              .copyWith(color: BrutalistPalette.faint(isDark)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    BrutalistGradientButton(
                      label:
                          _submitting ? 'ENVIANDO...' : 'ENVIAR PROPOSTA',
                      icon: Icons.send_rounded,
                      onTap: _submitting ? () {} : _submit,
                    ),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _sectionLabel(String text, Color color) => Text(
        text,
        style: AppTypography.titleSmallBold
            .copyWith(color: color.withValues(alpha: 0.5)),
      );
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.cardBg,
    required this.borderColor,
    required this.accentColor,
  });

  final TextEditingController controller;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color cardBg;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Icon(Icons.attach_money_rounded, size: 18, color: mutedColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            style: AppTypography.bodyLarge.copyWith(color: titleColor),
            cursorColor: accentColor,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: r'R$ 2.500,00',
              hintStyle: AppTypography.bodyLarge
                  .copyWith(color: BrutalistPalette.faint(isDark)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onTap,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.cardBg,
    required this.borderColor,
  });

  final DateTime? value;
  final VoidCallback onTap;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color cardBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final label = hasValue
        ? '${value!.day.toString().padLeft(2, '0')}/'
            '${value!.month.toString().padLeft(2, '0')}/'
            '${value!.year}'
        : 'Selecionar data';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, size: 18, color: mutedColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: hasValue
                    ? titleColor
                    : BrutalistPalette.faint(isDark),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ]),
      ),
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? accent : accent.withValues(alpha: 0.1);
    final fg = selected
        ? (isDark ? AppColors.black : AppColors.white)
        : accent;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: selected ? accent : accent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.titleSmallBold.copyWith(color: fg),
        ),
      ),
    );
  }
}
