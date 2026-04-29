import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/design_system.dart';
import '../../../search/presentation/providers/map_providers.dart';
import 'featured_section.dart';

const kNearbyProperties = [
  PropertyData(
    id: '4',
    title: 'Apê Moderno',
    location: 'Moema, SP',
    price: r'R$ 2.800',
    area: '65m²',
    beds: 2,
  ),
  PropertyData(
    id: '5',
    title: 'Casa com Jardim',
    location: 'Brooklin, SP',
    price: r'R$ 5.500',
    area: '220m²',
    beds: 4,
  ),
  PropertyData(
    id: '6',
    title: 'Kitnet Compacta',
    location: 'Consolação, SP',
    price: r'R$ 1.200',
    area: '28m²',
    beds: 1,
  ),
];

class NearbySection extends ConsumerWidget {
  const NearbySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPosition = ref.watch(userPositionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Perto de você',
          action: userPosition != null ? 'Ver mapa' : null,
          onAction:
              userPosition != null ? () => context.push('/search/map') : null,
        ),
        if (userPosition == null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenHorizontal,
              bottom: AppSpacing.md,
            ),
            child: Text(
              'Ative a localização para ver imóveis próximos',
              style: AppTypography.bodySmall.copyWith(
                color: BrutalistPalette.muted(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            itemCount: kNearbyProperties.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: _NearbyCard(property: kNearbyProperties[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.property});
  final PropertyData property;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor =
        isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: AppTypography.titleLargeBold
                      .copyWith(color: titleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  property.location,
                  style:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${property.price}/mês',
                  style: AppTypography.titleSmallAccent
                      .copyWith(color: accentColor),
                ),
                AppStatRow(
                  icon: Icons.straighten_rounded,
                  value: property.area,
                  color: mutedColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
