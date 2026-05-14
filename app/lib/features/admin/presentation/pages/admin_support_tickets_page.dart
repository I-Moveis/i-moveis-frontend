import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../support/domain/entities/support_ticket.dart';
import '../providers/admin_support_tickets_notifier.dart';

class AdminSupportTicketsPage extends ConsumerWidget {
  const AdminSupportTicketsPage({super.key});

  static const _filters = [
    ('OPEN', 'Abertos'),
    ('IN_PROGRESS', 'Em andamento'),
    ('RESOLVED', 'Resolvidos'),
    ('CLOSED', 'Fechados'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        final async = ref.watch(adminSupportTicketsProvider);
        final notifier = ref.read(adminSupportTicketsProvider.notifier);
        final currentFilter = notifier.statusFilter;

        return Column(children: [
          const BrutalistAppBar(title: 'Tickets de Suporte'),

          // Filtros de status
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final (value, label) = _filters[i];
                final isActive = currentFilter == value;
                return GestureDetector(
                  onTap: () => notifier.setFilter(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isActive
                          ? accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                        color: isActive
                            ? accentColor.withValues(alpha: 0.5)
                            : BrutalistPalette.surfaceBorder(isDark),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: AppTypography.titleSmallBold.copyWith(
                        color: isActive ? accentColor : mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar tickets.',
                    style:
                        AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ),
              data: (tickets) => RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  children: [
                    // Contador
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        '${tickets.length} ticket${tickets.length != 1 ? 's' : ''}',
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor),
                      ),
                    ),
                    if (tickets.isEmpty)
                      _EmptyState(isDark: isDark)
                    else
                      for (final t in tickets) ...[
                        _TicketTile(ticket: t, isDark: isDark),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.isDark});

  final SupportTicket ticket;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);

    final statusColor = _statusColor(ticket.status);

    return GestureDetector(
      onTap: () => context.push('/admin/support/${ticket.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
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
                  style: AppTypography.bodySmall.copyWith(color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(children: [
                  Text(
                    ticket.code,
                    style: AppTypography.monoSmallWide
                        .copyWith(color: muted, fontSize: 10),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('·',
                      style: AppTypography.bodySmall
                          .copyWith(color: muted.withValues(alpha: 0.5))),
                  const SizedBox(width: AppSpacing.sm),
                  if (ticket.userRole != null) ...[
                    Text(
                      ticket.userRole!,
                      style: AppTypography.bodySmall
                          .copyWith(color: muted, fontSize: 10),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('·',
                        style: AppTypography.bodySmall.copyWith(
                            color: muted.withValues(alpha: 0.5))),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    _formatDate(ticket.createdAt),
                    style: AppTypography.bodySmall
                        .copyWith(color: muted, fontSize: 11),
                  ),
                ]),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: muted),
        ]),
      ),
    );
  }

  static Color _statusColor(SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.resolved:
        return AppColors.success;
      case SupportTicketStatus.awaitingUser:
        return AppColors.warning;
      case SupportTicketStatus.open:
        return AppColors.error;
    }
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = BrutalistPalette.muted(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(children: [
        Icon(Icons.support_agent_outlined,
            size: 64, color: muted.withValues(alpha: 0.4)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Nenhum ticket por aqui',
          style: AppTypography.titleMedium.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Quando usuários abrirem chamados, eles aparecerão aqui.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: muted),
        ),
      ]),
    );
  }
}
