import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Chat tab — cozy conversation list with role-based filtering.
class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  static const _tenantConversations = [
    _ConversationData(name: 'Suporte I-Moveis', initials: 'IM', message: 'Como podemos te ajudar hoje?', time: '14:20', unread: false),
    _ConversationData(name: 'Proprietário João', initials: 'PJ', message: 'O contrato está pronto para assinatura.', time: '10:30', unread: true),
  ];

  static const _landlordConversations = [
    _ConversationData(name: 'João Silva', initials: 'JS', message: 'Enviado comprovante de PIX.', time: '10:30', unread: true),
    _ConversationData(name: 'Maria Oliveira', initials: 'MO', message: 'Pode conferir o contrato?', time: '09:15', unread: true),
    _ConversationData(name: 'Pedro Santos', initials: 'PS', message: 'Vou enviar o RG amanhã.', time: 'Ontem', unread: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );

        final conversations = isOwner ? _landlordConversations : _tenantConversations;

        return BrutalistPageScaffold(
          builder: (context, isDark, entrance, pulse) {
            final fade = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
            );

            final titleColor = BrutalistPalette.title(isDark);
            final mutedColor = BrutalistPalette.muted(isDark);
            final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

            return Opacity(opacity: fade.value, child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: BrutalistPageHeader(
                    title: 'Conversas',
                    subtitle: isOwner
                        ? 'Suas mensagens com inquilinos e interessados'
                        : 'Suas mensagens com proprietários e suporte',
                  ),
                ),
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: AppSpacing.lg),
                    if (conversations.isEmpty)
                      _buildEmptyState(isDark, titleColor, mutedColor, accentColor)
                    else
                      for (int i = 0; i < conversations.length; i++) ...[
                        _buildCard(context, conversations[i], i, isDark, titleColor, mutedColor, accentColor),
                        const SizedBox(height: AppSpacing.md),
                      ],
                  ]),
                )),
              ],
            ));
          },
        );
  }

  Widget _buildEmptyState(bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: mutedColor.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text('Nenhuma conversa', style: AppTypography.headlineSmall.copyWith(color: titleColor)),
          const SizedBox(height: AppSpacing.xs),
          Text('Suas mensagens aparecerão aqui.', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _ConversationData c, int i, bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return GestureDetector(
      onTap: () => context.go('/chat/conversation-$i'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.1),
            ),
            child: Center(child: Text(c.initials, style: AppTypography.titleSmallBold.copyWith(color: accentColor))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xxs),
            Text(c.message, style: AppTypography.bodySmall.copyWith(color: mutedColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: AppSpacing.md),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(c.time, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
            if (c.unread) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
            ],
          ]),
        ]),
      ),
    );
  }
}

class _ConversationData {
  const _ConversationData({required this.name, required this.initials, required this.message, required this.time, required this.unread});
  final String name;
  final String initials;
  final String message;
  final String time;
  final bool unread;
}
