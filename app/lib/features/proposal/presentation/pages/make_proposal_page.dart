import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Make proposal — cozy form with rounded inputs.
class MakeProposalPage extends StatelessWidget {
  const MakeProposalPage({required this.propertyId, super.key});
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
          const BrutalistAppBar(title: 'Proposta'),
          Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Property summary
            Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: BrutalistPalette.imagePlaceholderBg(isDark), borderRadius: AppRadius.borderMd), child: Icon(Icons.home_rounded, size: 24, color: accentColor.withValues(alpha: 0.3))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Apartamento — Vila Madalena', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                  Text(r'R$ 2.500/mês', style: AppTypography.bodySmallBold.copyWith(color: accentColor)),
                ])),
              ])),
            const SizedBox(height: AppSpacing.xxl),

            _sectionLabel('Valor proposto', titleColor),
            const SizedBox(height: AppSpacing.sm),
            _input(r'R$ 2.500,00', Icons.attach_money_rounded, isDark, titleColor, mutedColor, cardBg, borderColor, accentColor),
            const SizedBox(height: AppSpacing.xxl),

            _sectionLabel('Prazo do contrato', titleColor),
            const SizedBox(height: AppSpacing.sm),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: ['12 meses', '24 meses', '30 meses', '36 meses'].map((d) => _chip(d, accentColor, isDark)).toList()),
            const SizedBox(height: AppSpacing.xxl),

            _sectionLabel('Data de entrada', titleColor),
            const SizedBox(height: AppSpacing.sm),
            _input('Selecionar data', Icons.calendar_today_rounded, isDark, titleColor, mutedColor, cardBg, borderColor, accentColor),
            const SizedBox(height: AppSpacing.xxl),

            _sectionLabel('Mensagem (opcional)', titleColor),
            const SizedBox(height: AppSpacing.sm),
            Container(height: 120, padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
              child: TextField(maxLines: null, expands: true, style: AppTypography.bodyLarge.copyWith(color: titleColor), cursorColor: accentColor, cursorWidth: 1.5,
                decoration: InputDecoration(hintText: 'Escreva algo para o proprietário...', hintStyle: AppTypography.bodyLarge.copyWith(color: BrutalistPalette.faint(isDark)), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
            const SizedBox(height: AppSpacing.xxxl),
            BrutalistGradientButton(label: 'ENVIAR PROPOSTA', icon: Icons.send_rounded, onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

  Widget _sectionLabel(String text, Color color) => Text(text, style: AppTypography.titleSmallBold.copyWith(color: color.withValues(alpha: 0.5)));
  Widget _input(String hint, IconData icon, bool isDark, Color title, Color muted, Color bg, Color border, Color accent) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg), decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderLg, border: Border.all(color: border)),
      child: Row(children: [Icon(icon, size: 18, color: muted), const SizedBox(width: AppSpacing.md), Text(hint, style: AppTypography.bodyLarge.copyWith(color: BrutalistPalette.faint(isDark)))]));
  }
  Widget _chip(String label, Color color, bool isDark) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
      child: Text(label, style: AppTypography.titleSmallBold.copyWith(color: color)));
  }
}
