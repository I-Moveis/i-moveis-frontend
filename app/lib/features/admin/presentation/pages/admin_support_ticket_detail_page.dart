import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../../support/domain/entities/support_ticket.dart';
import '../../../support/domain/entities/support_ticket_message.dart';
import '../../../support/presentation/providers/support_ticket_messages_notifier.dart';
import '../providers/admin_support_tickets_notifier.dart';

class AdminSupportTicketDetailPage extends ConsumerStatefulWidget {
  const AdminSupportTicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<AdminSupportTicketDetailPage> createState() =>
      _AdminSupportTicketDetailPageState();
}

class _AdminSupportTicketDetailPageState
    extends ConsumerState<AdminSupportTicketDetailPage> {
  final _messageController = TextEditingController();
  final _resolutionController = TextEditingController();
  String? _selectedStatus;

  static const _statusOptions = [
    ('OPEN', 'Aberto'),
    ('IN_PROGRESS', 'Em andamento'),
    ('RESOLVED', 'Resolvido'),
    ('CLOSED', 'Fechado'),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  SupportTicket? _findTicket(List<SupportTicket> tickets) {
    try {
      return tickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final ticketsAsync = ref.watch(adminSupportTicketsProvider);
        final ticket = ticketsAsync.value != null
            ? _findTicket(ticketsAsync.value!)
            : null;

        final messagesAsync =
            ref.watch(ticketMessagesProvider(widget.ticketId));

        if (_selectedStatus == null && ticket != null) {
          _selectedStatus = ticket.status.toApi();
        }

        return Column(children: [
          BrutalistAppBar(
            title: ticket?.code ?? 'Ticket',
          ),

          Expanded(
            child: ticketsAsync.isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))
                : ticket == null
                    ? Center(
                        child: Text('Ticket não encontrado.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: mutedColor)),
                      )
                    : Column(children: [
                        // Header com metadata e controle de status
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                              vertical: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.title.isEmpty
                                    ? '(sem título)'
                                    : ticket.title,
                                style: AppTypography.titleSmallBold
                                    .copyWith(color: titleColor),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                ticket.description,
                                style: AppTypography.bodySmall
                                    .copyWith(color: mutedColor),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(children: [
                                Text(ticket.code,
                                    style: AppTypography.monoSmallWide
                                        .copyWith(
                                            color: mutedColor, fontSize: 10)),
                                if (ticket.userRole != null) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Text('·',
                                      style: AppTypography.bodySmall.copyWith(
                                          color:
                                              mutedColor.withValues(alpha: 0.5))),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(ticket.userRole!,
                                      style: AppTypography.bodySmall.copyWith(
                                          color: mutedColor, fontSize: 11)),
                                ],
                              ]),
                              const SizedBox(height: AppSpacing.md),

                              // Seletor de status
                              Text('Status',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: _statusOptions.map((opt) {
                                  final (value, label) = opt;
                                  final isSelected = _selectedStatus == value;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedStatus = value),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? accentColor.withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        borderRadius: AppRadius.borderFull,
                                        border: Border.all(
                                          color: isSelected
                                              ? accentColor.withValues(alpha: 0.5)
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(label,
                                          style:
                                              AppTypography.titleSmallBold.copyWith(
                                            color: isSelected
                                                ? accentColor
                                                : mutedColor,
                                            fontSize: 12,
                                          )),
                                    ),
                                  );
                                }).toList(),
                              ),

                              // Campo resolução aparece ao selecionar RESOLVED ou CLOSED
                              if (_selectedStatus == 'RESOLVED' ||
                                  _selectedStatus == 'CLOSED') ...[
                                const SizedBox(height: AppSpacing.md),
                                Text('Resolução',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: titleColor,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.borderLg,
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: TextField(
                                    controller: _resolutionController,
                                    maxLines: 3,
                                    style: AppTypography.bodyMedium
                                        .copyWith(color: titleColor),
                                    decoration: InputDecoration(
                                      hintText: 'Descreva a resolução...',
                                      hintStyle: AppTypography.bodySmall
                                          .copyWith(color: mutedColor),
                                      contentPadding: const EdgeInsets.all(
                                          AppSpacing.md),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () => _saveStatus(context, ticket),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.borderFull,
                                      border: Border.all(
                                          color:
                                              accentColor.withValues(alpha: 0.3)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('Salvar status',
                                        style: AppTypography.titleSmallBold
                                            .copyWith(
                                                color: accentColor,
                                                fontSize: 13)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Histórico de mensagens
                        Expanded(
                          child: messagesAsync.when(
                            loading: () => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            error: (_, __) => Center(
                              child: Text('Erro ao carregar mensagens.',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: mutedColor)),
                            ),
                            data: (messages) => messages.isEmpty
                                ? Center(
                                    child: Text('Nenhuma mensagem ainda.',
                                        style: AppTypography.bodySmall
                                            .copyWith(color: mutedColor)),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.screenHorizontal,
                                        vertical: AppSpacing.sm),
                                    itemCount: messages.length,
                                    itemBuilder: (_, i) => _MessageBubble(
                                      message: messages[i],
                                      isDark: isDark,
                                    ),
                                  ),
                          ),
                        ),

                        // Input de mensagem
                        _MessageInput(
                          controller: _messageController,
                          isDark: isDark,
                          onSend: () => _sendMessage(context),
                        ),
                      ]),
          ),
        ]);
      },
    );
  }

  Future<void> _saveStatus(BuildContext context, SupportTicket ticket) async {
    final status = _selectedStatus;
    if (status == null) return;
    final resolution = _resolutionController.text.trim();
    try {
      await ref.read(adminSupportTicketsProvider.notifier).updateTicket(
            ticket.id,
            status,
            resolution: resolution.isEmpty ? null : resolution,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status atualizado.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar status.')),
        );
      }
    }
  }

  Future<void> _sendMessage(BuildContext context) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _messageController.clear();
    try {
      await ref
          .read(ticketMessagesProvider(widget.ticketId).notifier)
          .send(content);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar mensagem.')),
        );
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});

  final SupportTicketMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final mutedColor = BrutalistPalette.muted(isDark);
    final titleColor = BrutalistPalette.title(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              child: Text(
                message.senderLabel.substring(0, 1),
                style: AppTypography.titleSmallBold
                    .copyWith(color: accentColor, fontSize: 12),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderLabel,
                  style: AppTypography.bodySmall
                      .copyWith(color: mutedColor, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? accentColor.withValues(alpha: 0.12)
                        : BrutalistPalette.surfaceBg(isDark),
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(
                      color: isAdmin
                          ? accentColor.withValues(alpha: 0.3)
                          : BrutalistPalette.surfaceBorder(isDark),
                    ),
                  ),
                  child: SelectableText(
                    message.content,
                    style:
                        AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 3,
            minLines: 1,
            style: AppTypography.bodyMedium.copyWith(color: titleColor),
            decoration: InputDecoration(
              hintText: 'Responder como suporte...',
              hintStyle: AppTypography.bodySmall.copyWith(color: mutedColor),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderLg,
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderLg,
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderLg,
                borderSide:
                    BorderSide(color: accentColor.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
