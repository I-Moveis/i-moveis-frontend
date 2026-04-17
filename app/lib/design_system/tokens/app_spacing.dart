/// Design tokens: Spacing scale
///
/// 4px base grid. Consistent spacing creates visual rhythm
/// inspired by McShannock's systematic approach and Airbnb's
/// generous whitespace.
abstract final class AppSpacing {
  /// 0px
  static const zero = 0.0;

  /// 2px - Tight inline spacing
  static const xxs = 2.0;

  /// 4px - Minimum spacing
  static const xs = 4.0;

  /// 6px - Small-medium inline gap
  static const xsSm = 6.0;

  /// 8px - Tight component spacing
  static const sm = 8.0;

  /// 12px - Default inner padding
  static const md = 12.0;

  /// 14px - Row/cell vertical padding
  static const mdLg = 14.0;

  /// 16px - Default component spacing
  static const lg = 16.0;

  /// 20px - Medium section spacing
  static const xl = 20.0;

  /// 24px - Section padding
  static const xxl = 24.0;

  /// 32px - Large section spacing
  static const xxxl = 32.0;

  /// 40px - Hero spacing
  static const huge = 40.0;

  /// 48px - Extra large spacing
  static const massive = 48.0;

  /// 64px - Maximum spacing
  static const gigantic = 64.0;

  // ─── Screen padding ──────────────────────────────────────────

  /// Default horizontal page padding (20px)
  static const screenHorizontal = 20.0;

  /// Default vertical page padding (24px)
  static const screenVertical = 24.0;

  /// Compact horizontal padding (16px)
  static const screenHorizontalCompact = 16.0;
}
