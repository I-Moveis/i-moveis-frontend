import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/property.dart';

/// A detailed list tile for property listings with integrated image carousel
/// and domain-specific information (area, rooms, total price).
class PropertyListTile extends ConsumerWidget {
  const PropertyListTile({
    required this.property,
    this.onTap,
    super.key,
  });

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    
    final isFavorite = ref.watch(favoritedIdsProvider).contains(property.id);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with Favorite Button
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: property.imageUrls.isEmpty ? 1 : property.imageUrls.length,
                    itemBuilder: (context, index) {
                      return ColoredBox(
                        color: BrutalistPalette.imagePlaceholderBg(isDark),
                        child: property.imageUrls.isEmpty
                            ? Center(
                                child: Icon(
                                  IconData(property.thumbnailIconCode, fontFamily: 'MaterialIcons'),
                                  size: 48,
                                  color: (isDark ? Colors.white : BrutalistPalette.warmBrown)
                                      .withValues(alpha: 0.1),
                                ),
                              )
                            : Image.network(
                                property.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    IconData(property.thumbnailIconCode, fontFamily: 'MaterialIcons'),
                                    size: 48,
                                    color: (isDark ? Colors.white : BrutalistPalette.warmBrown)
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                  // Favorite Button
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(property.id),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Page Indicator
                  if (property.imageUrls.length > 1)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          property.imageUrls.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: AppTypography.titleLargeBold.copyWith(color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Semantics(
                        label: 'Preço mensal',
                        child: Text(
                          property.price,
                          style: AppTypography.titleMediumBold.copyWith(color: accentColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    property.type,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Quick Info Row
                  Row(
                    children: [
                      _buildInfoItem(Icons.square_foot, '${property.area.toInt()} m²', isDark),
                      const SizedBox(width: AppSpacing.md),
                      _buildInfoItem(Icons.bed_outlined, '${property.bedrooms}', isDark),
                      const SizedBox(width: AppSpacing.md),
                      _buildInfoItem(Icons.bathtub_outlined, '${property.bathrooms}', isDark),
                      const SizedBox(width: AppSpacing.md),
                      _buildInfoItem(Icons.directions_car_outlined, '${property.parkingSpots}', isDark),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Total Price Detail
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total (c/ taxas)',
                          style: AppTypography.labelMedium.copyWith(color: mutedColor),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Semantics(
                            label: 'Preço total incluindo taxas',
                            child: Text(
                              'R\$ ${property.totalPrice.toInt()}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTypography.labelLarge.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, bool isDark) {
    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: BrutalistPalette.muted(isDark).withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: BrutalistPalette.title(isDark).withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
