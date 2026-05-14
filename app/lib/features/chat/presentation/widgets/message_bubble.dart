import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isDark,
    super.key,
  });

  final MessageModel message;
  final bool isDark;

  bool get _isMine => message.senderType == 'LANDLORD';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: _isMine ? 48 : 12,
        right: _isMine ? 12 : 48,
        bottom: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment:
            _isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSenderBadge(),
            ],
          ),
          const SizedBox(height: 2),
          Column(
            crossAxisAlignment:
                _isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                  color: _bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.lg),
                    topRight: const Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(_isMine ? AppRadius.lg : AppRadius.xs),
                    bottomRight: Radius.circular(_isMine ? AppRadius.xs : AppRadius.lg),
                  ),
                  border: message.senderType == 'BOT'
                      ? Border.all(color: BrutalistPalette.surfaceBorder(isDark))
                      : null,
                ),
                child: Text(
                  message.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _textColor,
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
                    if (_isMine) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(),
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

  Color get _bubbleColor {
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

  Color get _textColor {
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

  Widget _buildSenderBadge() {
    final label = senderTypeLabel(message.senderType);
    final color = _textColor;
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

  Widget _buildStatusIcon() {
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
