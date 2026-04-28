import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../design_system/design_system.dart';

/// A Brutalist-styled shimmer loader that mimics the PropertyListTile structure.
class BrutalistShimmer extends StatelessWidget {
  const BrutalistShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        itemBuilder: (context, index) => const _ShimmerTile(),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg, // Keep it angular
        border: Border.all(width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      color: Colors.white,
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 100,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: List.generate(4, (index) => 
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: Container(width: 40, height: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
