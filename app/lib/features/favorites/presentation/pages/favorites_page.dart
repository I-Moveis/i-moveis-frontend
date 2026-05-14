import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../listing/presentation/pages/my_properties_page.dart';
import '../../../property/presentation/providers/property_detail_provider.dart';
import '../../../search/presentation/widgets/property_list_tile.dart';
import '../../domain/entities/favorite.dart';
import '../providers/favorites_provider.dart';

/// Favorites tab — lista imóveis favoritados pelo usuário, ou redireciona
/// pra MyPropertiesPage caso o usuário seja owner.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );

    if (isOwner) {
      return const MyPropertiesPage();
    }

    final async = ref.watch(favoritesProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: fade.value,
          child: Column(
            children: [
              const BrutalistPageHeader(
                title: 'Salvos',
                subtitle: 'Imóveis que você favoritou pra ver depois',
              ),
              Expanded(
                child: async.when(
                  data: (favorites) => favorites.isEmpty
                      ? _EmptyState(isDark: isDark)
                      : _FavoritesList(favorites: favorites),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => _ErrorState(
                    isDark: isDark,
                    onRetry: () => ref.invalidate(favoritesProvider),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 48,
              color: accentColor.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Nenhum favorito',
              style:
                  AppTypography.headlineMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Explore e salve imóveis que\ncombinem com você',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: mutedColor, height: 1.8),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: BrutalistGradientButton(
                label: 'EXPLORAR IMÓVEIS',
                icon: Icons.search_rounded,
                onTap: () => context.go('/search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: mutedColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Não deu pra carregar',
              style: AppTypography.headlineMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cheque sua conexão e tente de novo.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: BrutalistGradientButton(
                label: 'TENTAR NOVAMENTE',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.favorites});

  final List<Favorite> favorites;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return _FavoriteTile(favorite: fav);
      },
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.favorite});

  final Favorite favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fast path: o backend devolve `property` aninhado em GET /favorites,
    // então 99% das vezes a tile renderiza sem round-trip extra.
    final property = favorite.property;
    if (property != null) {
      return PropertyListTile(
        property: property,
        onTap: () => context.push('/property/${property.id}'),
      );
    }

    // Fallback: update otimista (POST ainda pendente) — busca pelo id.
    final async =
        ref.watch(propertyDetailProvider(favorite.propertyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return async.when(
      data: (p) => PropertyListTile(
        property: p,
        onTap: () => context.push('/property/${p.id}'),
      ),
      loading: () => _SkeletonTile(isDark: isDark),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: BrutalistPalette.surfaceBorder(isDark),
          width: 1.5,
        ),
      ),
    );
  }
}
