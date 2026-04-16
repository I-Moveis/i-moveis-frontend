import 'package:flutter/material.dart';
import 'package:app/src/design_system/design_system.dart';

/// Listing analytics — cozy metrics with CountUpText.
class ListingAnalyticsPage extends StatelessWidget {
  const ListingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: BrutalistAppBar(title: 'Analytics')),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: AppSpacing.sm, children: ['7 dias', '30 dias', 'Total'].map((l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
              child: Text(l, style: AppTypography.titleSmallBold.copyWith(color: accentColor)),
            )).toList()),
            const SizedBox(height: AppSpacing.xxl),
            Row(children: [
              AppMetricCard(icon: Icons.visibility_outlined, value: 142, label: 'Visualizações'),
              const SizedBox(width: AppSpacing.md),
              AppMetricCard(icon: Icons.favorite_outline, value: 23, label: 'Favoritos'),
            ]),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              AppMetricCard(icon: Icons.description_outlined, value: 5, label: 'Propostas'),
              const SizedBox(width: AppSpacing.md),
              AppMetricCard(icon: Icons.calendar_today_outlined, value: 8, label: 'Visitas'),
            ]),
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

}
