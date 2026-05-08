import 'package:flutter/material.dart';

import '../../../../../design_system/design_system.dart';
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

  String get _senderLabel {
    switch (message.senderType) {
      case 'BOT':
        return 'Assistente';
      case 'TENANT':
        return 'Cliente';
      case 'LANDLORD':
        return 'Proprietário';
      default:
        return message.senderType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);
    final accent =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final bgColor = _isMine
        ? accent.withValues(alpha: 0.1)
        : BrutalistPalette.surfaceBg(isDark);
    final borderColor = _isMine
        ? accent.withValues(alpha: 0.25)
        : BrutalistPalette.surfaceBorder(isDark);

    return Row(
      mainAxisAlignment:
          _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isMine)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(
                message.senderType == 'BOT'
                    ? Icons.smart_toy_rounded
                    : Icons.person_rounded,
                size: 14,
                color: accent,
              ),
            ),
          ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    _isMine ? const Radius.circular(12) : Radius.zero,
                bottomRight:
                    _isMine ? Radius.zero : const Radius.circular(12),
              ),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _senderLabel,
                  style: AppTypography.labelSmall
                      .copyWith(color: _isMine ? accent : muted),
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  style: AppTypography.bodyMedium.copyWith(color: titleColor),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.bodySmall
                        .copyWith(color: muted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isMine)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm, top: 2),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: accent.withValues(alpha: 0.15),
              child: Icon(Icons.person_rounded, size: 14, color: accent),
            ),
          ),
      ],
    );
  }

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
