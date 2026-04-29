import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';

class OwnerCard extends StatelessWidget {
  const OwnerCard({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proprietário', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.blackLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.blackLightest),
          ),
          child: Row(
            children: [
              _Avatar(name: property.ownerName),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.ownerName.isNotEmpty ? property.ownerName : 'Proprietário',
                      style: AppTypography.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (property.ownerMemberSince.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        property.ownerMemberSince,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.whiteMuted),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    const _StarRating(rating: 4.8),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MessageButton(ownerName: property.ownerName),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.first.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.blackLighter,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.blackLightest, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTypography.titleMediumBold.copyWith(color: AppColors.white),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star_rounded
                : (i == fullStars && hasHalf)
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: 14,
            color: AppColors.whiteDim,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.bodySmall.copyWith(color: AppColors.whiteMuted),
        ),
      ],
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.ownerName});

  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
      label: const Text('Mensagem'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.blackLightest),
        textStyle: AppTypography.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
