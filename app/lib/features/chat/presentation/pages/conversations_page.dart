import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../domain/entities/conversation_summary.dart';
import '../providers/conversations_notifier.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isOwner = auth.maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );
    final currentUserId = auth.maybeWhen(
          authenticated: (user) => user.id,
          orElse: () => null,
        );
    final currentUserName = auth.maybeWhen(
          authenticated: (user) => user.name.trim().toLowerCase(),
          orElse: () => '',
        );

    final async = ref.watch(conversationsProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
          ),
        );
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark
            ? BrutalistPalette.warmOrange
            : BrutalistPalette.deepOrange;

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BrutalistPageHeader(
                  title: 'Conversas',
                  subtitle: isOwner
                      ? 'Mensagens com seus inquilinos'
                      : 'Mensagens com proprietários',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      async.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.xxxl),
                          child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, _) => _buildEmptyState(
                            isDark, titleColor, mutedColor, accentColor),
                        data: (conversations) {
                          // Tenant só pode ver as próprias conversas com
                          // landlords — não pode aparecer conversa de outro
                          // tenant. Landlord vê todas as próprias.
                          final visible = isOwner
                              ? conversations
                              : conversations
                                  .where((c) =>
                                      c.linkedTenantId != null &&
                                      c.linkedTenantId == currentUserId)
                                  .toList();
                          return visible.isEmpty
                              ? _buildEmptyState(isDark, titleColor,
                                  mutedColor, accentColor)
                              : Column(
                                  children: [
                                    for (final c in visible) ...[
                                      _ConversationCard(
                                        conversation: c,
                                        isDark: isDark,
                                        titleColor: titleColor,
                                        mutedColor: mutedColor,
                                        accentColor: accentColor,
                                        currentUserName: currentUserName,
                                        isOwner: isOwner,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                    ],
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: mutedColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.lg),
            Text('Nenhuma conversa',
                style: AppTypography.headlineSmall.copyWith(
                  color: titleColor,
                )),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Suas conversas com inquilinos aparecerão aqui.\n'
              'Quando um inquilino entrar em contato, você verá a conversa nesta lista.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.currentUserName,
    required this.isOwner,
  });

  final ConversationSummary conversation;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  /// Nome do usuário logado em lowercase. Usado para detectar quando o
  /// backend devolveu o próprio nome do user como counterpart (acontece
  /// quando dados de seed têm conflito ou quando `isUserLandlord` falha
  /// no backend) e cair em um rótulo neutro nesse caso.
  final String currentUserName;
  final bool isOwner;

  String _displayName() {
    final raw = conversation.counterpartName.trim();
    final lower = raw.toLowerCase();
    final isRoleLabel = const {'landlord', 'tenant', 'admin'}.contains(lower);
    final isSelf =
        currentUserName.isNotEmpty && lower == currentUserName;
    if (raw.isEmpty || isRoleLabel || isSelf) {
      // Fallback: rótulo neutro de acordo com o lado em que o usuário
      // logado está. Tenant vê chats com proprietários; landlord vê
      // chats com interessados.
      return isOwner ? 'Interessado' : 'Proprietário';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final displayName = _displayName();

    return GestureDetector(
      onTap: () => context.push('/conversation/${conversation.id}', extra: displayName),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  _initialsFor(displayName),
                  style: AppTypography.titleSmallBold
                      .copyWith(color: accentColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: AppTypography.titleLargeBold
                              .copyWith(color: titleColor),
                        ),
                      ),
                      if (conversation.unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    conversation.lastMessage,
                    style: AppTypography.bodySmall
                        .copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _formatTime(conversation.lastMessageAt),
              style: AppTypography.bodySmall.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final w = parts.first;
      return w.length == 1
          ? w.toUpperCase()
          : w.substring(0, 2).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final sameDay = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    if (sameDay) return '$hh:$mm';
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;
    if (isYesterday) return 'Ontem';
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$dd/$mo';
  }
}
