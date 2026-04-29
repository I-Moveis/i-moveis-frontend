import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_status.dart';
import '../providers/my_visits_notifier.dart';
import '../providers/visit_detail_provider.dart';

class VisitDetailPage extends ConsumerWidget {
  const VisitDetailPage({required this.visitId, super.key});
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final async = ref.watch(visitDetailProvider(visitId));
        return Column(children: [
          const BrutalistAppBar(title: 'Detalhe da visita'),
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
                        : 'Não foi possível carregar a visita.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                        color: BrutalistPalette.title(isDark)),
                  ),
                ),
              ),
              data: (visit) => _DetailBody(visit: visit, isDark: isDark),
            ),
          ),
        ]);
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.visit, required this.isDark});
  final Visit visit;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    final canMutate = visit.status == VisitStatus.scheduled;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Quando',
            value: _formatDateTime(visit.scheduledAt),
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Duração',
            value: '${visit.durationMinutes} minutos',
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Status',
            value: visit.status.label,
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Imóvel',
            value: visit.propertyId,
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            mutedColor: mutedColor,
          ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Observações',
              value: visit.notes!,
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              mutedColor: mutedColor,
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          if (canMutate) ...[
            BrutalistGradientButton(
              label: 'REAGENDAR',
              icon: Icons.edit_calendar_rounded,
              onTap: () => context.push(
                  '/profile/my-visits/${visit.id}/edit'),
            ),
            const SizedBox(height: AppSpacing.md),
            _CancelButton(visit: visit, isDark: isDark),
          ],
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year · $hh:$mm';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });
  final String label;
  final String value;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: mutedColor)),
          const SizedBox(height: AppSpacing.xxs),
          Text(value,
              style: AppTypography.titleSmall.copyWith(color: titleColor)),
        ],
      ),
    );
  }
}

class _CancelButton extends ConsumerStatefulWidget {
  const _CancelButton({required this.visit, required this.isDark});
  final Visit visit;
  final bool isDark;

  @override
  ConsumerState<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends ConsumerState<_CancelButton> {
  bool _busy = false;

  Future<void> _confirm() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar visita?'),
        content: const Text(
            'Esta ação não pode ser desfeita. Deseja prosseguir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar visita'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(myVisitsNotifierProvider.notifier)
          .cancel(widget.visit.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Visita cancelada.')),
      );
      router.pop();
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _confirm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: AppRadius.borderLg,
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Text(
            _busy ? 'Cancelando...' : 'Cancelar visita',
            style: AppTypography.titleSmallBold
                .copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
