import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/tokens/app_durations.dart';

/// Numbered project list item.
///
/// The p5aholic.me project page: clean rows with index number,
/// project name, role, date, and collaborator. No images needed.
/// The typography does all the work.
class ProjectListItem extends StatefulWidget {
  const ProjectListItem({
    required this.index, required this.title, super.key,
    this.role,
    this.date,
    this.collaborator,
    this.onTap,
    this.showDivider = true,
  });

  final int index;
  final String title;
  final String? role;
  final String? date;
  final String? collaborator;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  State<ProjectListItem> createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<ProjectListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indexStr = widget.index.toString().padLeft(2, '0');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              color: _isHovered
                  ? (isDark ? AppColors.blackLight : AppColors.lightElevated)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Index number
                  SizedBox(
                    width: 36,
                    child: Text(
                      indexStr,
                      style: AppTypography.monoSmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        AnimatedDefaultTextStyle(
                          duration: AppDurations.fast,
                          style: AppTypography.headlineMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          child: Text(widget.title),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Metadata row
                        Row(
                          children: [
                            if (widget.role != null) ...[
                              Text(
                                widget.role!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                            if (widget.role != null && widget.date != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Text(
                                  '●',
                                  style: TextStyle(
                                    fontSize: 4,
                                    color: isDark
                                        ? AppColors.darkTextDisabled
                                        : AppColors.lightTextDisabled,
                                  ),
                                ),
                              ),
                            if (widget.date != null)
                              Text(
                                widget.date!,
                                style: AppTypography.monoSmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                          ],
                        ),

                        // Collaborator
                        if (widget.collaborator != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'w/ ${widget.collaborator}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextDisabled
                                  : AppColors.lightTextDisabled,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow
                  AnimatedOpacity(
                    duration: AppDurations.fast,
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            if (widget.showDivider)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                height: 1,
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
              ),
          ],
        ),
      ),
    );
  }
}
