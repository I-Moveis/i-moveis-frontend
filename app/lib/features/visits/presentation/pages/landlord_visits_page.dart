import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/visit.dart';
import '../providers/landlord_visits_notifier.dart';
import '../widgets/visit_calendar_view.dart';

/// Smart agenda do landlord: calendário mensal das visitas agendadas nos
/// imóveis dele, com dots nos dias que têm visita e lista filtrada pelo dia
/// selecionado. Read-only — não dá pra cancelar/editar daqui.
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
              // Sempre mostra o calendário. Quando a lista vem vazia, o
              // grid segue visível (sem dots) e a _DayList interna mostra
              // "Nenhuma visita para este dia" — assim o landlord já se
              // familiariza com a agenda antes de ter dados.
              data: (visits) => Column(
                children: [
                  if (visits.isEmpty)
                    _EmptyBanner(
                      isDark: isDark,
                      icon: Icons.event_busy_outlined,
                      message:
                          'Nenhuma visita agendada nos seus imóveis ainda.',
                    ),
                  Expanded(
                    child: VisitCalendarView(
                      visits: visits,
                      onRefresh: () => ref
                          .read(landlordVisitsNotifierProvider.notifier)
                          .refresh(),
                      tileBuilder: (_, visit) =>
                          _LandlordVisitTile(visit: visit, isDark: isDark),
                    ),
                  ),
                ],
              ),
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
                  _formatTime(visit.scheduledAt),
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

  // O dia já aparece no header da _DayList; aqui só o horário.
  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

/// Banner slim acima do calendário quando não há nenhuma visita ainda.
/// Não ocupa a tela toda — o calendário continua visível embaixo.
class _EmptyBanner extends StatelessWidget {
  const _EmptyBanner({
    required this.isDark,
    required this.icon,
    required this.message,
  });
  final bool isDark;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: mutedColor, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: mutedColor),
            ),
          ),
        ],
      ),
    );
  }
}
