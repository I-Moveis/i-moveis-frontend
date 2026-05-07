import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// Reusable styled text field matching the schedule page's input style.
class ListingTextInput extends StatelessWidget {
  const ListingTextInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.height = 56,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Container(
      height: maxLines == 1 ? height : null,
      constraints: maxLines == 1 ? null : BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTypography.bodyLarge.copyWith(color: titleColor),
        cursorColor: accentColor,
        cursorWidth: 1.5,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyLarge
              .copyWith(color: BrutalistPalette.faint(isDark)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Section label (uppercase-ish, muted).
class ListingSectionLabel extends StatelessWidget {
  const ListingSectionLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        label,
        style: AppTypography.titleSmallBold.copyWith(
          color: titleColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Horizontal row of selectable chips for a small enum-like choice.
class ListingChoiceRow<T> extends StatelessWidget {
  const ListingChoiceRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.labelOf,
    super.key,
  });

  final List<T> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: selected == option
                    ? accentColor.withValues(alpha: 0.12)
                    : cardBg,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: selected == option
                      ? accentColor.withValues(alpha: 0.35)
                      : borderColor,
                ),
              ),
              child: Text(
                labelOf(option),
                style: AppTypography.titleSmall.copyWith(
                  color: selected == option ? accentColor : titleColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Linha scrollável com todos os tipos de imóvel — os 4 suportados pelo
/// backend hoje e mais 4 (Kitnet/Cobertura/Terreno/Comercial) que são
/// UI-only até o enum `PropertyType` expandir no backend (ver
/// BACKEND_HANDOFF.md §9). Tipos UI-only ganham um tooltip explicativo;
/// visualmente o chip parece igual pra não dar segundo padrão visual.
///
/// Compartilhado entre create e edit — sempre que a busca do usuário
/// ganhar mais opções, só adicionar aqui.
class ListingTypeChipsRow extends StatelessWidget {
  const ListingTypeChipsRow({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  /// Tipos aceitos pelo backend — seguros de mandar no POST/PUT.
  static const realTypes = <String>{
    'APARTMENT',
    'HOUSE',
    'STUDIO',
    'CONDO_HOUSE',
  };

  static const _all = <(String, String)>[
    ('APARTMENT', 'Apartamento'),
    ('HOUSE', 'Casa'),
    ('STUDIO', 'Studio'),
    ('CONDO_HOUSE', 'Condomínio'),
    ('KITNET', 'Kitnet'),
    ('PENTHOUSE', 'Cobertura'),
    ('LAND', 'Terreno'),
    ('COMMERCIAL', 'Comercial'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _all.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final entry = _all[i];
          final isReal = realTypes.contains(entry.$1);
          final chip = AppChip(
            label: entry.$2,
            isSelected: selected == entry.$1,
            onTap: () => onSelect(entry.$1),
          );
          if (isReal) return chip;
          return Tooltip(
            message: 'Tipo ainda não filtra na busca — backend em expansão',
            child: chip,
          );
        },
      ),
    );
  }
}

/// Toggle idêntico ao `ListingToggle` visualmente, mas com indicador
/// sutil de "ainda não filtra" pro landlord saber que a marcação é
/// cosmética enquanto o backend não suporta o campo. Usado para
/// Wi-Fi, Piscina e outros campos da busca sem contraparte no schema.
class ListingUiOnlyToggle extends StatelessWidget {
  const ListingUiOnlyToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        ListingToggle(label: label, value: value, onChanged: onChanged),
        Positioned(
          right: AppSpacing.lg + 40,
          top: 0,
          bottom: 0,
          child: Center(
            child: Tooltip(
              message: 'Ainda não filtra na busca — backend em expansão',
              child: Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: BrutalistPalette.muted(isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Toggle row: "Mobiliado? [ ]" with tap target.
class ListingToggle extends StatelessWidget {
  const ListingToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: value ? accentColor.withValues(alpha: 0.35) : borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box_rounded : Icons.check_box_outline_blank,
              color: value ? accentColor : mutedColor,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppTypography.titleSmall.copyWith(color: titleColor)),
            ),
          ],
        ),
      ),
    );
  }
}
