# Design System Documentation

Professional design system built with Flutter and Material Design 3, inspired by brutalist elegance and Japanese creative web design.

## 📁 Structure

The design system is organized into clear, logical folders for easy navigation and maintenance:

```
design_system/
├── constants.dart              # Global design constants (timings, opacities, sizes)
├── design_system.dart          # Main library export (start here)
├── README.md                   # This file
│
├── tokens/                     # Design Tokens
│   ├── index.dart
│   ├── app_colors.dart         # Color palette & semantic colors
│   ├── app_typography.dart     # Text styles & font scales
│   ├── app_spacing.dart        # Spacing scale (4px base grid)
│   ├── app_radius.dart         # Border radius values
│   ├── app_shadows.dart        # Elevation & shadow definitions
│   └── app_durations.dart      # Animation timings
│
├── theme/                      # Theme Configuration
│   ├── index.dart
│   └── app_theme.dart          # Dark & Light theme setup
│
├── components/                 # UI Components
│   ├── index.dart              # Master components export
│   ├── core/                   # Core Material Design components
│   │   ├── index.dart
│   │   └── [imports from main components]
│   ├── creative/               # Custom sophisticated components
│   │   ├── index.dart
│   │   └── [imports]
│   ├── navigation/             # Navigation patterns
│   │   ├── index.dart
│   │   └── [imports]
│   ├── specialized/            # Domain-specific components
│   │   ├── index.dart
│   │   └── [imports]
│   │
│   ├── app_button.dart         # Primary button component
│   ├── app_card.dart           # Card container
│   ├── app_text_field.dart     # Text input field
│   ├── app_bottom_nav.dart     # Bottom navigation
│   ├── app_chip.dart           # Chip / tag component
│   ├── app_avatar.dart         # User avatar
│   ├── app_badge.dart          # Badge indicator
│   ├── app_list_tile.dart      # List item
│   ├── app_bottom_sheet.dart   # Bottom sheet modal
│   ├── cinematic_hero.dart     # Hero animation component
│   ├── numbered_card.dart      # Numbered card layout
│   ├── pastel_chip.dart        # Pastel-colored chip
│   ├── advanced_cards.dart     # Advanced card variants
│   ├── reveal_text.dart        # Text reveal animation
│   ├── glass_button.dart       # Glass-morphism button
│   ├── minimal_nav.dart        # Minimal navigation
│   ├── bullet_nav.dart         # Bullet-point navigation
│   ├── creative_nav.dart       # Creative navigation patterns
│   └── project_list_item.dart  # Project list item
│
├── effects/                    # Animations & Effects
│   ├── index.dart
│   ├── cosmic_background.dart  # Cosmic animated background
│   ├── wave_background.dart    # Wave animated background
│   ├── scroll_animations.dart  # Scroll-triggered animations
│   └── transitions.dart        # Page transition effects
│
└── utils/                      # Utilities & Extensions
    ├── index.dart
    └── extensions.dart         # Color, TextStyle, ThemeData extensions
```

## 🎨 Tokens

Design tokens are the atomic building blocks of the design system. They're organized into categories:

### Colors (`app_colors.dart`)
- **Brutalist Core**: Black (#0F0F0F) and white with subtle variations
- **Semantic Colors**: Success, warning, error, info
- **Glass Morphism**: Semi-transparent white overlays
- **Iridescent**: Special accent colors for highlight moments
- **Extracted Reference Tokens**: From 7 Japanese design references

**Usage:**
```dart
import 'package:your_app/src/design_system/design_system.dart';

Container(
  color: AppColors.darkBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.primary),
  ),
)
```

### Typography (`app_typography.dart`)
Comprehensive text scale with 5 font families:
- **Display**: Large, attention-grabbing text (Syne)
- **Headline**: Section headers (Space Grotesk)
- **Title**: Smaller headers (Space Grotesk)
- **Body**: Body copy (Manrope) - highly legible
- **Label**: UI labels with wide tracking (Space Grotesk)
- **Mono**: Numbers and code (Space Mono)

**Usage:**
```dart
Text(
  'Welcome',
  style: AppTypography.displayLarge,
)
```

### Spacing (`app_spacing.dart`)
4px base grid for consistent spacing:
- `xxs` (2px) → `gigantic` (64px)
- Screen-specific padding constants

**Usage:**
```dart
Padding(
  padding: const EdgeInsets.all(AppSpacing.lg), // 16px
  child: Column(
    spacing: AppSpacing.md, // 12px between items
  ),
)
```

### Radius (`app_radius.dart`)
Border radius scale from subtle to pill-shaped:
- Numeric values (0-9999)
- BorderRadius convenience helpers

**Usage:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.borderLg,
  ),
)
```

### Shadows (`app_shadows.dart`)
Elevation-based shadow definitions for Material 3.

### Durations (`app_durations.dart`)
Standard animation timings for consistent motion.

## 🎭 Theme

Material 3 theme configuration with dark and light modes.

**Usage:**
```dart
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system,
)
```

## 🧩 Components

Organized into 4 categories:

### Core Components
Essential Material Design components with consistent styling:
- `AppButton` - Primary button
- `AppCard` - Container with styling
- `AppTextField` - Text input with validation
- `AppBottomNav` - Bottom navigation bar
- `AppChip` - Selectable chip/tag
- `AppAvatar` - User profile picture
- `AppBadge` - Count/status indicator
- `AppListTile` - List item
- `AppBottomSheet` - Modal bottom sheet

**Usage:**
```dart
AppButton(
  label: 'Click me',
  onPressed: () {},
)
```

### Creative Components
Custom, sophisticated components with unique visual style:
- `CinematicHero` - Hero animation with cinematic feel
- `NumberedCard` - Card with prominent number
- `PastelChip` - Pastel-colored chip variant
- `AdvancedCards` - Multiple card variants (Glass, Music, Exhibition)
- `RevealText` - Text with reveal animation
- `GlassButton` - Glass-morphism button style

### Navigation Components
Specialized navigation patterns:
- `MinimalNav` - Minimal, clean navigation
- `BulletNav` - Bullet-point style navigation
- `CreativeNav` - Creative navigation variants (Fullscreen, Sidebar, Floating, Progress)

### Specialized Components
Domain-specific components:
- `ProjectListItem` - Portfolio project display

## ✨ Effects

Animation and motion effects for enhanced UX:

- **CosmicBackground** - Animated cosmic/space background
- **WaveBackground** - Flowing wave background animation
- **ScrollAnimations** - Scroll-triggered reveal and parallax effects
- **Transitions** - Page transition effects (Curtain, Circle, Glitch)

**Usage:**
```dart
PageView(
  children: [
    CurtainPageTransition(child: Page1()),
    CirclePageTransition(child: Page2()),
  ],
)
```

## 📐 Constants

Global constants for consistency:

```dart
import 'package:your_app/src/design_system/constants.dart';

