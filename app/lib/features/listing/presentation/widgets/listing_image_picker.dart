import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/design_system.dart';

/// Widget for picking multiple images and selecting one as the cover.
class ListingImagePicker extends StatefulWidget {
  const ListingImagePicker({
    required this.onImagesChanged,
    required this.onCoverChanged,
    super.key,
  });

  final ValueChanged<List<XFile>> onImagesChanged;
  final ValueChanged<int> onCoverChanged;

  @override
  State<ListingImagePicker> createState() => _ListingImagePickerState();
}

class _ListingImagePickerState extends State<ListingImagePicker> {
  final List<XFile> _images = [];
  int _coverIndex = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
        widget.onImagesChanged(_images);
      }
    } on Exception catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_coverIndex >= _images.length) {
        _coverIndex = math.max(0, _images.length - 1);
      }
    });
    widget.onImagesChanged(_images);
    widget.onCoverChanged(_coverIndex);
  }

  void _setCover(int index) {
    setState(() {
      _coverIndex = index;
    });
    widget.onCoverChanged(_coverIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_images.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: BrutalistPalette.muted(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Adicionar fotos', style: AppTypography.titleSmall.copyWith(color: BrutalistPalette.muted(isDark))),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(Icons.add, color: BrutalistPalette.muted(isDark)),
                    ),
                  );
                }

                final file = _images[index];
                final isCover = _coverIndex == index;

                return GestureDetector(
                  onTap: () => _setCover(index),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(
                            color: isCover ? accentColor : borderColor,
                            width: isCover ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadius.borderLg,
                          child: kIsWeb
                              ? Image.network(file.path, fit: BoxFit.cover)
                              : Image.file(File(file.path), fit: BoxFit.cover),
                        ),
                      ),
                      if (isCover)
                        Positioned(
                          bottom: -6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(),
                              ),
                              child: Text(
                                'CAPA',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(),
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (_images.isNotEmpty)
          Text(
            'Toque na imagem para definir como capa',
            style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark)),
          ),
      ],
    );
  }
}
