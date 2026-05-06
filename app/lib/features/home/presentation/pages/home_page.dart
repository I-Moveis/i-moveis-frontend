import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';
import '../providers/home_properties_providers.dart';
import '../widgets/category_bar.dart';

/// Home page ÔÇö Cozy & warm, Airbnb-inspired with sunset wave backdrop.
///
/// Friendly greeting, rounded cards, soft pastels, generous spacing.
/// Puxa im├│veis reais do backend via tr├¬s `FutureProvider`s (destaques /
/// perto / mais procurados), cada um com uma ordena├º├úo diferente.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<double> _searchFade;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _searchFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    ref
      ..invalidate(featuredHomePropertiesProvider)
      ..invalidate(nearbyHomePropertiesProvider)
      ..invalidate(trendingHomePropertiesProvider);
    await Future.wait([
      ref.read(featuredHomePropertiesProvider.future),
      ref.read(nearbyHomePropertiesProvider.future),
      ref.read(trendingHomePropertiesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: WaveBackground(
              speed: 0.25,
              amplitude: 0.5,
              waveCount: 4,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(isDark)),
                      SliverToBoxAdapter(child: _buildSearchBar(isDark)),
                      SliverToBoxAdapter(child: _buildCategories(isDark)),
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _contentFade.value,
                          child: Column(
                            children: [
                              _buildFeaturedSection(isDark),
                              const SizedBox(height: AppSpacing.xxxl),
                              _buildNearbySection(isDark),
                              const SizedBox(height: AppSpacing.xxxl),
                              _buildTrendingSection(isDark),
                              const SizedBox(height: AppSpacing.huge),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  HEADER ÔÇö friendly greeting, warm and human
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final subtitleColor =
        isDark ? AppColors.whiteDim : AppColors.lightTextSecondary;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentPeach(isDark);

    return Opacity(
      opacity: _headerFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ol├í!',
                        style: AppTypography.bodyLarge.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Encontre seu lar',
                        style: AppTypography.headlineLarge.copyWith(
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: BrutalistPalette.subtleBg(isDark),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 22,
                          color: mutedColor,
                        ),
                        Positioned(
                          top: 11,
                          right: 13,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  SEARCH BAR ÔÇö rounded, inviting, tap-to-search
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildSearchBar(bool isDark) {
    final bgColor = BrutalistPalette.surfaceBg(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final hintColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
    final iconColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

    return Opacity(
      opacity: _searchFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: GestureDetector(
          onTap: () => context.go('/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.mdLg,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Onde voc├¬ quer morar?',
                    style: AppTypography.bodyLarge.copyWith(color: hintColor),
                  ),
                ),
                Container(width: 1, height: 20, color: borderColor),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.tune_rounded, size: 18, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  CATEGORIES ÔÇö rounded pill chips (visual only for now)
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildCategories(bool isDark) {
    return Opacity(
      opacity: _searchFade.value,
      child: const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xl),
        child: CategoryBar(),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  FEATURED ÔÇö horizontal cards with image placeholder + badge
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildFeaturedSection(bool isDark) {
    final asyncValue = ref.watch(featuredHomePropertiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(
          title: 'Destaques',
          action: 'Ver todos',
          onAction: () => context.go('/search'),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 270,
          child: asyncValue.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyRow(
                  isDark,
                  'Nenhum destaque no momento.',
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: _buildFeaturedCard(items[i], isDark),
                ),
              );
            },
            loading: () => _buildFeaturedSkeleton(isDark),
            error: (err, _) => _buildErrorRow(
              isDark,
              onRetry: () => ref.invalidate(featuredHomePropertiesProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Property property, bool isDark) {
    final cardBg = isDark ? AppColors.blackLight : AppColors.white;
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final tagBg = isDark
        ? BrutalistPalette.warmPeach.withValues(alpha: 0.12)
        : BrutalistPalette.deepOrange.withValues(alpha: 0.08);
    final imageBg = BrutalistPalette.imagePlaceholderBg(isDark);

    final badge = property.badges.isNotEmpty ? property.badges.first : null;
    final firstImage =
        property.imageUrls.isNotEmpty ? property.imageUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderXl,
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (firstImage != null)
                    Image.network(
                      firstImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _buildImagePlaceholder(isDark, imageBg),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _buildImagePlaceholder(isDark, imageBg);
                      },
                    )
                  else
                    _buildImagePlaceholder(isDark, imageBg),
                  if (badge != null)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.propertyTag.copyWith(
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: BrutalistPalette.overlayPillBg(isDark),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        property.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 16,
                        color: property.isFavorite ? accentColor : mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTypography.titleLargeBold.copyWith(
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: mutedColor,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          property.address.isNotEmpty
                              ? property.address
                              : 'ÔÇö',
                          style: AppTypography.bodySmall.copyWith(
                            color: mutedColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${property.price}/m├¬s',
                          style: AppTypography.titleMediumAccent.copyWith(
                            color: accentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppStatRow(
                        icon: Icons.straighten_rounded,
                        value: '${property.area.toInt()}m┬▓',
                        color: mutedColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppStatRow(
                        icon: Icons.bed_rounded,
                        value: '${property.bedrooms}q',
                        color: mutedColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  NEARBY ÔÇö compact horizontal cards
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildNearbySection(bool isDark) {
    final asyncValue = ref.watch(nearbyHomePropertiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Perto de voc├¬',
          action: 'Ver mapa',
          onAction: () => context.go('/search/map'),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 150,
          child: asyncValue.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyRow(
                  isDark,
                  'Nenhum imóvel disponível agora.',
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _buildNearbyCard(items[i], isDark),
                ),
              );
            },
            loading: () => _buildNearbySkeleton(isDark),
            error: (err, _) => _buildErrorRow(
              isDark,
              onRetry: () => ref.invalidate(nearbyHomePropertiesProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(Property property, bool isDark) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: AppTypography.titleLargeBold.copyWith(
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  property.address.isNotEmpty ? property.address : 'ÔÇö',
                  style: AppTypography.bodySmall.copyWith(color: mutedColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${property.price}/m├¬s',
                    style: AppTypography.titleSmallAccent.copyWith(
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppStatRow(
                  icon: Icons.straighten_rounded,
                  value: '${property.area.toInt()}m┬▓',
                  color: mutedColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  TRENDING ÔÇö vertical list with rank number
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildTrendingSection(bool isDark) {
    final asyncValue = ref.watch(trendingHomePropertiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Mais procurados'),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: asyncValue.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyBox(
                  isDark,
                  'Sem dados de popularidade ainda.',
                );
              }
              return Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _buildTrendingItem(items[i], i, isDark),
                    if (i < items.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            },
            loading: () => _buildTrendingSkeleton(isDark),
            error: (err, _) => _buildErrorRow(
              isDark,
              onRetry: () => ref.invalidate(trendingHomePropertiesProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingItem(Property property, int rank, bool isDark) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final rankColor = isDark
        ? BrutalistPalette.warmAmber.withValues(alpha: 0.3)
        : BrutalistPalette.deepAmber.withValues(alpha: 0.2);
    final firstImage =
        property.imageUrls.isNotEmpty ? property.imageUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${rank + 1}',
                style: AppTypography.headlineLargeBold.copyWith(
                  color: rankColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: AppRadius.borderMd,
              child: SizedBox(
                width: 56,
                height: 56,
                child: firstImage != null
                    ? Image.network(
                        firstImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildImagePlaceholder(isDark, null),
                      )
                    : _buildImagePlaceholder(isDark, null),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTypography.titleLargeBold.copyWith(
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    property.address.isNotEmpty ? property.address : 'ÔÇö',
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${property.price}/m├¬s',
                    style: AppTypography.titleSmallAccent.copyWith(
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: mutedColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  //  PLACEHOLDERS / STATES
  // ÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉÔòÉ
  Widget _buildImagePlaceholder(bool isDark, Color? bg) {
    final color = bg ?? BrutalistPalette.imagePlaceholderBg(isDark);
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          Icons.home_rounded,
          size: 40,
          color: (isDark ? Colors.white : BrutalistPalette.warmBrown)
              .withValues(alpha: 0.12),
        ),
      ),
    );
  }

  Widget _buildFeaturedSkeleton(bool isDark) {
    final skeletonColor = BrutalistPalette.imagePlaceholderBg(isDark);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      itemCount: 3,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: AppRadius.borderXl,
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySkeleton(bool isDark) {
    final skeletonColor = BrutalistPalette.imagePlaceholderBg(isDark);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      itemCount: 3,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: AppRadius.borderLg,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSkeleton(bool isDark) {
    final skeletonColor = BrutalistPalette.imagePlaceholderBg(isDark);
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < 2 ? AppSpacing.md : 0),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: AppRadius.borderLg,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyRow(bool isDark, String message) {
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodySmall.copyWith(color: mutedColor),
        ),
      ),
    );
  }

  Widget _buildEmptyBox(bool isDark, String message) {
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      alignment: Alignment.center,
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: mutedColor),
      ),
    );
  }

  Widget _buildErrorRow(bool isDark, {required VoidCallback onRetry}) {
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 16,
              color: mutedColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Falha ao carregar.',
              style: AppTypography.bodySmall.copyWith(color: mutedColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'TENTAR DE NOVO',
                style: AppTypography.labelSmall.copyWith(color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
