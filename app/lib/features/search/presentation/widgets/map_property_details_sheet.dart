import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/property.dart';

/// Sheet que aparece quando o usuário toca em um pin no mapa.
/// Estilo Google Maps: imagem à esquerda, infos à direita, ações embaixo
/// (detalhes, rotas, street view).
class MapPropertyDetailsSheet extends StatelessWidget {
  const MapPropertyDetailsSheet({
    required this.property,
    required this.onClose,
    super.key,
  });

  final Property property;
  final VoidCallback onClose;

  Future<void> _openStreetView() async {
    final url = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano'
      '&viewpoint=${property.latitude},${property.longitude}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${property.latitude},${property.longitude}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final bgColor = isDark ? AppColors.blackLight : AppColors.white;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final dividerColor = BrutalistPalette.dividerColor(isDark);

    final imageUrl =
        property.imageUrls.isNotEmpty ? property.imageUrls.first : null;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: image + info + close button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.borderMd,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildImagePlaceholder(isDark),
                            )
                          : _buildImagePlaceholder(isDark),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                property.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMediumBold.copyWith(
                                  color: titleColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onClose,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.sm,
                                  top: AppSpacing.xxs,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: mutedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        if (property.address.isNotEmpty)
                          Text(
                            property.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: mutedColor,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${property.price}/mês',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleSmallAccent.copyWith(
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _StatChip(
                              icon: Icons.straighten_rounded,
                              label: '${property.area.toInt()}m²',
                              color: mutedColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _StatChip(
                              icon: Icons.bed_rounded,
                              label: '${property.bedrooms}q',
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
            Container(height: 1, color: dividerColor),
            // Actions row: Detalhes / Rotas / Street View
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.info_outline_rounded,
                    label: 'Detalhes',
                    color: accentColor,
                    onTap: () => context.push('/property/${property.id}'),
                  ),
                ),
                Container(width: 1, height: 44, color: dividerColor),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.directions_rounded,
                    label: 'Rotas',
                    color: accentColor,
                    onTap: _openDirections,
                  ),
                ),
                Container(width: 1, height: 44, color: dividerColor),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.streetview_rounded,
                    label: 'Street View',
                    color: accentColor,
                    onTap: _openStreetView,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return ColoredBox(
      color: BrutalistPalette.imagePlaceholderBg(isDark),
      child: Center(
        child: Icon(
          Icons.home_rounded,
          size: 32,
          color: (isDark ? AppColors.white : BrutalistPalette.warmBrown)
              .withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
