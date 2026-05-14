import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/models/chat_models.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({required this.conversationId, super.key});
  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
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
      await sendChatMessage(
        ref: ref,
        sessionId: widget.conversationId,
        content: content,
      );
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
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );
    final headerTitle = isOwner ? 'Inquilino / Contato' : 'Proprietário';

    final messagesAsync =
        ref.watch(sessionMessagesProvider(widget.conversationId));

    ref.listen<AsyncValue<List<MessageModel>>>(
      sessionMessagesProvider(widget.conversationId),
      (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );

    return BrutalistPageScaffold(
      waveAmplitude: 0.3,
      waveCount: 3,
      waveSpeed: 0.2,
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Column(children: [
          BrutalistAppBar(
            title: headerTitle,
            onBack: () => context.go('/chat'),
            actions: [
              BrutalistAppBarAction(
                icon: Icons.info_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 40, color: accentColor.withValues(alpha: 0.2)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Erro ao carregar',
                      style: AppTypography.headlineMedium
                          .copyWith(color: titleColor)),
                ]),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 40,
                          color: accentColor.withValues(alpha: 0.2)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Nenhuma mensagem',
                          style: AppTypography.headlineMedium
                              .copyWith(color: titleColor)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Envie a primeira mensagem',
                          style: AppTypography.bodyMedium
                              .copyWith(color: mutedColor)),
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
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: MessageBubble(message: messages[i], isDark: isDark),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file_rounded,
                      size: 20, color: mutedColor),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    enabled: !_sending,
                    style:
                        AppTypography.bodyMedium.copyWith(color: titleColor),
                    cursorColor: accentColor,
                    cursorWidth: 1.5,
                    decoration: InputDecoration(
                      hintText: 'Mensagem...',
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: BrutalistPalette.faint(isDark)),
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
                            color: isDark ? AppColors.black : AppColors.white),
                  ),
                ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}
