import 'package:flutter/material.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import 'brutalist_page_scaffold.dart';

/// Inline app bar for sub-pages in the Brutalist Elegance design language.
///
/// Replaces Material AppBar with a glass-morphism back button,
/// optional title, and optional trailing action buttons.
/// Designed to sit inside the WaveBackground transparent scaffold.
class BrutalistAppBar extends StatelessWidget {
  const BrutalistAppBar({
    super.key,
    this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
  });

  /// Optional page title displayed center-left.
  final String? title;

  /// Back button callback. If null, uses `Navigator.of(context).pop()`.
  final VoidCallback? onBack;

  /// Optional trailing glass action buttons.
  final List<BrutalistAppBarAction>? actions;

  /// Whether to show the back button.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          if (showBack)
            _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack ?? () => Navigator.of(context).pop(),
            ),

          if (showBack && title != null)
            const SizedBox(width: AppSpacing.md),

          // Title
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTypography.headlineSmall.copyWith(
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),

          // Actions
          if (actions != null)
            for (int i = 0; i < actions!.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _GlassIconButton(
                icon: actions![i].icon,
                onTap: actions![i].onTap,
              ),
            ],
        ],
      ),
    );
  }
}

/// Action item for [BrutalistAppBar].
class BrutalistAppBarAction {
  const BrutalistAppBarAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;
}

/// Glass-morphism icon button matching the onboarding skip button style.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = BrutalistPalette.muted(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BrutalistPalette.glassBg(isDark),
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: BrutalistPalette.glassBorderColor(isDark),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

/// Glass-morphism text button for app bar actions (e.g. "SALVAR").
class BrutalistGlassTextButton extends StatelessWidget {
  const BrutalistGlassTextButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = BrutalistPalette.accentPeach(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: BrutalistPalette.glassBg(isDark),
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: BrutalistPalette.glassBorderColor(isDark),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: textColor,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}
