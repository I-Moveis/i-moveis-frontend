import '../../../../design_system/design_system.dart';
import '../../domain/entities/property.dart';
import 'package:flutter/material.dart';

/// A card for property listings with an integrated image carousel.
class PropertyCarouselCard extends StatelessWidget {
  /// Creates a [PropertyCarouselCard].
  const PropertyCarouselCard({
    required this.property,
    this.onTap,
    super.key,
  });

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            AspectRatio(
              aspectRatio: 2.1 / 1, // Slimmer carousel as requested
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
                  // Indicator
                  Positioned(
                    bottom: AppSpacing.sm,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        '1 / ${property.imageUrls.isEmpty ? 1 : property.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // "Exclusive" tag
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: const Text(
                        'DESTAQUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
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
                      Text(
                        property.price,
                        style: AppTypography.titleMediumBold.copyWith(color: accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    property.type,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
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
