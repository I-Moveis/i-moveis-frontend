import 'package:flutter/material.dart';
import '../tokens/app_typography.dart';

/// Compact icon + value row for property stats (area, beds, etc).
class AppStatRow extends StatelessWidget {
  const AppStatRow({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
