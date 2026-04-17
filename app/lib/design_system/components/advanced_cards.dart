import 'dart:math';

import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Advanced card components inspired by:
/// - LQVE: project showcase cards
/// - p5aholic: glassmorphic effects
/// - obake.blue: numbered portfolio grid
/// - Starpeggio/Overture: music release cards
/// - ILY GIRL: exhibition cards
/// - punchred.xyz: creator profiles

// ═══════════════════════════════════════════════════════════════
//  1. ProjectShowcaseCard — LQVE-style project card
// ═══════════════════════════════════════════════════════════════

class ProjectShowcaseCard extends StatefulWidget {
  const ProjectShowcaseCard({
    required this.index, required this.title, super.key,
    this.client,
    this.year,
    this.imageUrl,
    this.onTap,
    this.aspectRatio = 4 / 3,
  });

  final int index;
  final String title;
  final String? client;
  final String? year;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double aspectRatio;

  @override
  State<ProjectShowcaseCard> createState() => _ProjectShowcaseCardState();
}

class _ProjectShowcaseCardState extends State<ProjectShowcaseCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          scale: _hovering ? 1.02 : 1.0,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightElevated,
                borderRadius: AppRadius.borderMd,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image placeholder
                  ColoredBox(
                    color: isDark
                        ? AppColors.blackLighter
                        : AppColors.lightBorderSubtle,
                    child: widget.imageUrl != null
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _placeholder(isDark),
                          )
                        : _placeholder(isDark),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Number
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: Text(
                      widget.index.toString().padLeft(2, '0'),
                      style: AppTypography.monoLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),

                  // Info
                  Positioned(
                    bottom: AppSpacing.lg,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.client != null || widget.year != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              if (widget.client != null)
                                Text(
                                  widget.client!,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              if (widget.client != null && widget.year != null)
                                Text(
                                  '  /  ',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              if (widget.year != null)
                                Text(
                                  widget.year!,
                                  style: AppTypography.monoSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Hover arrow
                  Positioned(
                    top: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovering ? 1.0 : 0.0,
                      child: Icon(
                        Icons.arrow_outward,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(bool isDark) {
    return Center(
      child: Text(
        widget.index.toString().padLeft(2, '0'),
        style: AppTypography.displayMassive.copyWith(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  2. GlassmorphicCard — p5aholic glass effect
// ═══════════════════════════════════════════════════════════════

class GlassmorphicCard extends StatelessWidget {
  const GlassmorphicCard({
    required this.child, super.key,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.blur = 12.0,
    this.opacity = 0.08,
    this.borderOpacity = 0.12,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.borderLg;
    final baseColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: opacity),
          borderRadius: radius,
          border: Border.all(
            color: baseColor.withValues(alpha: borderOpacity),
          ),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  3. PortfolioGridCard — obake.blue numbered grid item
// ═══════════════════════════════════════════════════════════════

class PortfolioGridCard extends StatefulWidget {
  const PortfolioGridCard({
    required this.index, required this.title, super.key,
    this.date,
    this.category,
    this.imageUrls = const [],
    this.onTap,
  });

  final int index;
  final String title;
  final String? date;
  final String? category;
  final List<String> imageUrls;
  final VoidCallback? onTap;

  @override
  State<PortfolioGridCard> createState() => _PortfolioGridCardState();
}

class _PortfolioGridCardState extends State<PortfolioGridCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number + date row
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.index.toString().padLeft(2, '0'),
                    style: AppTypography.monoIndex.copyWith(
                      color: isDark
                          ? AppColors.whiteFaint
                          : AppColors.lightTextDisabled,
                    ),
                  ),
                  if (widget.date != null)
                    Text(
                      widget.date!,
                      style: AppTypography.monoSmall.copyWith(
                        color: isDark
                            ? AppColors.whiteMuted
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                ],
              ),
            ),

            // Image area
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              scale: _hovering ? 1.03 : 1.0,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.blackLighter
                        : AppColors.lightBorderSubtle,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: widget.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(isDark),
                        )
                      : _imagePlaceholder(isDark),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              widget.title,
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (widget.category != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                widget.category!,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.whiteMuted
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  4. MusicReleaseCard — Starpeggio/Overture style
// ═══════════════════════════════════════════════════════════════

class MusicReleaseCard extends StatelessWidget {
  const MusicReleaseCard({
    required this.title, super.key,
    this.subtitle,
    this.price,
    this.edition,
    this.trackList = const [],
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? price;
  final String? edition;
  final List<String> trackList;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            Container(
              width: 120,
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? AppColors.blackLighter : AppColors.lightElevated,
                borderRadius: AppRadius.borderSm,
              ),
              child: imageUrl != null
                  ? Image.network(imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _artPlaceholder(isDark))
                  : _artPlaceholder(isDark),
            ),

            const SizedBox(width: AppSpacing.lg),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (edition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.whiteFaint.withValues(alpha: 0.1)
                            : AppColors.lightBorderSubtle,
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: Text(
                        edition!,
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.whiteMuted
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),

                  Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.whiteMuted
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],

                  if (price != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      price!,
                      style: AppTypography.monoIndex.copyWith(
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ],

                  if (trackList.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    for (int i = 0; i < min(trackList.length, 5); i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                '${i + 1}.',
                                style: AppTypography.monoSmall.copyWith(
                                  color: isDark
                                      ? AppColors.whiteFaint
                                      : AppColors.lightTextDisabled,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                trackList[i],
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.whiteDim
                                      : AppColors.lightTextSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _artPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.album_outlined,
        size: 40,
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  5. ExhibitionCard — ILY GIRL exhibition style
// ═══════════════════════════════════════════════════════════════

class ExhibitionCard extends StatelessWidget {
  const ExhibitionCard({
    required this.titleJp, required this.titleEn, super.key,
    this.dateRange,
    this.venue,
    this.imageUrl,
    this.accentColor = AppColors.pastelPink,
    this.onTap,
  });

  final String titleJp;
  final String titleEn;
  final String? dateRange;
  final String? venue;
  final String? imageUrl;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: isDark ? AppColors.blackLighter : AppColors.lightElevated,
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container())
                    : Center(
                        child: Text(
                          titleEn.substring(0, min(2, titleEn.length)),
                          style: AppTypography.displayMassive.copyWith(
                            color: accentColor.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
              ),
            ),

            // Content
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent bar
                  Container(
                    width: 40,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),

                  // JP title
                  Text(
                    titleJp,
                    style: AppTypography.headlineLarge.copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // EN title
                  Text(
                    titleEn,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.whiteMuted
                          : AppColors.lightTextTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  if (dateRange != null || venue != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        if (dateRange != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: isDark
                                    ? AppColors.whiteMuted
                                    : AppColors.lightTextTertiary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                dateRange!,
                                style: AppTypography.monoSmall.copyWith(
                                  color: isDark
                                      ? AppColors.whiteMuted
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        if (dateRange != null && venue != null)
                          const SizedBox(width: AppSpacing.lg),
                        if (venue != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 12,
                                color: isDark
                                    ? AppColors.whiteMuted
                                    : AppColors.lightTextTertiary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                venue!,
                                style: AppTypography.monoSmall.copyWith(
                                  color: isDark
                                      ? AppColors.whiteMuted
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  6. CreatorProfileCard — punchred.xyz style
// ═══════════════════════════════════════════════════════════════

class CreatorProfileCard extends StatefulWidget {
  const CreatorProfileCard({
    required this.name, super.key,
    this.role,
    this.bio,
    this.socialLinks = const [],
    this.thumbnails = const [],
    this.onTap,
  });

  final String name;
  final String? role;
  final String? bio;
  final List<CreatorSocialLink> socialLinks;
  final List<String> thumbnails;
  final VoidCallback? onTap;

  @override
  State<CreatorProfileCard> createState() => _CreatorProfileCardState();
}

class _CreatorProfileCardState extends State<CreatorProfileCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: _hovering
                  ? (isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled)
                  : (isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name — massive
              Text(
                widget.name,
                style: AppTypography.displayLarge.copyWith(
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),

              if (widget.role != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.role!,
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.whiteMuted
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],

              if (widget.bio != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.bio!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.whiteDim
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],

              // Social links
              if (widget.socialLinks.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    for (int i = 0; i < widget.socialLinks.length; i++) ...[
                      Text(
                        '${widget.socialLinks[i].label} ↗',
                        style: AppTypography.monoSmall.copyWith(
                          color: isDark
                              ? AppColors.whiteMuted
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                      if (i < widget.socialLinks.length - 1)
                        const SizedBox(width: AppSpacing.lg),
                    ],
                  ],
                ),
              ],

              // Thumbnail strip
              if (widget.thumbnails.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.thumbnails.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, i) => Container(
                      width: 48,
                      height: 48,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.borderXs,
                        color: isDark
                            ? AppColors.blackLighter
                            : AppColors.lightElevated,
                      ),
                      child: Image.network(
                        widget.thumbnails[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CreatorSocialLink {
  const CreatorSocialLink({required this.label, required this.url});
  final String label;
  final String url;
}
