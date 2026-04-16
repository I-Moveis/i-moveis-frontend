import 'package:flutter/material.dart';
import 'package:app/src/design_system/design_system.dart';

/// Admin contracts — cozy contract management.
class AdminContractsPage extends StatelessWidget {
  const AdminContractsPage({super.key});

  static const _contracts = [
    _C(id: '1001', status: 'Ativo', color: AppColors.success),
    _C(id: '1002', status: 'Pendente assinatura', color: AppColors.pending),
    _C(id: '1003', status: 'Ativo', color: AppColors.success),
    _C(id: '1004', status: 'Rascunho', color: AppColors.info),
    _C(id: '1005', status: 'Encerrado', color: AppColors.error),
    _C(id: '1006', status: 'Ativo', color: AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: BrutalistAppBar(title: 'Contratos')),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: AppSpacing.sm, children: ['Todos', 'Ativos', 'Pendentes', 'Encerrados'].map((l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
              child: Text(l, style: AppTypography.titleSmallBold.copyWith(color: accentColor)),
            )).toList()),
            const SizedBox(height: AppSpacing.xxl),
            for (final c in _contracts) ...[
              GestureDetector(onTap: () {}, child: Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                child: Row(children: [
                  Icon(Icons.article_outlined, size: 20, color: accentColor.withValues(alpha: 0.5)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Contrato #${c.id}', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs), decoration: BoxDecoration(color: c.color.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
                      child: Text(c.status, style: AppTypography.tagBadge.copyWith(color: c.color))),
                  ])),
                  Icon(Icons.chevron_right_rounded, size: 18, color: mutedColor.withValues(alpha: 0.4)),
                ]))),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }
}

class _C {
  const _C({required this.id, required this.status, required this.color});
  final String id;
  final String status;
  final Color color;
}
