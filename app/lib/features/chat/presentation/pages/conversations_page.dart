import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/models/chat_models.dart';
import '../providers/chat_providers.dart';

/// Lista de conversas do usuário — mesma tela pra tenant e landlord, com
/// copy de subtítulo trocando pelo papel. Dados vêm do
/// `conversationsProvider`, que hoje cai em lista vazia enquanto o
/// backend não expõe `GET /api/conversations`
/// (ver `BACKEND_HANDOFF.md §4`).
class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );

    final async = ref.watch(sessionsProvider);

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
                      ? 'Suas mensagens com inquilinos e interessados'
                      : 'Suas mensagens com proprietários e suporte',
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
                        // Erro também cai no estado vazio — o provider
                        // já tenta recuperar sozinho. Não tem sentido
                        // mostrar "erro ao carregar" enquanto o backend
                        // nem expõe o endpoint.
                        error: (_, _) => _buildEmptyState(
                            isDark, titleColor, mutedColor, accentColor),
                        data: (sessions) => sessions.isEmpty
                            ? _buildEmptyState(
                                isDark, titleColor, mutedColor, accentColor)
                            : Column(
                                children: [
                                  for (final s in sessions) ...[
                                    _ConversationCard(
                                      session: s,
                                      isDark: isDark,
                                      titleColor: titleColor,
                                      mutedColor: mutedColor,
                                      accentColor: accentColor,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                ],
                              ),
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
              'Suas mensagens com inquilinos, proprietários e suporte\n'
              'aparecerão aqui.',
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
    required this.session,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final ChatSessionModel session;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final lastAt = session.lastMessageAt ?? session.startedAt;

    return GestureDetector(
      onTap: () => context.push('/chat/${session.id}'),
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
                  session.initials,
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
                  Text(
                    session.tenantName ?? 'Inquilino',
                    style: AppTypography.titleLargeBold
                        .copyWith(color: titleColor),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    session.lastMessage ?? '',
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _formatTime(lastAt),
              style: AppTypography.bodySmall.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
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
