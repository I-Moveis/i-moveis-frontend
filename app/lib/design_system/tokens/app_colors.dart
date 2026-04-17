import 'package:flutter/material.dart';

/// Design tokens: Color palette
///
/// Brutalist elegance — Keita Yamada / p5aholic.me philosophy:
/// Pure black (#0f0f0f) and pure white. Period.
/// The boldness comes from CONTRAST, not color.
/// Accent is restrained to a single tone, used sparingly.
/// "Simple but audacious, minimalist but not flat, elegant."
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════
  //  THE BLACK — warm charcoal, not void-black
  // ═══════════════════════════════════════════════════════════════
  static const black = Color(0xFF131313);
  static const blackLight = Color(0xFF1C1C1C); // Cards, elevated
  static const blackLighter = Color(0xFF262626); // Hover states
  static const blackLightest = Color(0xFF363636); // Borders

  // ═══════════════════════════════════════════════════════════════
  //  THE WHITE
  // ═══════════════════════════════════════════════════════════════
  static const white = Color(0xFFFFFFFF);
  static const whiteDim = Color(0xFFE0E0E0); // Secondary text
  static const whiteMuted = Color(0xFF888888); // Tertiary text
  static const whiteFaint = Color(0xFF555555); // Disabled / ghost

  // ═══════════════════════════════════════════════════════════════
  //  DARK THEME — warm charcoal, cozy feel
  // ═══════════════════════════════════════════════════════════════
  static const darkBackground = black;
  static const darkSurface = Color(0xFF171717);
  static const darkCard = blackLight;
  static const darkElevated = blackLighter;

  // ═══════════════════════════════════════════════════════════════
  //  LIGHT THEME (gallery mode — obake.blue / exhibition)
  // ═══════════════════════════════════════════════════════════════
  static const lightBackground = white;
  static const lightSurface = white;
  static const lightCard = white;
  static const lightElevated = Color(0xFFF5F5F5);

  // ═══════════════════════════════════════════════════════════════
  //  ACCENT — used sparingly, like a gallery spotlight
  //  One single accent. That's it. Restraint IS the design.
  // ═══════════════════════════════════════════════════════════════
  static const accent = Color(0xFFFFFFFF); // White IS the accent on dark
  static const accentOnLight = Color(0xFF0F0F0F); // Black IS the accent on light

  // For when you absolutely need color (status, not decoration):
  static const primary = Color(0xFFFFFFFF);
  static const primaryDark = Color(0xFF0F0F0F);
  static const primaryLight = Color(0xFFE0E0E0);
  static const onPrimary = Color(0xFF0F0F0F);

  static const secondary = Color(0xFF888888);
  static const secondaryDark = Color(0xFF555555);
  static const secondaryLight = Color(0xFFAAAAAA);
  static const onSecondary = Color(0xFFFFFFFF);

  static const tertiary = Color(0xFF888888);
  static const tertiaryDark = Color(0xFF555555);
  static const tertiaryLight = Color(0xFFAAAAAA);
  static const onTertiary = Color(0xFF0F0F0F);

  // ═══════════════════════════════════════════════════════════════
  //  TEXT
  // ═══════════════════════════════════════════════════════════════

  // Dark theme
  static const darkTextPrimary = white;
  static const darkTextSecondary = whiteDim;
  static const darkTextTertiary = whiteMuted;
  static const darkTextDisabled = whiteFaint;

  // Light theme
  static const lightTextPrimary = black;
  static const lightTextSecondary = Color(0xFF444444);
  static const lightTextTertiary = whiteMuted;
  static const lightTextDisabled = Color(0xFFBBBBBB);

  // ═══════════════════════════════════════════════════════════════
  //  BORDERS — barely there
  // ═══════════════════════════════════════════════════════════════
  static const darkBorder = blackLightest;
  static const darkBorderSubtle = blackLighter;
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightBorderSubtle = Color(0xFFF0F0F0);

  // ═══════════════════════════════════════════════════════════════
  //  SEMANTIC — functional color only, never decorative
  // ═══════════════════════════════════════════════════════════════
  static const success = Color(0xFF4ADE80);
  static const successBg = Color(0xFF0D1A0D);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFEAB308);
  static const warningBg = Color(0xFF1A1708);
  static const warningLight = Color(0xFFFEF9C3);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFF1A0D0D);
  static const errorLight = Color(0xFFFEE2E2);
  static const pending = Color(0xFFD4A060);
  static const pendingBg = Color(0xFF1A1508);
  static const pendingLight = Color(0xFFFFF3E0);
  static const info = Color(0xFF888888);
  static const infoBg = Color(0xFF1A1A1A);
  static const infoLight = Color(0xFFF0F0F0);

  // ═══════════════════════════════════════════════════════════════
  //  GLASS — p5aholic: hsla(0,0%,100%,.01) + 5px blur
  //  Almost invisible. That's the point.
  // ═══════════════════════════════════════════════════════════════
  static const glass = Color(0x03FFFFFF); // 1% white
  static const glassBorder = Color(0x0AFFFFFF); // 4% white
  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x05FFFFFF),
      Color(0x02FFFFFF),
    ],
  );

  // ═══════════════════════════════════════════════════════════════
  //  OVERLAY
  // ═══════════════════════════════════════════════════════════════
  static const overlayLight = Color(0x0AFFFFFF);
  static const overlayMedium = Color(0x1AFFFFFF);
  static const overlayDark = Color(0x80000000);
  static const scrim = Color(0xCC0F0F0F);

  // ═══════════════════════════════════════════════════════════════
  //  IRIDESCENT — kept from v2 but used ONLY for special moments
  //  Like a gallery that's mostly white but has one stunning piece
  // ═══════════════════════════════════════════════════════════════
  static const iridescent1 = Color(0xFFFF6B9D);
  static const iridescent2 = Color(0xFFFF9A56);
  static const iridescent3 = Color(0xFFFFE66D);
  static const iridescent4 = Color(0xFF06D6A0);
  static const iridescent5 = Color(0xFF48BFE3);
  static const iridescent6 = Color(0xFF8B5CF6);

  static const pastelPink = Color(0xFFECACAC); // Extracted from obake.blue
  static const pastelBlue = Color(0xFFB5D4FF);
  static const pastelMint = Color(0xFFAEF1F5); // Extracted from Starpeggio
  static const pastelLavender = Color(0xFFD4B5FF);
  static const pastelYellow = Color(0xFFFFF0B5);
  static const pastelPeach = Color(0xFFFFD4B5);

  // ═══════════════════════════════════════════════════════════════
  //  EXTRACTED REFERENCE TOKENS (JAPANESE WEB AESTHETICS)
  // ═══════════════════════════════════════════════════════════════
  static const lqveCyan = Color(0xFF01FFEA); // LQVE neon cyan
  static const obakeBlue = Color(0xFF2B00FF); // Obake.blue vivid blue
  static const obakePink = Color(0xFFECACAC); // Obake.blue pastel pink
  static const starpeggioCyan = Color(0xFFAEF1F5); // Starpeggio glassy cyan
  static const overtureTeal = Color(0xFF054646); // Overture deep teal
  static const overtureDark = Color(0xFF070808); // Overture true dark
  static const p5OffWhite = Color(0xFFE6E6E6); // p5aholic off-white

  static const iridescentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [iridescent1, iridescent3, iridescent4, iridescent6],
  );

  // The only gradients: functional, not decorative
  static const auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [iridescent6, iridescent4, iridescent5],
  );

  static const shimmerGradient = SweepGradient(
    colors: [
      Color(0x808B5CF6),
      Color(0x8006D6A0),
      Color(0x80FF6B9D),
      Color(0x80FFE66D),
      Color(0x8048BFE3),
      Color(0x808B5CF6),
    ],
  );

  // Kept for gradient cards
  static const cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
  );

  static const midnightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
  );

  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [iridescent1, iridescent2, iridescent3],
  );

  static const grain = Color(0x08FFFFFF);
}
