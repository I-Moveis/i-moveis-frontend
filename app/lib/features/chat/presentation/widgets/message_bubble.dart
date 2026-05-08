import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    this.showSender = false,
    this.senderName,
    super.key,
  });

  final MessageModel message;
  final bool showSender;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMine = message.senderType == 'LANDLORD';

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 48 : 12,
        right: isMine ? 12 : 48,
        bottom: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && senderName != null)
            Padding(
              padding: EdgeInsets.only(
                left: isMine ? 0 : 4,
                right: isMine ? 4 : 0,
                bottom: AppSpacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    senderName!,
                    style: AppTypography.tagBadge.copyWith(
                      color: BrutalistPalette.muted(isDark),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildSenderBadge(isDark),
                ],
              ),
            ),
          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: _bubbleColor(isDark),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.lg),
                    topRight: const Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(isMine ? AppRadius.lg : AppRadius.xs),
                    bottomRight: Radius.circular(isMine ? AppRadius.xs : AppRadius.lg),
                  ),
                  border: message.senderType == 'BOT'
                      ? Border.all(color: BrutalistPalette.surfaceBorder(isDark))
                      : null,
                ),
                child: Text(
                  message.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _textColor(isDark),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: AppTypography.captionTiny.copyWith(
                        color: BrutalistPalette.faint(isDark),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(isDark),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _bubbleColor(bool isDark) {
    switch (message.senderType) {
      case 'BOT':
        return BrutalistPalette.surfaceBg(isDark);
      case 'TENANT':
        return isDark
            ? BrutalistPalette.deepOrange.withValues(alpha: 0.15)
            : BrutalistPalette.deepOrange.withValues(alpha: 0.1);
      case 'LANDLORD':
        return isDark
            ? BrutalistPalette.warmBrown.withValues(alpha: 0.25)
            : BrutalistPalette.deepBrown.withValues(alpha: 0.12);
      default:
        return BrutalistPalette.surfaceBg(isDark);
    }
  }

  Color _textColor(bool isDark) {
    switch (message.senderType) {
      case 'BOT':
        return BrutalistPalette.title(isDark);
      case 'TENANT':
        return isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
      case 'LANDLORD':
        return isDark ? BrutalistPalette.warmBrown : BrutalistPalette.deepBrown;
      default:
        return BrutalistPalette.title(isDark);
    }
  }

  Widget _buildSenderBadge(bool isDark) {
    final label = senderTypeLabel(message.senderType);
    final color = _textColor(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: AppTypography.captionTiny.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isDark) {
    switch (message.status) {
      case 'sent':
        return Icon(Icons.check, size: 12, color: BrutalistPalette.faint(isDark));
      case 'delivered':
        return Icon(Icons.done_all, size: 12, color: BrutalistPalette.faint(isDark));
      case 'read':
        return Icon(Icons.done_all, size: 12, color: BrutalistPalette.warmOrange);
      default:
        return Icon(Icons.access_time, size: 10, color: BrutalistPalette.faint(isDark));
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
