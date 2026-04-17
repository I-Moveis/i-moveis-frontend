import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_radius.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../../design_system/tokens/app_typography.dart';

/// Helper to show a design-system styled bottom sheet.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  double? maxHeight,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadius.sheetTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: builder(context)),
            ],
          ),
        ),
      );
    },
  );
}

/// Bottom sheet header with title and optional close button.
class AppBottomSheetHeader extends StatelessWidget {
  const AppBottomSheetHeader({
    required this.title, super.key,
    this.showClose = true,
    this.trailing,
  });

  final String title;
  final bool showClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (showClose)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close_rounded,
                size: 24,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          if (showClose) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: showClose ? TextAlign.start : TextAlign.center,
            ),
          ),
          if (trailing != null) ...[trailing!],
        ],
      ),
    );
  }
}
