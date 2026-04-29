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
