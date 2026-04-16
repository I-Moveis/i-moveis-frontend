import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/design_system/design_system.dart';

/// Chat tab — cozy conversation list with rounded cards.
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  static const _conversations = [
    _ConversationData(name: 'Ricardo Mendes', initials: 'RM', message: 'Olá, o apartamento ainda está disponível?', time: '10:30', unread: true),
    _ConversationData(name: 'Ana Souza', initials: 'AS', message: 'Podemos agendar a visita para sexta?', time: '09:15', unread: true),
    _ConversationData(name: 'Carlos Lima', initials: 'CL', message: 'Contrato assinado! Obrigado.', time: 'Ontem', unread: false),
  ];

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: AppSpacing.xl),
                Text('Conversas', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
                const SizedBox(height: AppSpacing.xxl),
                for (int i = 0; i < _conversations.length; i++) ...[
                  _buildCard(context, _conversations[i], i, isDark, titleColor, mutedColor, accentColor),
                  const SizedBox(height: AppSpacing.md),
                ],
              ]),
            )),
          ],
        ));
      },
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
