import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/support_ticket.dart';
import '../../../admin/presentation/providers/admin_support_tickets_notifier.dart';
import '../providers/support_tickets_notifier.dart';

/// Acompanhamento de um chamado específico. Mostra o título, descrição,
/// status, horário e um placeholder da conversa (respostas do admin
/// ainda não existem no backend — ver `BACKEND_HANDOFF.md §10`).
///
/// Quando o painel do admin começar a responder, a API vai entregar um
/// array de `messages`; é lá que esta tela vai crescer pra mostrar uma
/// thread completa. Hoje exibe só a mensagem inicial do usuário.
///
/// Busca o ticket tanto na lista do usuário quanto na lista admin,
/// para funcionar tanto pelo Perfil → Suporte quanto pelo painel admin.
class SupportTicketDetailPage extends ConsumerWidget {
  const SupportTicketDetailPage({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTickets = ref.watch(supportTicketsProvider);
    final adminTickets = ref.watch(adminSupportTicketsProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Chamado'),
          Expanded(
            child: _buildContent(
              userTickets: userTickets,
              adminTickets: adminTickets,
              isDark: isDark,
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildContent({
    required AsyncValue<List<SupportTicket>> userTickets,
    required AsyncValue<List<SupportTicket>> adminTickets,
    required bool isDark,
  }) {
    // Busca no provider do usuário primeiro
    final userList = userTickets.asData?.value ?? [];
    final ticket = userList.where((t) => t.code == code).firstOrNull;
    if (ticket != null) return _Detail(ticket: ticket, isDark: isDark);

    // Busca no provider admin
    final adminList = adminTickets.asData?.value ?? [];
    final adminTicket = adminList.where((t) => t.code == code).firstOrNull;
    if (adminTicket != null) return _Detail(ticket: adminTicket, isDark: isDark);

    // Ambos ainda carregando
    if (userTickets.isLoading || adminTickets.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return _NotFound(isDark: isDark);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.ticket, required this.isDark});

  final SupportTicket ticket;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: BrutalistPalette.surfaceBg(isDark),
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: ticket.status, isDark: isDark),
                  const Spacer(),
                  SelectableText(
                    ticket.code,
                    style: AppTypography.monoSmallWide.copyWith(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ticket.title.isEmpty ? '(sem título)' : ticket.title,
                style: AppTypography.headlineSmall.copyWith(color: titleColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Aberto em ${_formatDate(ticket.createdAt)}',
                style: AppTypography.bodySmall.copyWith(color: muted),
              ),
              if (ticket.userName != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: muted.withValues(alpha: 0.6)),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      ticket.userName!,
                      style: AppTypography.bodySmall.copyWith(
                          color: titleColor, fontWeight: FontWeight.w600),
                    ),
                    if (ticket.userRole != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _RoleBadge(role: ticket.userRole!, isDark: isDark),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _MessageBubble(
          author: ticket.userName ?? 'Você',
          body: ticket.description,
          time: _formatTime(ticket.createdAt),
          isUser: ticket.userRole != 'ADMIN',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (ticket.status != SupportTicketStatus.resolved)
          SizedBox(
            width: double.infinity,
            child: BrutalistGradientButton(
              label: 'ABRIR CONVERSA',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => context.push('/support/${ticket.code}/chat'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: BrutalistGradientButton(
              label: 'VER CONVERSA',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => context.push('/support/${ticket.code}/chat'),
            ),
          ),
        const SizedBox(height: AppSpacing.massive),
      ],
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

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isDark});
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderPill,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall
            .copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.author,
    required this.body,
    required this.time,
    required this.isUser,
    required this.isDark,
  });

  final String author;
  final String body;
  final String time;
  final bool isUser;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);
    final accent =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isUser
              ? accent.withValues(alpha: 0.15)
              : BrutalistPalette.subtleBg(isDark),
          child: Icon(
            isUser ? Icons.person_rounded : Icons.support_agent_rounded,
            size: 16,
            color: isUser ? accent : muted,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(author,
                      style: AppTypography.titleSmallBold
                          .copyWith(color: titleColor)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(time,
                      style:
                          AppTypography.bodySmall.copyWith(color: muted)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: BrutalistPalette.surfaceBg(isDark),
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                      color: BrutalistPalette.surfaceBorder(isDark)),
                ),
                child: SelectableText(
                  body,
                  style: AppTypography.bodyMedium.copyWith(color: titleColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = BrutalistPalette.muted(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: muted),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chamado não encontrado.',
              style: AppTypography.bodyMedium.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.isDark});
  final String role;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (role) {
      'TENANT' => ('Inquilino', BrutalistPalette.accentPeach(isDark)),
      'LANDLORD' => ('Locador', AppColors.info),
      'ADMIN' => ('Admin', AppColors.warning),
      _ => (role, BrutalistPalette.muted(isDark)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
