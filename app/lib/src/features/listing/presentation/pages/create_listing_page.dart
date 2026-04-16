import 'package:flutter/material.dart';
import 'package:app/src/design_system/design_system.dart';

/// Create listing — cozy multi-step wizard.
class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});
  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  int _step = 0;
  static const _steps = ['Tipo de imóvel', 'Endereço', 'Detalhes', 'Amenidades', 'Fotos', 'Descrição', 'Preço', 'Revisão'];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: Column(children: [
          BrutalistAppBar(title: 'Anunciar', onBack: _back),
          Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Progress
            Text('Etapa ${_step + 1} de ${_steps.length}', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(borderRadius: AppRadius.borderFull, child: SizedBox(height: 3, child: Stack(children: [
              Container(color: BrutalistPalette.subtleBg(isDark)),
              FractionallySizedBox(widthFactor: ((_step + 1) / _steps.length).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: accentColor, borderRadius: AppRadius.borderFull))),
            ]))),
            const SizedBox(height: AppSpacing.xxl),
            Text(_steps[_step], style: AppTypography.headlineLarge.copyWith(color: titleColor)),
          ])),
          // Step content
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.home_rounded, size: 48, color: accentColor.withValues(alpha: 0.15)),
            const SizedBox(height: AppSpacing.lg),
            Text('Conteúdo da etapa', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
          ]))),
          // Nav buttons
          Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: GestureDetector(onTap: _back, child: Container(height: 48, decoration: BoxDecoration(borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                child: Center(child: Text('Voltar', style: AppTypography.titleSmallBold.copyWith(color: titleColor)))))),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(child: BrutalistGradientButton(label: _step == _steps.length - 1 ? 'PUBLICAR' : 'PRÓXIMO', height: 48, onTap: _step == _steps.length - 1 ? () => Navigator.of(context).pop() : _next)),
          ])),
          const SizedBox(height: AppSpacing.xxl),
        ]));
      },
    );
  }
}
