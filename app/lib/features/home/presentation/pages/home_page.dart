import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import './landlord_dashboard_page.dart';

/// Home page — Wrapper that switches between Tenant Home and Landlord Dashboard.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isOwner = state.maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );

        if (isOwner) {
          return const LandlordDashboardPage();
        }

        return const _TenantHomeContent();
      },
    );
  }
}

/// Original Tenant Home content.
class _TenantHomeContent extends StatefulWidget {
  const _TenantHomeContent({super.key});

  @override
  State<_TenantHomeContent> createState() => _TenantHomeContentState();
}

class _TenantHomeContentState extends State<_TenantHomeContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<double> _searchFade;
  late final Animation<double> _contentFade;

  int _selectedCategory = 0;

  static const _categories = [
    (icon: Icons.apartment_rounded, label: 'Apê'),
    (icon: Icons.house_rounded, label: 'Casa'),
    (icon: Icons.single_bed_rounded, label: 'Kitnet'),
    (icon: Icons.business_rounded, label: 'Studio'),
    (icon: Icons.pets_rounded, label: 'Pet friendly'),
    (icon: Icons.weekend_rounded, label: 'Mobiliado'),
  ];

  static const _featuredProperties = [
    _PropertyData(
      title: 'Cobertura Duplex',
      location: 'Jardins, São Paulo',
      price: r'R$ 4.200',
      area: '180m²',
      beds: 3,
      tag: 'Destaque',
      index: 1,
    ),
    _PropertyData(
      title: 'Loft Industrial',
      location: 'Vila Madalena, SP',
      price: r'R$ 3.800',
      area: '120m²',
      beds: 2,
      tag: 'Novo',
      index: 2,
    ),
    _PropertyData(
      title: 'Studio Premium',
      location: 'Pinheiros, SP',
      price: r'R$ 2.500',
      area: '45m²',
      beds: 1,
      tag: 'Exclusivo',
      index: 3,
    ),
  ];

  static const _nearbyProperties = [
    _PropertyData(
      title: 'Apê Moderno',
      location: 'Moema, SP',
      price: r'R$ 2.800',
      area: '65m²',
      beds: 2,
      index: 1,
    ),
    _PropertyData(
      title: 'Casa com Jardim',
      location: 'Brooklin, SP',
      price: r'R$ 5.500',
      area: '220m²',
      beds: 4,
      index: 2,
    ),
    _PropertyData(
      title: 'Kitnet Compacta',
      location: 'Consolação, SP',
      price: r'R$ 1.200',
      area: '28m²',
      beds: 1,
      index: 3,
    ),
  ];

  static const _trendingProperties = [
    _PropertyData(
      title: 'Penthouse Vista Mar',
      location: 'Leblon, RJ',
      price: r'R$ 12.000',
      area: '300m²',
      beds: 4,
      index: 1,
    ),
    _PropertyData(
      title: 'Flat Executivo',
      location: 'Itaim Bibi, SP',
      price: r'R$ 3.200',
      area: '55m²',
      beds: 1,
      index: 2,
    ),
    _PropertyData(
      title: 'Townhouse Privê',
      location: 'Vila Nova, SP',
      price: r'R$ 7.800',
      area: '190m²',
      beds: 3,
      index: 3,
    ),
  ];

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
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final subtitleColor = isDark ? AppColors.whiteDim : AppColors.lightTextSecondary;
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentPeach(isDark);

    return Opacity(
      opacity: _headerFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
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
                      Text('Olá!', style: AppTypography.bodyLarge.copyWith(color: subtitleColor)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Encontre seu lar', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: BrutalistPalette.subtleBg(isDark), borderRadius: AppRadius.borderMd),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_outlined, size: 22, color: mutedColor),
                        Positioned(
                          top: 11,
                          right: 13,
                          child: Container(width: 7, height: 7, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
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

  Widget _buildSearchBar(bool isDark) {
    final bgColor = BrutalistPalette.surfaceBg(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final hintColor = isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
    final iconColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

    return Opacity(
      opacity: _searchFade.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        child: GestureDetector(
          onTap: () => context.go('/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
            decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.borderXl, border: Border.all(color: borderColor)),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text('Onde você quer morar?', style: AppTypography.bodyLarge.copyWith(color: hintColor))),
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

  Widget _buildCategories(bool isDark) {
    return Opacity(
      opacity: _searchFade.value,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = i == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppChip(label: cat.label, icon: cat.icon, isSelected: isSelected, onTap: () => setState(() => _selectedCategory = i)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Destaques', action: 'Ver todos'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            itemCount: _featuredProperties.length,
            itemBuilder: (context, i) {
              return Padding(padding: const EdgeInsets.only(right: AppSpacing.lg), child: _buildFeaturedCard(_featuredProperties[i], isDark));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(_PropertyData property, bool isDark) {
    final cardBg = isDark ? AppColors.blackLight : AppColors.white;
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final tagBg = isDark ? BrutalistPalette.warmPeach.withValues(alpha: 0.12) : BrutalistPalette.deepOrange.withValues(alpha: 0.08);
    final imageBg = BrutalistPalette.imagePlaceholderBg(isDark);

    return GestureDetector(
      onTap: () => context.push('/property/${property.index}'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderXl, boxShadow: BrutalistPalette.subtleShadow(isDark)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: imageBg, child: Center(child: Icon(Icons.home_rounded, size: 48, color: (isDark ? Colors.white : BrutalistPalette.warmBrown).withValues(alpha: 0.12)))),
                  if (property.tag != null)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(color: tagBg, borderRadius: AppRadius.borderFull),
                        child: Text(property.tag!, style: AppTypography.propertyTag.copyWith(color: accentColor)),
                      ),
                    ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: BrutalistPalette.overlayPillBg(isDark), shape: BoxShape.circle),
                      child: Icon(Icons.favorite_outline_rounded, size: 16, color: mutedColor),
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
                  Text(property.title, style: AppTypography.titleLargeBold.copyWith(color: titleColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(children: [Icon(Icons.place_outlined, size: 13, color: mutedColor), const SizedBox(width: AppSpacing.xxs), Text(property.location, style: AppTypography.bodySmall.copyWith(color: mutedColor))]),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [Text('${property.price}/mês', style: AppTypography.titleMediumAccent.copyWith(color: accentColor)), const Spacer(), AppStatRow(icon: Icons.straighten_rounded, value: property.area, color: mutedColor), const SizedBox(width: AppSpacing.sm), AppStatRow(icon: Icons.bed_rounded, value: '${property.beds}q', color: mutedColor)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Perto de você', action: 'Ver mapa'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            itemCount: _nearbyProperties.length,
            itemBuilder: (context, i) {
              return Padding(padding: const EdgeInsets.only(right: AppSpacing.md), child: _buildNearbyCard(_nearbyProperties[i], isDark));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(_PropertyData property, bool isDark) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return GestureDetector(
      onTap: () => context.push('/property/${property.index}'),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(property.title, style: AppTypography.titleLargeBold.copyWith(color: titleColor), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: AppSpacing.xxs), Text(property.location, style: AppTypography.bodySmall.copyWith(color: mutedColor))]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${property.price}/mês', style: AppTypography.titleSmallAccent.copyWith(color: accentColor)), AppStatRow(icon: Icons.straighten_rounded, value: property.area, color: mutedColor)]),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Mais procurados'),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              for (int i = 0; i < _trendingProperties.length; i++) ...[
                _buildTrendingItem(_trendingProperties[i], i, isDark),
                if (i < _trendingProperties.length - 1) const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingItem(_PropertyData property, int rank, bool isDark) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final rankColor = isDark ? BrutalistPalette.warmAmber.withValues(alpha: 0.3) : BrutalistPalette.deepAmber.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: () => context.push('/property/${property.index}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
        child: Row(
          children: [
            SizedBox(width: 32, child: Text('${rank + 1}', style: AppTypography.headlineLargeBold.copyWith(color: rankColor))),
            const SizedBox(width: AppSpacing.md),
            Container(width: 56, height: 56, decoration: BoxDecoration(color: BrutalistPalette.imagePlaceholderBg(isDark), borderRadius: AppRadius.borderMd), child: Icon(Icons.home_rounded, size: 24, color: (isDark ? Colors.white : BrutalistPalette.warmBrown).withValues(alpha: 0.12))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: AppTypography.titleLargeBold.copyWith(color: titleColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(property.location, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${property.price}/mês', style: AppTypography.titleSmallAccent.copyWith(color: accentColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: mutedColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _PropertyData {
  const _PropertyData({required this.title, required this.location, required this.price, required this.area, required this.beds, required this.index, this.tag});
  final String title;
  final String location;
  final String price;
  final String area;
  final int beds;
  final int index;
  final String? tag;
}
