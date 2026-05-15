import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../property/presentation/providers/property_detail_provider.dart';
import '../../domain/entities/visit.dart';
import '../providers/my_visits_notifier.dart';
import '../widgets/visit_calendar_view.dart';

/// Smart agenda do inquilino: grid mensal de calendário com dots nos dias
/// que têm visita e lista filtrada pelo dia selecionado abaixo. Delega
/// loading/error/empty pra estados locais e o `VisitCalendarView` pra UI
/// do calendário + dia.
class MyVisitsPage extends ConsumerWidget {
  const MyVisitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final async = ref.watch(myVisitsNotifierProvider);
        return Column(children: [
          const BrutalistAppBar(title: 'Minhas visitas'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => _ErrorView(
                message: e is Failure
                    ? e.message
                    : 'Não foi possível carregar suas visitas.',
                onRetry: () =>
                    ref.read(myVisitsNotifierProvider.notifier).refresh(),
                isDark: isDark,
              ),
              // Sempre mostra o calendário. Lista vazia → grid segue
              // visível (sem dots); a _DayList interna mostra "Nenhuma
              // visita para este dia" em cada seleção. Um banner slim em
              // cima comunica que ainda não tem visita marcada.
              data: (visits) => Column(
                children: [
                  if (visits.isEmpty)
                    _EmptyBanner(
                      isDark: isDark,
                      icon: Icons.event_available_outlined,
                      message: 'Você ainda não agendou nenhuma visita.',
                    ),
                  Expanded(
                    child: VisitCalendarView(
                      visits: visits,
                      onRefresh: () => ref
                          .read(myVisitsNotifierProvider.notifier)
                          .refresh(),
                      tileBuilder: (ctx, visit) => _VisitTile(
                        visit: visit,
                        isDark: isDark,
                        onTap: () =>
                            context.push('/profile/my-visits/${visit.id}'),
                      ),
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

class _VisitTile extends ConsumerWidget {
  const _VisitTile({
    required this.visit,
    required this.isDark,
    required this.onTap,
  });
  final Visit visit;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    // Resolve título do imóvel (e nome do landlord, quando o backend
    // expõe na Property) via cache do `propertyDetailProvider`. Carrega
    // sob demanda — o family deduplica entre tiles que apontam para o
    // mesmo imóvel.
    final propertyAsync =
        ref.watch(propertyDetailProvider(visit.propertyId));
    final propertyTitle = propertyAsync.maybeWhen(
      data: (p) => p.title.isNotEmpty ? p.title : 'Imóvel',
      orElse: () => 'Imóvel',
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: mutedColor),
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
                    propertyTitle,
                    style: AppTypography.bodyMedium.copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    visit.status.label,
                    style:
                        AppTypography.bodySmall.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: mutedColor),
          ],
        ),
      ),
    );
  }

  // No tile, o dia já está no header da _DayList — mostra só o horário.
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: mutedColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            BrutalistGradientButton(
              label: 'TENTAR NOVAMENTE',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
