import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/design_system.dart';

class PropertyData {
  const PropertyData({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.area,
    required this.beds,
    this.tag,
  });

  final String id;
  final String title;
  final String location;
  final String price;
  final String area;
  final int beds;
  final String? tag;
}

const kFeaturedProperties = [
  PropertyData(
    id: '1',
    title: 'Cobertura Duplex',
    location: 'Jardins, São Paulo',
    price: r'R$ 4.200',
    area: '180m²',
    beds: 3,
    tag: 'Destaque',
  ),
  PropertyData(
    id: '2',
    title: 'Loft Industrial',
    location: 'Vila Madalena, SP',
    price: r'R$ 3.800',
    area: '120m²',
    beds: 2,
    tag: 'Novo',
  ),
  PropertyData(
    id: '3',
    title: 'Studio Premium',
    location: 'Pinheiros, SP',
    price: r'R$ 2.500',
    area: '45m²',
    beds: 1,
    tag: 'Exclusivo',
  ),
];

class FeaturedSection extends StatefulWidget {
  const FeaturedSection({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            itemCount: widget.isLoading ? 3 : kFeaturedProperties.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: widget.isLoading
                  ? _ShimmerCard(controller: _shimmerController)
                  : _FeaturedCard(property: kFeaturedProperties[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.blackLight : AppColors.lightSurface;
    final highlight = isDark
        ? AppColors.blackLightest
        : AppColors.white;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderXl,
            gradient: LinearGradient(
              begin: Alignment(-1 + controller.value * 2, 0),
              end: Alignment(controller.value * 2, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.property});
  final PropertyData property;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.blackLight : AppColors.white;
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final tagBg = isDark
        ? BrutalistPalette.warmPeach.withValues(alpha: 0.12)
        : BrutalistPalette.deepOrange.withValues(alpha: 0.08);

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
                  ColoredBox(
                    color: BrutalistPalette.imagePlaceholderBg(isDark),
                    child: Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 48,
                        color: (isDark ? Colors.white : BrutalistPalette.warmBrown)
                            .withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  if (property.tag != null)
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
                          property.tag!,
                          style: AppTypography.propertyTag
                              .copyWith(color: accentColor),
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
                      child: Icon(Icons.favorite_outline_rounded,
                          size: 16, color: mutedColor),
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
                    style: AppTypography.titleLargeBold
                        .copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 13, color: mutedColor),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        property.location,
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '${property.price}/mês',
                        style: AppTypography.titleMediumAccent
                            .copyWith(color: accentColor),
                      ),
                      const Spacer(),
                      AppStatRow(
                        icon: Icons.straighten_rounded,
                        value: property.area,
                        color: mutedColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppStatRow(
                        icon: Icons.bed_rounded,
                        value: '${property.beds}q',
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
}
