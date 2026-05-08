import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../data/models/chat_models.dart';

class SessionTile extends ConsumerWidget {
  const SessionTile({
    required this.session,
    this.onTap,
    super.key,
  });

  final ChatSessionModel session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    final initials = _initials(session.tenantName ?? 'Cliente');
    final hasUnread = _hasUnread;

    return GestureDetector(
      onTap: onTap ?? () => context.go('/chat/${session.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: BrutalistPalette.surfaceBg(isDark),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasUnread
                    ? accentColor.withValues(alpha: 0.2)
                    : accentColor.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTypography.titleSmallBold.copyWith(
                    color: hasUnread ? accentColor : accentColor.withValues(alpha: 0.6),
                  ),
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
                          session.tenantName ?? 'Cliente',
                          style: AppTypography.titleLargeBold.copyWith(
                            color: titleColor,
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _buildStatusBadge(isDark, key: ValueKey('${session.id}-${session.status}')),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildPreview(mutedColor, key: ValueKey('${session.id}-${session.lastMessage}')),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(session.lastMessageAt),
                  style: AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.elasticOut,
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasUnread {
    final last = session.lastSenderType;
    return last == 'TENANT' || last == 'BOT';
  }

  Widget _buildPreview(Color mutedColor, {Key? key}) {
    final lastSender = session.lastSenderType;
    final prefix = lastSender == 'LANDLORD' ? 'Você: ' : '';

    return Text(
      '$prefix${session.lastMessage ?? 'Nova conversa'}',
      key: key,
      style: AppTypography.bodySmall.copyWith(color: mutedColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusBadge(bool isDark, {Key? key}) {
    String label;
    Color color;
    switch (session.status) {
      case 'ACTIVE_BOT':
        label = '🤖 Bot';
        color = BrutalistPalette.muted(isDark);
        break;
      case 'WAITING_HUMAN':
        label = '🟡 Pendente';
        color = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        break;
      case 'RESOLVED':
        label = '✅ Resolvido';
        color = const Color(0xFF4CAF50);
        break;
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: AppTypography.captionTiny.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1) return 'Ontem';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}
