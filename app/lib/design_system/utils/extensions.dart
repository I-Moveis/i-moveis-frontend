/// Design System Extensions
///
/// Utility extensions for colors, text styles, and other common operations.
library;

import 'package:flutter/material.dart';

/// Extensions for Color manipulation
extension ColorExtensions on Color {
  /// Get luminance-based text color (white or black)
  Color get textColorOnBg {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Create a lighter shade of the color
  Color lighten({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0, 1),
    );
    return lightened.toColor();
  }

  /// Create a darker shade of the color
  Color darken({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0, 1),
    );
    return darkened.toColor();
  }

  /// Blend two colors with a specified opacity
  Color blend(Color other, double amount) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(this, other, amount) ?? this;
  }
}

/// Extensions for TextStyle manipulation
extension TextStyleExtensions on TextStyle {
  /// Create a copy with adjusted opacity
  TextStyle withOpacity(double opacity) {
    return copyWith(
      color: color?.withValues(alpha: opacity),
    );
  }

  /// Create a copy with adjusted line height
  TextStyle withLineHeight(double lineHeight) {
    return copyWith(
      height: lineHeight,
    );
  }

  /// Create a copy with letter spacing adjustment
  TextStyle withLetterSpacing(double spacing) {
    return copyWith(
      letterSpacing: spacing,
    );
  }
}

/// Extensions for ThemeData
extension ThemeDataExtensions on ThemeData {
  /// Get text color based on brightness
  Color get textColorPrimary {
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  /// Get text color for secondary text
  Color get textColorSecondary {
    return brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }
}

/// Extensions for Duration
extension DurationExtensions on Duration {
  /// Check if duration is less than a second
  bool get isInstant => inMilliseconds < 1000;

  /// Check if duration is quick (< 500ms)
  bool get isQuick => inMilliseconds < 500;

  /// Check if duration is normal (500-1000ms)
  bool get isNormal => inMilliseconds >= 500 && inMilliseconds <= 1000;

  /// Check if duration is slow (> 1000ms)
  bool get isSlow => inMilliseconds > 1000;
}
