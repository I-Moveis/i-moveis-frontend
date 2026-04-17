import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_shadows.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_durations.dart';

/// Standard card with border and optional elevation.
/// Inspired by McShannock's clean flat cards.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child, super.key,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.borderLg;

    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: radius,
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
        ),
        boxShadow: isDark ? null : AppShadows.lightSm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Image card with overlay text. Airbnb-style listing card.
class AppImageCard extends StatelessWidget {
  const AppImageCard({
    required this.title, super.key,
    this.imageUrl,
    this.placeholderColor,
    this.subtitle,
    this.badge,
    this.onTap,
    this.aspectRatio = 4 / 3,
    this.borderRadius,
  });

  final String? imageUrl;
  final Color? placeholderColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.borderXl;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: placeholderColor ??
                    (isDark ? AppColors.darkElevated : AppColors.lightBorderSubtle),
                borderRadius: radius,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (badge != null)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Glassmorphism card. Magic Receipt style frosted glass effect.
class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    required this.child, super.key,
    this.padding,
    this.blur = 16,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.borderLg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.glassGradient,
          borderRadius: radius,
          border: Border.all(
            color: AppColors.overlayLight,
          ),
        ),
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

/// Gradient accent card with neon glow.
class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    required this.child, super.key,
    this.gradient,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.auroraGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXl,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
            child: child,
          ),
        ),
      ),
    );
  }
}
