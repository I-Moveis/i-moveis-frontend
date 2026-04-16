import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/seed_color_provider.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import 'brutalist_page_scaffold.dart';

/// Step state for [BrutalistStepper].
enum BrutalistStepState { pending, active, completed }

/// Data for a single step in [BrutalistStepper].
class BrutalistStepData {
  const BrutalistStepData({
    required this.label,
    this.state = BrutalistStepState.pending,
  });

  final String label;
  final BrutalistStepState state;
}

/// Custom stepper matching the Brutalist Elegance design language.
class BrutalistStepper extends ConsumerWidget {
  const BrutalistStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
  });

  final List<BrutalistStepData> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final accentAmber = palette.accentAmber(isDark);
    final accentOrange = palette.accentOrange(isDark);
    final titleColor = palette.title(isDark);
    final mutedColor = palette.muted(isDark);
    final faintColor = palette.faint(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildStep(
            index: i,
            step: steps[i],
            isLast: i == steps.length - 1,
            isDark: isDark,
            accentAmber: accentAmber,
            accentOrange: accentOrange,
            titleColor: titleColor,
            mutedColor: mutedColor,
            faintColor: faintColor,
          ),
        ],
      ],
    );
  }

  Widget _buildStep({
    required int index,
    required BrutalistStepData step,
    required bool isLast,
    required bool isDark,
    required Color accentAmber,
    required Color accentOrange,
    required Color titleColor,
    required Color mutedColor,
    required Color faintColor,
  }) {
    final isActive = step.state == BrutalistStepState.active;
    final isCompleted = step.state == BrutalistStepState.completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator column (number + line)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Step circle / number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? accentAmber.withValues(alpha: 0.15)
                        : isActive
                            ? accentOrange.withValues(alpha: 0.12)
                            : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? accentAmber.withValues(alpha: 0.5)
                          : isActive
                              ? accentOrange.withValues(alpha: 0.6)
                              : faintColor.withValues(alpha: 0.3),
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: accentAmber,
                          )
                        : Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: AppTypography.monoSmall.copyWith(
                              color: isActive
                                  ? accentOrange
                                  : faintColor,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                  ),
                ),

                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      color: isCompleted
                          ? accentAmber.withValues(alpha: 0.4)
                          : faintColor.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Step content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.xl,
              ),
              child: Text(
                step.label,
                style: AppTypography.labelMedium.copyWith(
                  color: isActive
                      ? titleColor
                      : isCompleted
                          ? mutedColor
                          : faintColor,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal progress bar for multi-step flows (e.g. create listing).
class BrutalistProgressBar extends ConsumerWidget {
  const BrutalistProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final accentAmber = palette.accentAmber(isDark);
    final trackColor = palette.faint(isDark).withValues(alpha: 0.15);
    final progress = totalSteps > 0 ? (currentStep + 1) / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step counter
        Text(
          'ETAPA ${(currentStep + 1).toString().padLeft(2, '0')} / ${totalSteps.toString().padLeft(2, '0')}',
          style: AppTypography.monoSmall.copyWith(
            color: accentAmber.withValues(alpha: 0.6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Progress track
        ClipRRect(
          borderRadius: AppRadius.borderFull,
          child: SizedBox(
            height: 2,
            child: Stack(
              children: [
                // Track
                Container(color: trackColor),
                // Fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentAmber,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
