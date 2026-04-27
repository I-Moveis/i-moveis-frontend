import 'package:flutter/material.dart';

class MapPriceMarker extends StatelessWidget {
  const MapPriceMarker({
    required this.formattedPrice,
    required this.onTap,
    super.key,
    this.isSelected = false,
  });

  final String formattedPrice;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Pegando as cores do tema ou padronizando caso não tenha
    final primaryColor = Theme.of(context).primaryColor;
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isSelected ? colorScheme.secondary : primaryColor;
    final textColor = isSelected ? colorScheme.onSecondary : colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedPrice,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
