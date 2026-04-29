import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/visit.dart';
import '../providers/landlord_visits_notifier.dart';

/// Shows the visits scheduled on the current user's properties (landlord
/// perspective). Read-only — no cancel/edit from here.
class LandlordVisitsPage extends ConsumerWidget {
  const LandlordVisitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final async = ref.watch(landlordVisitsNotifierProvider);
        return Column(children: [
          const BrutalistAppBar(title: 'Visitas dos meus imóveis'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure
                        ? e.message
                        : 'Não foi possível carregar as visitas.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                        color: BrutalistPalette.title(isDark)),
                  ),
                ),
              ),
              data: (visits) {
                if (visits.isEmpty) {
                  return _EmptyView(isDark: isDark);
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(landlordVisitsNotifierProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: visits.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) =>
                        _LandlordVisitTile(visit: visits[i], isDark: isDark),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

class _LandlordVisitTile extends StatelessWidget {
  const _LandlordVisitTile({required this.visit, required this.isDark});
  final Visit visit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline_rounded, color: mutedColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(visit.scheduledAt),
                  style: AppTypography.titleSmallBold
                      .copyWith(color: titleColor),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Inquilino #${visit.tenantId} · ${visit.status.label}',
                  style:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Imóvel #${visit.propertyId}',
                  style:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day $month · $hh:$mm';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: mutedColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhuma visita agendada nos seus imóveis.',
              textAlign: TextAlign.center,
              style:
                  AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
