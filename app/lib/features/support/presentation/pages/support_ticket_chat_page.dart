import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/support_ticket.dart';
import '../providers/support_ticket_messages_notifier.dart';
import '../providers/support_tickets_notifier.dart';

class SupportTicketChatPage extends ConsumerStatefulWidget {
  const SupportTicketChatPage({required this.ticketId, super.key});
  final String ticketId;

  @override
  ConsumerState<SupportTicketChatPage> createState() =>
      _SupportTicketChatPageState();
}

class _SupportTicketChatPageState
    extends ConsumerState<SupportTicketChatPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _msgController.text.trim();
    if (content.isEmpty) return;

    setState(() => _sending = true);
    _msgController.clear();

    try {
      await ref
          .read(ticketMessagesProvider(widget.ticketId).notifier)
          .send(content);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar mensagem.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(supportTicketsProvider);
    final ticket = ticketAsync.maybeWhen(
      data: (tickets) =>
          tickets.where((t) => t.id == widget.ticketId).firstOrNull,
      orElse: () => null,
    );

    final isResolved = ticket?.status == SupportTicketStatus.resolved;
    final messagesAsync =
        ref.watch(ticketMessagesProvider(widget.ticketId));

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final muted = BrutalistPalette.muted(isDark);
        final accent =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Column(children: [
          BrutalistAppBar(
            title: ticket?.code ?? 'Chat',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => Center(
                child: Text('Erro ao carregar mensagens',
                    style: TextStyle(color: muted)),
              ),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.support_agent_rounded,
                          size: 40, color: accent.withValues(alpha: 0.2)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Nenhuma mensagem',
                          style: AppTypography.headlineMedium
                              .copyWith(color: titleColor)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Envie a primeira mensagem',
                          style:
                              AppTypography.bodyMedium.copyWith(color: muted)),
                    ]),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isUser = !msg.isFromAdmin;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  accent.withValues(alpha: 0.12),
                              child: Icon(Icons.support_agent_rounded,
                                  size: 16, color: accent),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? accent.withValues(alpha: 0.1)
                                    : BrutalistPalette.surfaceBg(isDark),
                                borderRadius: AppRadius.borderLg,
                                border: Border.all(
                                    color: isUser
                                        ? accent.withValues(alpha: 0.25)
                                        : BrutalistPalette.surfaceBorder(
                                            isDark)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.senderLabel,
                                    style: AppTypography.labelSmall
                                        .copyWith(
                                            color: isUser ? accent : muted),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    msg.content,
                                    style: AppTypography.bodyMedium
                                        .copyWith(color: titleColor),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      _formatTime(msg.timestamp),
                                      style: AppTypography.bodySmall.copyWith(
                                          color: muted, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: AppSpacing.sm),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  accent.withValues(alpha: 0.15),
                              child: Icon(Icons.person_rounded,
                                  size: 16, color: accent),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (isResolved)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: BrutalistPalette.subtleBg(isDark),
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(
                        color: BrutalistPalette.surfaceBorder(isDark)),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Chamado resolvido — não aceita novas mensagens.',
                          style:
                              AppTypography.bodySmall.copyWith(color: muted)),
                    ),
                  ]),
                ),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      enabled: !_sending,
                      style: AppTypography.bodyMedium
                          .copyWith(color: titleColor),
                      cursorColor: accent,
                      cursorWidth: 1.5,
                      decoration: InputDecoration(
                        hintText: 'Mensagem...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                            color: BrutalistPalette.faint(isDark)),
                        filled: true,
                        fillColor: BrutalistPalette.surfaceBg(isDark),
                        border: OutlineInputBorder(
                            borderRadius: AppRadius.borderRound,
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  BrutalistPalette.warmBrown,
                                  BrutalistPalette.warmOrange,
                                ]
                              : [
                                  BrutalistPalette.deepBrown,
                                  BrutalistPalette.deepOrange,
                                ],
                        ),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(Icons.send_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.black
                                  : AppColors.white),
                    ),
                  ),
                ]),
              ),
            ),
        ]);
      },
    );
  }

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
