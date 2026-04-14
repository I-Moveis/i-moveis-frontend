import 'package:flutter/material.dart';

/// Design tokens: Border radius
///
/// Rounded, friendly shapes inspired by Airbnb's warm aesthetic
/// combined with McShannock's clean precision.
abstract final class AppRadius {
  /// 0px - Sharp corners
  static const none = 0.0;

  /// 4px - Subtle rounding
  static const xs = 4.0;

  /// 8px - Small rounding (chips, small cards)
  static const sm = 8.0;

  /// 12px - Default rounding (cards, inputs)
  static const md = 12.0;

  /// 16px - Medium rounding (modals, sheets)
  static const lg = 16.0;

  /// 20px - Large rounding (image cards)
  static const xl = 20.0;

  /// 24px - Extra large (featured cards)
  static const xxl = 24.0;

  /// 9999px - Full/pill shape (buttons, badges)
  static const full = 9999.0;

  // ─── Convenience BorderRadius ────────────────────────────────

  static final borderNone = BorderRadius.circular(none);
  static final borderXs = BorderRadius.circular(xs);
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderXxl = BorderRadius.circular(xxl);
  static final borderFull = BorderRadius.circular(full);

  /// Top-only rounding for bottom sheets
  static final sheetTop = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
