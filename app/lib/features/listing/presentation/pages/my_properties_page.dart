import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// My properties — cozy owner property list.
class MyPropertiesPage extends StatelessWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          const SliverToBoxAdapter(child: BrutalistAppBar(title: 'Meus imóveis')),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // New listing button
            GestureDetector(onTap: () => context.go('/profile/my-properties/create'), child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.08), borderRadius: AppRadius.borderLg, border: Border.all(color: accentColor.withValues(alpha: 0.2))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_rounded, size: 20, color: accentColor),
                const SizedBox(width: AppSpacing.sm),
                Text('Novo anúncio', style: AppTypography.titleSmallBold.copyWith(color: accentColor)),
              ]),
            )),
            const SizedBox(height: AppSpacing.xxl),
            for (int i = 0; i < 2; i++) ...[
              AppPropertyCard(
                title: 'Imóvel ${i + 1}',
                status: ['Disponível', 'Alugado'][i],
                statusColor: [AppColors.success, if (isDark) BrutalistPalette.warmAmber else BrutalistPalette.deepAmber][i],
                trailing: GestureDetector(
                  onTap: () => context.go('/profile/my-properties/analytics'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: BrutalistPalette.subtleBg(isDark), borderRadius: AppRadius.borderMd),
                    child: Icon(Icons.bar_chart_rounded, size: 16, color: mutedColor),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

}
