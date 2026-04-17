import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Admin listings — cozy listing moderation.
class AdminListingsPage extends StatelessWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          const SliverToBoxAdapter(child: BrutalistAppBar(title: 'Moderação')),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Filters
            Wrap(spacing: AppSpacing.sm, children: ['Todos', 'Pendentes', 'Aprovados'].map((l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
              child: Text(l, style: AppTypography.titleSmallBold.copyWith(color: accentColor)),
            )).toList()),
            const SizedBox(height: AppSpacing.xxl),
            for (int i = 0; i < 8; i++) ...[
              AppPropertyCard(
                title: 'Imóvel ${i + 1}',
                status: i % 3 != 0 ? 'Pendente' : 'Aprovado',
                statusColor: i % 3 != 0 ? (isDark ? BrutalistPalette.warmAmber : BrutalistPalette.deepAmber) : AppColors.success,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: AppRadius.borderMd),
                        child: const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: AppRadius.borderMd),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

}
