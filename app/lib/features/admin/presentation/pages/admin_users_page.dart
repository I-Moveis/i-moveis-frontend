import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Admin users — cozy user management list.
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

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

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          const SliverToBoxAdapter(child: BrutalistAppBar(title: 'Usuários')),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int i = 0; i < 10; i++) ...[
              _card(i, isDark, titleColor, mutedColor, accentColor, cardBg, borderColor),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

  Widget _card(int i, bool isDark, Color title, Color muted, Color accent, Color bg, Color border) {
    final isOwner = i % 3 == 0;
    final roleColor = isOwner ? accent : (isDark ? BrutalistPalette.warmAmber : BrutalistPalette.deepAmber);
    return Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderLg, border: Border.all(color: border)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.1)),
          child: Center(child: Text('${i + 1}', style: AppTypography.titleSmallBold.copyWith(color: accent)))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Usuário ${i + 1}', style: AppTypography.titleLargeBold.copyWith(color: title)),
          const SizedBox(height: AppSpacing.xxs),
          Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs), decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
            child: Text(isOwner ? 'Proprietário' : 'Inquilino', style: AppTypography.tagBadge.copyWith(color: roleColor))),
        ])),
        GestureDetector(onTap: () {}, child: Container(width: 32, height: 32,
          decoration: BoxDecoration(color: BrutalistPalette.subtleBg(isDark), borderRadius: AppRadius.borderMd),
          child: Icon(Icons.more_horiz_rounded, size: 16, color: muted))),
      ]));
  }
}
