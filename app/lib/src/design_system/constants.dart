import 'package:flutter/material.dart';

/// Design System Constants
///
/// Global constants used across the design system for consistency,
/// including animation timings, opacity values, and other reusable values.

/// Standard animation timing
const Duration kAnimationDuration = Duration(milliseconds: 300);
const Duration kShortAnimationDuration = Duration(milliseconds: 150);
const Duration kLongAnimationDuration = Duration(milliseconds: 500);

/// Curve constants for animations
const Curve kAnimationCurve = Curves.easeInOut;
const Curve kShortAnimationCurve = Curves.easeOut;
const Curve kLongAnimationCurve = Curves.easeInOutCubic;

/// Opacity constants
const double kOpacityDisabled = 0.5;
const double kOpacityHover = 0.08;
const double kOpacityFocus = 0.12;
const double kOpacityPressed = 0.16;

/// Elevation constants
const double kElevationDefault = 0;
const double kElevationSmall = 2;
const double kElevationMedium = 4;
const double kElevationLarge = 8;
const double kElevationXL = 12;

/// Border width constants
const double kBorderWidthThin = 1.0;
const double kBorderWidthRegular = 1.5;
const double kBorderWidthThick = 2.0;

/// Icon sizes
const double kIconSizeSmall = 18;
const double kIconSizeMedium = 24;
const double kIconSizeLarge = 32;
const double kIconSizeXL = 48;
const double kIconSizeXXL = 64;

/// Min touch target size (Material Design)
const double kMinTouchSize = 48;

/// Avatar sizes
const double kAvatarSizeSmall = 32;
const double kAvatarSizeMedium = 48;
const double kAvatarSizeLarge = 72;

/// Blur radius values
const double kBlurSmall = 4;
const double kBlurMedium = 8;
const double kBlurLarge = 16;
const double kBlurXL = 32;

/// Aspect ratios
const double kImageAspectRatio = 16 / 9;
const double kSquareAspectRatio = 1;
const double kPortraitAspectRatio = 9 / 16;
