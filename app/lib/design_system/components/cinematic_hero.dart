import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/effects/cosmic_background.dart';

/// Cinematic hero section.
///
/// Full-screen impact area inspired by:
/// - lqve.jp "WE ARE MOST RADICAL CREATIVE COMPANY" hero
/// - Midnight Grand Orchestra cosmic key visuals
/// - UNDER VOYAGER immersive narrative opening
///
/// Combines starfield + gradient mesh + noise for depth.
class CinematicHero extends StatelessWidget {
  const CinematicHero({
    required this.title, super.key,
    this.subtitle,
    this.sectionLabel,
    this.height,
    this.showStars = true,
    this.gradient,
    this.child,
  });

  final String title;
  final String? subtitle;
  final String? sectionLabel;
  final double? height;
  final bool showStars;
  final Gradient? gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height ?? MediaQuery.of(context).size.height * 0.55,
      child: Stack(
        children: [
          // Background
          if (showStars)
            const Positioned.fill(
              child: CosmicBackground(starCount: 60),
            )
          else if (gradient != null)
            Positioned.fill(
              child: Container(decoration: BoxDecoration(gradient: gradient)),
            ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section marker (PUNCH / obake.blue style)
                  if (sectionLabel != null) ...[
                    Text(
                      sectionLabel!.toUpperCase(),
                      style: AppTypography.sectionMarker.copyWith(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Hero title with dramatic sizing
                  Text(
                    title,
                    style: AppTypography.displayHero.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),

                  // Subtitle
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],

                  // Custom child content
                  if (child != null) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    child!,
                  ],

                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
