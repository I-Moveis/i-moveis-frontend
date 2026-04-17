import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Photo gallery — Brutalist Elegance immersive fullscreen carousel
/// with black background, glass controls, and pill indicators.
class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPhotos = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Photo carousel
            PageView.builder(
              controller: _pageController,
              itemCount: _totalPhotos,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) {
                return Center(
                  child: Text(
                    (i + 1).toString().padLeft(2, '0'),
                    style: AppTypography.monoGiant.copyWith(
                      color: BrutalistPalette.surfaceBg(true),
                    ),
                  ),
                );
              },
            ),

            // Top bar
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              child: Row(
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrutalistPalette.surfaceBg(true),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: BrutalistPalette.surfaceBorder(true),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AppColors.whiteMuted,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Counter
                  Text(
                    '${(_currentPage + 1).toString().padLeft(2, '0')} / ${_totalPhotos.toString().padLeft(2, '0')}',
                    style: AppTypography.monoSmallWide.copyWith(
                      color: AppColors.whiteMuted,
                    ),
                  ),

                  const Spacer(),

                  // Close
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrutalistPalette.surfaceBg(true),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: BrutalistPalette.surfaceBorder(true),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.whiteMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom indicators
            Positioned(
              bottom: AppSpacing.xxl,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPhotos, (i) {
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
      ),
    );
  }
}
