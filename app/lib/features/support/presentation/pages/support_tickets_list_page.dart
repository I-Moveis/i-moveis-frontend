import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/support_ticket.dart';
import '../providers/support_tickets_notifier.dart';

/// Lista de chamados de suporte abertos pelo usuário. Ponto de entrada
/// do fluxo `/support` — vem do menu "Suporte" no perfil.
///
/// CTA principal em "Novo chamado" (topo) que leva para `/support/new`
/// (o formulário). Cada card da lista leva para `/support/:code` com o
/// detalhe do chamado.
///
/// Visual inspirado em `ConversationsPage` pra manter coesão com o que
/// o usuário conhece como "threads de conversa".
class SupportTicketsListPage extends ConsumerWidget {
  const SupportTicketsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(supportTicketsProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Suporte'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, _) => _ListView(
                tickets: const [],
                isDark: isDark,
                onRefresh: () =>
                    ref.read(supportTicketsProvider.notifier).refresh(),
              ),
              data: (tickets) => _ListView(
                tickets: tickets,
                isDark: isDark,
                onRefresh: () =>
                    ref.read(supportTicketsProvider.notifier).refresh(),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.tickets,
    required this.isDark,
    required this.onRefresh,
  });

  final List<SupportTicket> tickets;
  final bool isDark;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          _NewTicketCta(isDark: isDark),
          const SizedBox(height: AppSpacing.xxl),
          if (tickets.isEmpty)
            _EmptyState(isDark: isDark)
          else
            for (final t in tickets) ...[
              _TicketCard(ticket: t, isDark: isDark),
              const SizedBox(height: AppSpacing.md),
            ],
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }
}

class _NewTicketCta extends StatelessWidget {
  const _NewTicketCta({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    return GestureDetector(
      onTap: () => context.push('/support/new'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_comment_rounded, size: 20, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Abrir novo chamado',
              style: AppTypography.titleSmallBold.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.isDark});

  final SupportTicket ticket;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);

    return GestureDetector(
      onTap: () => context.push('/support/${ticket.code}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            _StatusDot(status: ticket.status, isDark: isDark),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title.isEmpty ? '(sem título)' : ticket.title,
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    ticket.description,
                    style:
                        AppTypography.bodySmall.copyWith(color: muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        ticket.code,
                        style: AppTypography.monoSmallWide
                            .copyWith(color: muted, fontSize: 10),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('·',
                          style: AppTypography.bodySmall.copyWith(
                              color: muted.withValues(alpha: 0.5))),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: AppTypography.bodySmall
                            .copyWith(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final sameDay = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    if (sameDay) return 'Hoje $hh:$mm';
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$dd/$mo $hh:$mm';
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, required this.isDark});
  final SupportTicketStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case SupportTicketStatus.resolved:
        color = AppColors.success;
      case SupportTicketStatus.awaitingUser:
        color = AppColors.warning;
      case SupportTicketStatus.open:
        color = BrutalistPalette.accentOrange(isDark);
    }
    return Tooltip(
      message: status.label,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = BrutalistPalette.muted(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(Icons.support_agent_outlined,
              size: 64, color: muted.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nenhum chamado por aqui',
            style: AppTypography.titleMedium.copyWith(color: muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Quando você abrir um novo chamado, ele aparece nesta lista.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
