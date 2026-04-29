import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class SimilarProperties extends StatelessWidget {
  const SimilarProperties({
    required this.properties,
    this.onPropertyTap,
    super.key,
  });

  final List<Property> properties;
  final void Function(Property)? onPropertyTap;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imóveis Similares', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _SimilarCard(
              property: properties[index],
              onTap: onPropertyTap != null ? () => onPropertyTap!(properties[index]) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({required this.property, this.onTap});

  final Property property;
  final VoidCallback? onTap;

  static const _cardWidth = 180.0;
  static const _imageHeight = 110.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _cardWidth,
        decoration: BoxDecoration(
          color: BrutalistPalette.surfaceBg(isDark),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(property: property, isDark: isDark),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: BrutalistPalette.title(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    property.price,
                    style: AppTypography.titleMediumBold.copyWith(
                      color: BrutalistPalette.accentOrange(isDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _QuickInfo(property: property, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.property, required this.isDark});

  final Property property;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _SimilarCard._imageHeight,
      width: double.infinity,
      child: property.imageUrls.isNotEmpty
          ? Image.network(
              property.imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Placeholder(property: property, isDark: isDark),
            )
          : _Placeholder(property: property, isDark: isDark),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.property, required this.isDark});

  final Property property;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrutalistPalette.imagePlaceholderBg(isDark),
      child: Center(
        child: Icon(
          IconData(property.thumbnailIconCode, fontFamily: 'MaterialIcons'),
          size: 36,
          color: BrutalistPalette.muted(isDark).withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({required this.property, required this.isDark});

  final Property property;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InfoChip(icon: Icons.bed_outlined, label: '${property.bedrooms}', isDark: isDark),
        const SizedBox(width: AppSpacing.xs),
        _InfoChip(icon: Icons.square_foot, label: '${property.area.toInt()}m²', isDark: isDark),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.isDark});

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: BrutalistPalette.muted(isDark)),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark)),
        ),
      ],
    );
  }
}
