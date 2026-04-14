/// Design System — Brutalist Elegance × Japanese Creative Web
///
/// Professional, well-organized design system extracted and synthesized from
/// 7 award-winning Japanese sites:
/// - p5aholic.me (Keita Yamada) — GLSL backgrounds, brutalist typography
/// - lqve.jp — Bold creative agency, cyan accent, Suisse typography
/// - obake.blue — Numbered grid portfolio, PPNeueMachina, blue/pink
/// - midnight-grand-orchestra.jp/starpeggio — Cosmic/star aesthetic
/// - ily-girl.mikapikazo.info — Exhibition, pastel colors, dual-language
/// - midnight-grand-orchestra.jp/overture-bluray-dvd — Music release
/// - punchred.xyz — Interactive illustrator portfolio
///
/// Philosophy: Simple but audacious. Minimalist but not flat. Elegant.
///
/// Structure:
/// ```
/// lib/src/design_system/
/// ├── constants.dart              # Global design constants
/// ├── tokens/                     # Design tokens (colors, typography, etc)
/// │   ├── index.dart
/// │   ├── app_colors.dart
/// │   ├── app_typography.dart
/// │   ├── app_spacing.dart
/// │   ├── app_radius.dart
/// │   ├── app_shadows.dart
/// │   └── app_durations.dart
/// ├── theme/                      # Theme configuration
/// │   ├── index.dart
/// │   └── app_theme.dart
/// ├── components/                 # UI Components
/// │   ├── index.dart
/// │   ├── core/                   # Core Material Design components
/// │   ├── creative/               # Custom sophisticated components
/// │   ├── navigation/             # Navigation patterns
/// │   ├── specialized/            # Domain-specific components
/// │   └── [component files]
/// ├── effects/                    # Animations & effects
/// │   ├── index.dart
/// │   ├── cosmic_background.dart
/// │   ├── wave_background.dart
/// │   ├── scroll_animations.dart
/// │   └── transitions.dart
/// ├── utils/                      # Utilities & extensions
/// │   ├── index.dart
/// │   └── extensions.dart
/// └── design_system.dart          # Main export file
/// ```
library;

// ─── Tokens ────────────────────────────────────────────────────
export 'tokens/index.dart';
export 'tokens/app_colors.dart';
export 'tokens/app_typography.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_radius.dart';
export 'tokens/app_shadows.dart';
export 'tokens/app_durations.dart';

// ─── Theme ─────────────────────────────────────────────────────
export 'theme/index.dart';
export 'theme/app_theme.dart';

// ─── Components ────────────────────────────────────────────────
export 'components/index.dart';

// ─── Effects ────────────────────────────────────────────────────
export 'effects/index.dart';
export 'effects/cosmic_background.dart';
export 'effects/wave_background.dart';
export 'effects/scroll_animations.dart';
export 'effects/transitions.dart';

// ─── Constants & Utils ─────────────────────────────────────────
export 'constants.dart';
export 'utils/index.dart';
export 'utils/extensions.dart';
