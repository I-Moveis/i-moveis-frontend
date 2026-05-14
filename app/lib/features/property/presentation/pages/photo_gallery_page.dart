import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../design_system/design_system.dart';
import '../providers/property_detail_provider.dart';

/// Fullscreen photo gallery with zoom/swipe via photo_view.
class PhotoGalleryPage extends ConsumerStatefulWidget {
  const PhotoGalleryPage({
    required this.propertyId,
    this.initialIndex = 0,
    super.key,
  });

  final String propertyId;
  final int initialIndex;

  @override
  ConsumerState<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends ConsumerState<PhotoGalleryPage> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: AppColors.black,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.whiteMuted),
        ),
        error: (_, __) => Center(
          child: Text(
            'Não foi possível carregar as fotos.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.whiteMuted),
          ),
        ),
        data: (property) {
          final urls = property.imageUrls;

          if (urls.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma foto disponível.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.whiteMuted),
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                // ── Gallery ───────────────────────────────────────────
                PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: urls.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  backgroundDecoration: const BoxDecoration(color: AppColors.black),
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(urls[index]),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          IconData(
                            property.thumbnailIconCode,
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 64,
                          color: AppColors.whiteFaint,
                        ),
                      ),
                    );
                  },
                ),

                // ── Top bar ───────────────────────────────────────────
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.screenHorizontal,
                  right: AppSpacing.screenHorizontal,
                  child: Row(
                    children: [
                      _GlassButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        '${(_currentPage + 1).toString().padLeft(2, '0')} / ${urls.length.toString().padLeft(2, '0')}',
                        style: AppTypography.monoSmallWide.copyWith(
                          color: AppColors.whiteMuted,
                        ),
                      ),
                      const Spacer(),
                      _GlassButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // ── Bottom indicators ─────────────────────────────────
                Positioned(
                  bottom: AppSpacing.xxl,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(urls.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: AppDurations.medium,
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        width: isActive ? 24 : 6,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderFull,
                          color: isActive
                              ? BrutalistPalette.warmAmber
                              : AppColors.whiteFaint.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BrutalistPalette.surfaceBg(true),
          borderRadius: AppRadius.borderSm,
          border: Border.all(color: BrutalistPalette.surfaceBorder(true)),
        ),
        child: Icon(icon, size: 18, color: AppColors.whiteMuted),
      ),
    );
  }
}
