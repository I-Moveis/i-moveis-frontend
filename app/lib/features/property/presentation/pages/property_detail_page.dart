import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../data/mock_property_datasource.dart';
import '../providers/property_detail_provider.dart';
import '../widgets/amenities_grid.dart';
import '../widgets/location_map.dart';
import '../widgets/owner_card.dart';
import '../widgets/price_breakdown.dart';
import '../widgets/property_header.dart';
import '../widgets/property_info_cards.dart';
import '../widgets/similar_properties.dart';

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _heroFade;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    Future<void>.delayed(
      const Duration(milliseconds: 100),
      () { if (mounted) _entrance.forward(); },
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(propertyDetailProvider(widget.propertyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.whiteMuted),
        ),
        error: (_, __) => Center(
          child: Text(
            'Imóvel não encontrado.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.whiteMuted),
          ),
        ),
        data: (property) {
          final similars = kMockProperties
              .where((p) => p.id != property.id && p.type == property.type)
              .take(6)
              .toList();

          return AnimatedBuilder(
            animation: _entrance,
            builder: (context, _) {
              return Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Header (carousel + badges + actions) ─────────
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _heroFade.value,
                          child: PropertyHeader(
                            property: property,
                            onPhotosTap: () =>
                                context.push('/property/${widget.propertyId}/photos'),
                          ),
                        ),
                      ),

                      // ── Content ───────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _contentFade.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xl),

                                // Title & address
                                Text(
                                  property.title,
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: BrutalistPalette.title(isDark),
                                  ),
                                ),
                                if (property.address.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined, size: 14, color: BrutalistPalette.muted(isDark)),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          property.address,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: BrutalistPalette.muted(isDark),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: AppSpacing.xxl),

                                // Stats cards
                                PropertyInfoCards(property: property),

                                const SizedBox(height: AppSpacing.xxl),

                                // Description
                                Text(
                                  'Sobre',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: BrutalistPalette.title(isDark),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  property.description,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: BrutalistPalette.title(isDark).withValues(alpha: 0.8),
                                    height: 1.8,
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxl),

                                // Pricing
                                PriceBreakdown(property: property),

                                const SizedBox(height: AppSpacing.xxl),

                                // Amenities
                                if (property.amenities.isNotEmpty) ...[
                                  AmenitiesGrid(property: property),
                                  const SizedBox(height: AppSpacing.xxl),
                                ],

                                // Map
                                LocationMap(property: property),

                                const SizedBox(height: AppSpacing.xxl),

                                // Owner
                                OwnerCard(property: property),

                                const SizedBox(height: AppSpacing.xxl),

                                // Similar properties
                                SimilarProperties(
                                  properties: similars,
                                  onPropertyTap: (p) =>
                                      context.push('/property/${p.id}'),
                                ),

                                // Space for bottom bar
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Bottom action bar ─────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: _contentFade.value,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.blackLight : AppColors.white)
                              .withValues(alpha: 0.92),
                          border: Border(
                            top: BorderSide(color: borderColor, width: 0.5),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.push(
                                    '/property/${widget.propertyId}/schedule',
                                  ),
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.borderLg,
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Agendar visita',
                                        style: AppTypography.titleSmallBold.copyWith(
                                          color: BrutalistPalette.title(isDark),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: BrutalistGradientButton(
                                  label: 'PROPOSTA',
                                  height: 48,
                                  icon: Icons.description_outlined,
                                  onTap: () => context.push(
                                    '/property/${widget.propertyId}/proposal',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
