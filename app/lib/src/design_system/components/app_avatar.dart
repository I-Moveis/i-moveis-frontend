import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

/// User avatar with image, initials, or icon fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
  });

  final String? imageUrl;
  final String? initials;
  final AppAvatarSize size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;

  double get _size => switch (size) {
        AppAvatarSize.xs => 28,
        AppAvatarSize.sm => 36,
        AppAvatarSize.md => 44,
        AppAvatarSize.lg => 56,
        AppAvatarSize.xl => 72,
      };

  double get _fontSize => switch (size) {
        AppAvatarSize.xs => 11,
        AppAvatarSize.sm => 13,
        AppAvatarSize.md => 16,
        AppAvatarSize.lg => 20,
        AppAvatarSize.xl => 26,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark ? AppColors.darkElevated : AppColors.lightBorderSubtle),
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: imageUrl == null
                ? Center(
                    child: initials != null
                        ? Text(
                            initials!,
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: _size * 0.5,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                  )
                : null,
          ),
          if (showBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _size * 0.3,
                height: _size * 0.3,
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
