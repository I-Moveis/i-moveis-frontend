/// Design tokens: Animation durations & curves
///
/// Consistent motion design inspired by Airbnb's conversational
/// transitions and Magic Receipt's smooth GPU-accelerated animations.
abstract final class AppDurations {
  /// 100ms - Micro interactions (opacity, color)
  static const fast = Duration(milliseconds: 100);

  /// 200ms - Default transitions (button press, chip toggle)
  static const normal = Duration(milliseconds: 200);

  /// 300ms - Medium transitions (card expand, page transition)
  static const medium = Duration(milliseconds: 300);

  /// 400ms - Slow transitions (bottom sheet, modal)
  static const slow = Duration(milliseconds: 400);

  /// 600ms - Emphasis animations (hero, onboarding)
  static const emphasis = Duration(milliseconds: 600);
}
