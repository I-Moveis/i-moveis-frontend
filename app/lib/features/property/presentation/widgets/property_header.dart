import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../search/domain/entities/property.dart';

class PropertyHeader extends ConsumerStatefulWidget {
  const PropertyHeader({
    required this.property,
    required this.onPhotosTap,
    super.key,
  });

  final Property property;
  final VoidCallback onPhotosTap;

  @override
  ConsumerState<PropertyHeader> createState() => _PropertyHeaderState();
}

class _PropertyHeaderState extends ConsumerState<PropertyHeader> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final isFavorite =
        ref.watch(favoritedIdsProvider).contains(widget.property.id);
    final imageCount = widget.property.imageUrls.length;

    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image carousel
          _buildCarousel(isDark, imageCount),

          // Bottom gradient scrim — IgnorePointer pra não roubar o swipe
          // do PageView do carrossel atrás.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, bg.withValues(alpha: 0.95)],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Top bar: back + favorite + share
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    _glassBtn(Icons.arrow_back_rounded, () => Navigator.of(context).pop(), isDark, mutedColor),
                    const Spacer(),
                    _glassBtn(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.property.id),
                      isDark,
                      isFavorite ? Colors.redAccent : mutedColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _glassBtn(Icons.share_outlined, () {}, isDark, mutedColor),
                  ],
                ),
              ),
            ),
          ),

          // Bottom row: page indicator + photo counter
          Positioned(
            bottom: AppSpacing.xl,
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            child: Row(
              children: [
                // Page dots
                if (imageCount > 1)
                  Row(
                    children: List.generate(imageCount, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 16 : 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: isActive
                              ? accentColor
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: AppRadius.borderFull,
                        ),
                      );
                    }),
                  ),

                const Spacer(),

                // Photo counter pill — tap opens gallery
                if (imageCount > 0)
                  GestureDetector(
                    onTap: widget.onPhotosTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.borderFull,
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        '${_currentPage + 1} / $imageCount',
                        style: AppTypography.bodySmall.copyWith(color: mutedColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Badges (bottom-left, above the indicator row)
          if (widget.property.badges.isNotEmpty)
            Positioned(
              bottom: AppSpacing.xl + 28,
              left: AppSpacing.screenHorizontal,
              child: Row(
                children: widget.property.badges.map((badge) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _badge(badge, accentColor),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarousel(bool isDark, int imageCount) {
    if (imageCount == 0) {
      return ColoredBox(
        color: BrutalistPalette.imagePlaceholderBg(isDark),
        child: Center(
          child: Icon(
            IconData(widget.property.thumbnailIconCode, fontFamily: 'MaterialIcons'),
            size: 64,
            color: (isDark ? Colors.white : BrutalistPalette.warmBrown).withValues(alpha: 0.08),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: imageCount,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (_, i) => GestureDetector(
        onTap: widget.onPhotosTap,
        child: Image.network(
          widget.property.imageUrls[i],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            if (kDebugMode) {
              debugPrint(
                '[property-header] falha ao carregar '
                '${widget.property.imageUrls[i]} — $error',
              );
            }
            return ColoredBox(
              color: BrutalistPalette.imagePlaceholderBg(isDark),
              child: Center(
                child: Icon(
                  IconData(widget.property.thumbnailIconCode,
                      fontFamily: 'MaterialIcons'),
                  size: 64,
                  color: (isDark ? Colors.white : BrutalistPalette.warmBrown)
                      .withValues(alpha: 0.08),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap, bool isDark, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BrutalistPalette.overlayPillBg(isDark),
          borderRadius: AppRadius.borderMd,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        label,
        style: AppTypography.bodySmallBold.copyWith(color: color),
      ),
    );
  }
}
