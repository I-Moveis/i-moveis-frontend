import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../data/providers/notifications_data_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_notifier.dart';

/// Tela que o tenant ou landlord abre ao tocar no sino. Lista as
/// notificações recebidas (cache local de push / broadcasts do admin).
/// Ao abrir, marca tudo como lido automaticamente.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Efeito: ao abrir a tela, zera o badge. Se o usuário quiser manter
    // algo "unread", é só não abrir. Para fluxos mais sofisticados (marcar
    // individualmente), expor um menu de ações.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Sincroniza com o backend antes de marcar como lido
      await ref.read(syncNotificationsProvider.future).catchError((_) => 0);
      if (mounted) {
        ref.read(notificationsNotifierProvider.notifier).markAllRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(notificationsNotifierProvider);
    return BrutalistPageScaffold(
      builder: (context, isDark, _, _) {
        return Column(children: [
          BrutalistAppBar(
            title: 'Notificações',
            actions: items.isEmpty
                ? null
                : [
                    BrutalistAppBarAction(
                      icon: Icons.delete_sweep_outlined,
                      onTap: () => _confirmClear(context),
                    ),
                  ],
          ),
          Expanded(
            child: items.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => _NotificationTile(
                      notification: items[index],
                      isDark: isDark,
                    ),
                  ),
          ),
        ]);
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar notificações'),
        content: const Text(
          'Isso apaga todas as notificações do seu histórico local. '
          'Ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(notificationsNotifierProvider.notifier).clear();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: mutedColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Você está em dia',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Avisos importantes da plataforma, atualizações do app e '
              'comunicados do suporte aparecem aqui.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.isDark});
  final AppNotification notification;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: notification.read
              ? BrutalistPalette.surfaceBorder(isDark)
              : accentColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              _iconForCategory(notification.category),
              size: 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title.isEmpty
                      ? 'Mensagem da plataforma'
                      : notification.title,
                  style: AppTypography.titleSmallBold
                      .copyWith(color: titleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  notification.body,
                  style: AppTypography.bodyMedium.copyWith(color: mutedColor),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _formatReceivedAt(notification.receivedAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: mutedColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case 'update':
        return Icons.system_update_alt_rounded;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _formatReceivedAt(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    if (diff.inDays < 7) return 'há ${diff.inDays} d';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
