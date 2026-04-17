import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// Favorites tab — cozy empty state with warm CTA.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);

        return Opacity(
          opacity: fade.value,
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: AppSpacing.xl),
                Text('Salvos', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
              ]),
            ),
            // Empty state
            Expanded(child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite_rounded, size: 48, color: accentColor.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.xl),
                Text('Nenhum favorito', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
                const SizedBox(height: AppSpacing.sm),
                Text('Explore e salve imóveis que\ncombinem com você', textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: mutedColor, height: 1.8)),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(width: double.infinity, child: BrutalistGradientButton(label: 'EXPLORAR IMÓVEIS', icon: Icons.search_rounded, onTap: () => context.go('/search'))),
              ]),
            ))),
          ]),
        );
      },
    );
  }
}
