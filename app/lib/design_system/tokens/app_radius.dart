import 'package:flutter/material.dart';

/// Design tokens: Border radius
///
/// Rounded, friendly shapes inspired by Airbnb's warm aesthetic
/// combined with McShannock's clean precision.
abstract final class AppRadius {
  /// 0px - Sharp corners
  static const none = 0.0;

  /// 1px - Subtle rounding
  static const xs = 1.0;

  /// 2px - Small rounding (chips, small cards)
  static const sm = 2.0;

  /// 4px - Default rounding (cards, inputs)
  static const md = 4.0;

  /// 6px - Medium rounding (modals, sheets)
  static const lg = 6.0;

  /// 8px - Large rounding (image cards)
  static const xl = 8.0;

  /// 10px - Extra large (featured cards)
  static const xxl = 10.0;

  /// 12px - Full/pill shape (buttons, badges)
  static const full = 12.0;

  /// 16px - Pill shape (nav items, tags)
  static const pill = 16.0;

  /// 24px - Round shape (chat bubbles, search bars)
  static const round = 24.0;

  // ─── Convenience BorderRadius ────────────────────────────────

  static final borderNone = BorderRadius.circular(none);
  static final borderXs = BorderRadius.circular(xs);
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderXxl = BorderRadius.circular(xxl);
  static final borderFull = BorderRadius.circular(full);
  static final borderPill = BorderRadius.circular(pill);
  static final borderRound = BorderRadius.circular(round);

  /// Top-only rounding for bottom sheets
  static const sheetTop = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
