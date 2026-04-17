import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Contract page — cozy stepper with PDF preview.
class ContractPage extends StatelessWidget {
  const ContractPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: Column(children: [
          const BrutalistAppBar(title: 'Contrato'),
          Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Progresso', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.lg),
            const BrutalistStepper(currentStep: 2, steps: [
              BrutalistStepData(label: 'Proposta aceita', state: BrutalistStepState.completed),
              BrutalistStepData(label: 'Contrato gerado', state: BrutalistStepState.completed),
              BrutalistStepData(label: 'Assinatura inquilino', state: BrutalistStepState.active),
              BrutalistStepData(label: 'Assinatura proprietário'),
              BrutalistStepData(label: 'Contrato ativo'),
            ]),
            const SizedBox(height: AppSpacing.xxl),
            Text('Documento', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.lg),
            Container(height: 200, decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.picture_as_pdf_outlined, size: 40, color: accentColor.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.md),
                Text('Preview do contrato', style: AppTypography.titleSmall.copyWith(color: mutedColor)),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(onTap: () {}, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(borderRadius: AppRadius.borderFull, border: Border.all(color: borderColor)),
                  child: Text('Baixar PDF', style: AppTypography.titleSmall.copyWith(color: mutedColor)),
                )),
              ]))),
            const SizedBox(height: AppSpacing.xxxl),
            BrutalistGradientButton(label: 'ASSINAR CONTRATO', icon: Icons.draw_rounded, onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }
}
