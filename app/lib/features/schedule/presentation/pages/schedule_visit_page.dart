import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Schedule visit — cozy date/time selection.
class ScheduleVisitPage extends StatelessWidget {
  const ScheduleVisitPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: Column(children: [
          const BrutalistAppBar(title: 'Agendar visita'),
          Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Escolha uma data', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
            const SizedBox(height: AppSpacing.md),
            _buildDates(isDark, titleColor, mutedColor, accentColor, cardBg, borderColor),
            const SizedBox(height: AppSpacing.xxl),

            Text('Horário', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
            const SizedBox(height: AppSpacing.md),
            for (final s in [('09:00 – 12:00', 'Manhã'), ('13:00 – 17:00', 'Tarde'), ('18:00 – 20:00', 'Noite')]) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                child: Row(children: [Text(s.$1, style: AppTypography.titleSmall.copyWith(color: titleColor)), const Spacer(), Text(s.$2, style: AppTypography.bodySmall.copyWith(color: mutedColor))])),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xl),

            Text('Observações', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
            const SizedBox(height: AppSpacing.md),
            Container(height: 100, padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
              child: TextField(maxLines: null, expands: true, style: AppTypography.bodyLarge.copyWith(color: titleColor), cursorColor: accentColor, cursorWidth: 1.5,
                decoration: InputDecoration(hintText: 'Alguma observação? (opcional)', hintStyle: AppTypography.bodyLarge.copyWith(color: BrutalistPalette.faint(isDark)), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
            const SizedBox(height: AppSpacing.xxxl),
            BrutalistGradientButton(label: 'CONFIRMAR', icon: Icons.check_rounded, onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

  Widget _buildDates(bool isDark, Color titleColor, Color mutedColor, Color accentColor, Color cardBg, Color borderColor) {
    final now = DateTime.now();
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return SizedBox(height: 84, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 7, itemBuilder: (_, i) {
      final date = now.add(Duration(days: i));
      final isFirst = i == 0;
      return Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: Container(width: 64,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(color: isFirst ? accentColor.withValues(alpha: 0.12) : cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: isFirst ? accentColor.withValues(alpha: 0.35) : borderColor)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(days[date.weekday - 1], style: AppTypography.bodySmall.copyWith(color: mutedColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(date.day.toString(), style: AppTypography.headlineMediumBold.copyWith(color: isFirst ? accentColor : titleColor)),
        ])));
    }));
  }
}