// Animation timings
const kAnimationDuration = Duration(milliseconds: 300);

// Opacity values
const kOpacityHover = 0.08;

// Icon sizes
const kIconSizeMedium = 24;

// Touch target sizes
const kMinTouchSize = 48;
```

## 🛠 Utils & Extensions

Helpful extensions for common operations:

### Color Extensions
```dart
final lightColor = AppColors.darkBackground.lighten(amount: 0.2);
final darkColor = AppColors.primary.darken(amount: 0.1);
final blended = AppColors.primary.blend(AppColors.secondary, 0.5);
final textColor = AppColors.darkBackground.textColorOnBg; // Auto white/black
```

### TextStyle Extensions
```dart
final styled = AppTypography.bodyMedium.withOpacity(0.7);
final spaced = AppTypography.titleLarge.withLetterSpacing(2.0);
```

## 🎯 Usage Examples

### Basic Button with Theme
```dart
AppButton(
  label: 'Submit',
  onPressed: () => print('Clicked'),
)
```

### Custom Card Layout
```dart
AppCard(
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Text('Title', style: AppTypography.titleLarge),
        SizedBox(height: AppSpacing.md),
        Text('Description', style: AppTypography.bodyMedium),
      ],
    ),
  ),
)
```

### Responsive Layout
```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.screenHorizontal,
    vertical: AppSpacing.screenVertical,
  ),
  child: Column(
    spacing: AppSpacing.lg,
    children: [...],
  ),
)
```

### Dark/Light Theme Toggle
```dart
// App automatically respects system theme
// Or set manually:
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system, // Follow system preference
)
```

## 📖 Design Philosophy

- **Simple but Audacious**: Minimalist but not flat
- **Elegant Brutalism**: Bold contrast (black/white) with restrained color
- **Japanese Aesthetic**: Inspired by award-winning Japanese web design
- **Functional Animation**: Motion serves purpose, not just decoration
- **Accessibility First**: Proper contrast ratios and touch targets
- **Material 3 Compliant**: Modern Flutter best practices

## 🚀 Best Practices

1. **Always use tokens**, never hardcode values
2. **Use index exports** for organized imports:
   ```dart
   import 'design_system/tokens/index.dart';
   import 'design_system/components/index.dart';
   ```
3. **Extend components** instead of modifying originals
4. **Use Theme context** for dynamic styling:
   ```dart
   Theme.of(context).colorScheme.primary
   ```
5. **Prefer constants** from `constants.dart` for reusable values
6. **Use extensions** for common operations

## 📝 Adding New Components

When adding a new component:

1. Create file in appropriate category folder
2. Follow naming convention: `my_component.dart`
3. Add export to category `index.dart`
4. Add import to main `components/index.dart`
5. Update this README with component description

Example structure:
```dart
import 'package:flutter/material.dart';
import '../tokens/index.dart';

class MyComponent extends StatelessWidget {
  const MyComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppRadius.borderMd,
      ),
      child: const Text('Component'),
    );
  }
}
```

## 🎨 Color Usage Guidelines

- **Primary**: Main actions and focus
- **Secondary**: Supporting elements
- **Success/Error/Warning**: Semantic meaning only
- **Iridescent**: Special moments and highlights (use sparingly)
- **Glass**: Subtle overlays and effects
- **Text Colors**: Use semantic text colors for contrast and theme switching

## 📱 Responsive Design

Use tokens for responsive layouts:

```dart
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile 
        ? AppSpacing.screenHorizontalCompact 
        : AppSpacing.screenHorizontal,
    ),
    child: Column(...),
  );
}
```

---

For more information or to contribute to the design system, refer to the component files directly.
