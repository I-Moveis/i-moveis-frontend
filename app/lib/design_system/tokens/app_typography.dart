import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens: Typography scale
///
/// Extracted typography from the 7 references translated to Google Fonts equivalents:
/// 1. p5aholic.me (Display) -> Anton / Bebas Neue equivalent
/// 2. obake.blue (Primary) -> PP Neue Machina -> 'Syne' (wide, modern, geometric)
/// 3. LQVE (Secondary/Headline) -> Suisse Int'l -> 'Space Grotesk'
/// 4. ILY GIRL (Body) -> Aventa -> 'Manrope' (highly legible, quiet)
/// 5. MGO Overture (Numbers) -> Oroban Masuria -> 'Space Mono'
abstract final class AppTypography {
  
  // Font Families evaluated at runtime
  static String? get _displayFont => GoogleFonts.syne().fontFamily;
  static String? get _headlineFont => GoogleFonts.spaceGrotesk().fontFamily;
  static String? get _bodyFont => GoogleFonts.manrope().fontFamily;
  static String? get _monoFont => GoogleFonts.spaceMono().fontFamily;

  // ═══════════════════════════════════════════════════════════════
  //  DISPLAY — THE STATEMENT (Syne)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get displayMassive => TextStyle(
    fontFamily: _displayFont,
    fontSize: 72,
    fontWeight: FontWeight.w800,
    height: 0.9,
    letterSpacing: -4,
  );

  static TextStyle get displayLarge => TextStyle(
    fontFamily: _displayFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 0.95,
    letterSpacing: -2.5,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: _displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1.5,
  );

  static TextStyle get displaySmall => TextStyle(
    fontFamily: _displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.05,
    letterSpacing: -1,
  );

  // ═══════════════════════════════════════════════════════════════
  //  HEADLINE — SECTION LEVEL (Space Grotesk)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ═══════════════════════════════════════════════════════════════
  //  TITLE (Space Grotesk)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get titleLarge => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static TextStyle get titleSmall => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════
  //  BODY — QUIET AND READABLE (Manrope)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.1,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.15,
  );

  // ═══════════════════════════════════════════════════════════════
  //  LABEL — WIDE TRACKING (Space Grotesk)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get labelLarge => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.5,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 2,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 2.5,
  );

  // ═══════════════════════════════════════════════════════════════
  //  MONO / NUMBERS (Space Mono)
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get monoDisplay => TextStyle(
    fontFamily: _monoFont,
    fontSize: 64,
    fontWeight: FontWeight.w400,
    height: 0.9,
    letterSpacing: -3,
  );

  static TextStyle get monoLarge => TextStyle(
    fontFamily: _monoFont,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: -1,
  );

  static TextStyle get monoIndex => TextStyle(
    fontFamily: _monoFont,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 0.88,
  );

  static TextStyle get mono => TextStyle(
    fontFamily: _monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0,
  );

  static TextStyle get monoSmall => TextStyle(
    fontFamily: _monoFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════
  //  CONSTANTS & EXTRAS
  // ═══════════════════════════════════════════════════════════════

  static TextStyle get navLabel => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 3,
  );

  static TextStyle get sectionMarker => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 4,
  );

  static TextStyle get displayHero => displayMassive;

  // ═══════════════════════════════════════════════════════════════
  //  EMPHASIS VARIANTS — bolder weights for interactive/highlight use
  // ═══════════════════════════════════════════════════════════════

  /// headlineMedium but bolder (w700) — price highlights, key metrics
  static TextStyle get headlineMediumBold => headlineMedium.copyWith(fontWeight: FontWeight.w700);

  /// titleLarge but semi-bold (w600) — card titles, list item names
  static TextStyle get titleLargeBold => titleLarge.copyWith(fontWeight: FontWeight.w600);

  /// titleMedium but semi-bold (w600) — avatar initials, sub-card titles
  static TextStyle get titleMediumBold => titleMedium.copyWith(fontWeight: FontWeight.w600);

  /// titleSmall but semi-bold (w600) — chips, action labels, section labels
  static TextStyle get titleSmallBold => titleSmall.copyWith(fontWeight: FontWeight.w600);

  /// bodySmall but semi-bold (w600) — inline badges, bold captions
  static TextStyle get bodySmallBold => bodySmall.copyWith(fontWeight: FontWeight.w600);

  /// Tiny tag/badge — 10px semi-bold for role tags, status badges
  static TextStyle get tagBadge => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.7,
    letterSpacing: 0.15,
  );

  /// Caption tiny — 10px for secondary metadata
  static TextStyle get captionTiny => TextStyle(
    fontFamily: _bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.15,
  );

  // ═══════════════════════════════════════════════════════════════
  //  BRAND / AUTH — recurring patterns in splash, onboarding, auth
  // ═══════════════════════════════════════════════════════════════

  /// Brand title — displayLarge tightened for logo contexts
  static TextStyle get displayBrand => displayLarge.copyWith(letterSpacing: -2);

  /// Brand subtitle — wide-spaced display for "ALUGUEL" type text
  static TextStyle get displaySubtitle => displayMedium.copyWith(
    fontWeight: FontWeight.w400,
    letterSpacing: 8,
  );

  /// Animated section index — mono at 80px (splash/auth "00"/"01")
  static TextStyle get monoHero => TextStyle(
    fontFamily: _monoFont,
    fontSize: 80,
    fontWeight: FontWeight.w400,
    height: 0.9,
    letterSpacing: -4,
  );

  /// Giant decorative number — mono at 120px (photo gallery)
  static TextStyle get monoGiant => TextStyle(
    fontFamily: _monoFont,
    fontSize: 120,
    fontWeight: FontWeight.w400,
    height: 0.9,
    letterSpacing: -3,
  );

  /// Mono input field — 14px with subtle spacing (auth text fields)
  static TextStyle get monoInput => TextStyle(
    fontFamily: _monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.5,
  );

  /// Mono small with wide spacing — photo counters
  static TextStyle get monoSmallWide => monoSmall.copyWith(letterSpacing: 1);

  /// CTA button label — bold, wide-spaced (gradient buttons)
  static TextStyle get buttonLabel => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 3,
  );

  /// Input field label — small caps above text fields
  static TextStyle get inputLabel => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 3,
  );

  /// Property card tag — compact label for "NOVO", "DESTAQUE"
  static TextStyle get propertyTag => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════
  //  MORE WEIGHT VARIANTS
  // ═══════════════════════════════════════════════════════════════

  /// headlineLarge but bolder (w700) — rank numbers
  static TextStyle get headlineLargeBold => headlineLarge.copyWith(fontWeight: FontWeight.w700);

  /// titleMedium accent (w700) — price emphasis
  static TextStyle get titleMediumAccent => titleMedium.copyWith(fontWeight: FontWeight.w700);

  /// titleSmall accent (w700) — price/value text
  static TextStyle get titleSmallAccent => titleSmall.copyWith(fontWeight: FontWeight.w700);

  /// Section action label — labelLarge with widest spacing
  static TextStyle get labelAction => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 4,
  );

  /// Nav bar label (active)
  static TextStyle get navLabelActive => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0.3,
  );

  /// Nav bar label (inactive)
  static TextStyle get navLabelInactive => TextStyle(
    fontFamily: _headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 0,
  );
}
