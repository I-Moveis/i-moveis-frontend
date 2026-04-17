import 'package:flutter/material.dart';

/// Design tokens: Shadows
///
/// Brutalist elegance: shadows are barely there or not at all.
/// Depth comes from contrast and spacing, not drop shadows.
/// Glow effects reserved for rare interactive moments.
abstract final class AppShadows {
  // ─── Dark Theme — almost no shadows ──────────────────────────

  static const darkSm = <BoxShadow>[];
  static const darkMd = <BoxShadow>[];
  static const darkLg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Light Theme — subtle only ───────────────────────────────

  static const lightSm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const lightMd = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const lightLg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ─── Glow — for rare moments of emphasis ─────────────────────

  static const primaryGlow = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const secondaryGlow = <BoxShadow>[];

  static const tertiaryGlow = <BoxShadow>[];

  static const accentGlow = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const errorGlow = [
    BoxShadow(
      color: Color(0x33EF4444),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const cosmicBloom = <BoxShadow>[];
  static const starlight = <BoxShadow>[];

  /// Dynamic glow for gradient buttons (auth/onboarding shimmer buttons).
  static List<BoxShadow> buttonGlow(Color glowColor) => [
        BoxShadow(
          color: glowColor,
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];
}
