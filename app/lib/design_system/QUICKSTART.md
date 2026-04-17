# Design System - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1️⃣ Import the Design System
```dart
import 'package:your_app/src/design_system/design_system.dart';
```

### 2️⃣ Setup Your App Theme
```dart
MaterialApp(
  title: 'My App',
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system, // Follows device preference
  home: const HomePage(),
)
```

### 3️⃣ Use Design Tokens
```dart
// Colors
Container(
  color: AppColors.darkBackground,
  child: Text(
    'Hello World',
    style: TextStyle(color: AppColors.primary),
  ),
)

// Typography
Text('Heading', style: AppTypography.headlineLarge)
Text('Body', style: AppTypography.bodyMedium)

// Spacing
Padding(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: Column(
    spacing: AppSpacing.md,
    children: [...],
  ),
)

// Radius
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.borderLg,
  ),
)
```

### 4️⃣ Use Components
```dart
// Button
AppButton(
  label: 'Click Me',
  onPressed: () => print('Clicked!'),
)

// Card
AppCard(
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Text('Content'),
  ),
)

// Text Field
AppTextField(
  hintText: 'Enter text',
  onChanged: (value) => print(value),
)

// Bottom Navigation
AppBottomNav(
  selectedIndex: 0,
  items: const ['Home', 'Search', 'Profile'],
  onTap: (index) {},
)
```

### 5️⃣ Add Effects
```dart
// Page transitions
PageView(
  children: [
    CurtainPageTransition(child: Page1()),
    CirclePageTransition(child: Page2()),
  ],
)

// Scroll animations
ScrollReveal(
  child: MyWidget(),
)
```

## 📁 What's Where?

| Folder | Purpose | Example |
|--------|---------|---------|
| `tokens/` | Color, typography, spacing, etc | `AppColors.primary` |
| `theme/` | Material 3 theme config | `AppTheme.dark` |
| `components/` | UI widgets | `AppButton(...)` |
| `effects/` | Animations | `CurtainPageTransition(...)` |
| `utils/` | Helper functions | `AppColors.primary.lighten()` |

## 🎨 Design Tokens at a Glance

### Colors
```dart
AppColors.primary           // Main color
AppColors.success           // Green
AppColors.error             // Red
AppColors.warning           // Yellow
AppColors.darkBackground    // Dark theme bg
AppColors.lightBackground   // Light theme bg
```

### Typography Scales
```dart
AppTypography.displayLarge      // 48px, bold
AppTypography.headlineLarge     // 22px, section headers
AppTypography.titleLarge        // 16px, small headers
AppTypography.bodyLarge         // 15px, body text
AppTypography.labelLarge        // 12px, labels
AppTypography.monoLarge         // 32px, numbers
```

### Spacing (4px base grid)
```dart
AppSpacing.xs       // 4px
AppSpacing.sm       // 8px
AppSpacing.md       // 12px
AppSpacing.lg       // 16px
AppSpacing.xl       // 20px
AppSpacing.xxl      // 24px
AppSpacing.xxxl     // 32px
```

### Radius
```dart
AppRadius.xs        // 4px
AppRadius.sm        // 8px
AppRadius.md        // 12px
AppRadius.lg        // 16px
AppRadius.xl        // 20px
AppRadius.xxl       // 24px
AppRadius.full      // 9999px (pill-shaped)
```

## 🧩 Component Library Overview

### Core (9 components)
- `AppButton` - Primary button
- `AppCard` - Container
- `AppTextField` - Text input
- `AppBottomNav` - Bottom navigation
- `AppChip` - Tag/label
- `AppAvatar` - Profile picture
- `AppBadge` - Count indicator
- `AppListTile` - List item
- `AppBottomSheet` - Modal

### Creative (6 components)
- `CinematicHero` - Hero animation
- `NumberedCard` - Card with number
- `PastelChip` - Pastel color chip
- `AdvancedCards` - Multiple variants
- `RevealText` - Text reveal
- `GlassButton` - Glass-morphism

### Navigation (3 components)
- `MinimalNav` - Clean navigation
- `BulletNav` - Bullet-point nav
- `CreativeNav` - Creative patterns

### Specialized (1 component)
- `ProjectListItem` - Portfolio item

## 📐 Constants

Common values for consistency:

```dart
// Timing
const kAnimationDuration = Duration(milliseconds: 300);
const kShortAnimationDuration = Duration(milliseconds: 150);
const kLongAnimationDuration = Duration(milliseconds: 500);

// Sizes
const kMinTouchSize = 48;           // Touch target
const kIconSizeMedium = 24;         // Icon size
const kAvatarSizeMedium = 48;       // Avatar

// Opacity
const kOpacityHover = 0.08;
const kOpacityFocus = 0.12;
const kOpacityPressed = 0.16;
```

## 🛠️ Useful Extensions

```dart
// Color extensions
AppColors.darkBackground.lighten(amount: 0.2)
AppColors.primary.darken(amount: 0.1)
AppColors.primary.blend(AppColors.secondary, 0.5)
AppColors.darkBackground.textColorOnBg  // Auto white/black

// TextStyle extensions
AppTypography.bodyMedium.withOpacity(0.7)
AppTypography.titleLarge.withLetterSpacing(2.0)
AppTypography.bodyLarge.withLineHeight(1.8)
```

## 📱 Responsive Layout Example

```dart
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile 
        ? AppSpacing.screenHorizontalCompact  // 16px
        : AppSpacing.screenHorizontal,         // 20px
    ),
    child: Column(
      spacing: AppSpacing.lg,  // 16px between items
      children: [
        Text('Title', style: AppTypography.headlineLarge),
        Text('Body', style: AppTypography.bodyMedium),
      ],
    ),
  );
}
```

## 🎬 Page Transition Example

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        CurtainPageTransition(
          child: const Page1(),
        ),
        CirclePageTransition(
          child: const Page2(),
        ),
        GlitchPageTransition(
          child: const Page3(),
        ),
      ],
    );
  }
}
```

## 🎨 Dark/Light Theme Toggle

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MyHomePage(
        onThemeChange: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
```

## 📝 Common Patterns

### Button with Icon
```dart
AppButton(
  label: 'Settings',
  icon: Icons.settings,
  onPressed: () {},
)
```

### Custom Card
```dart
AppCard(
  child: Column(
    children: [
      Text('Title', style: AppTypography.headlineMedium),
      SizedBox(height: AppSpacing.md),
      Text('Description', style: AppTypography.bodyMedium),
    ],
  ),
)
```

### List with Padding
```dart
ListView(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.screenHorizontal,
    vertical: AppSpacing.screenVertical,
  ),
  children: [
    AppListTile(
      title: 'Item 1',
      onTap: () {},
    ),
    AppListTile(
      title: 'Item 2',
      onTap: () {},
    ),
  ],
)
```

## 🚨 Common Mistakes to Avoid

❌ **Don't**: Hardcode colors
```dart
Container(color: Color(0xFF0F0F0F))
```

✅ **Do**: Use design tokens
```dart
Container(color: AppColors.darkBackground)
```

---

❌ **Don't**: Use arbitrary spacing
```dart
SizedBox(height: 15)
```

✅ **Do**: Use spacing scale
```dart
SizedBox(height: AppSpacing.md)
```

---

❌ **Don't**: Create custom text styles
```dart
TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
```

✅ **Do**: Use typography scale
```dart
AppTypography.bodyMedium
```

## 📚 Full Documentation

- **README.md** - Complete design system documentation
- **STRUCTURE.md** - Directory structure and organization
- **Component Files** - Individual component implementations

## 🎯 Next Steps

1. ✅ Read this guide
2. ✅ Import design_system in your app
3. ✅ Setup theme in MaterialApp
4. ✅ Start using components and tokens
5. ✅ Refer to README.md for detailed info

## 💡 Pro Tips

1. **Use barrel exports** for cleaner imports
2. **Extend components** instead of modifying them
3. **Use Theme.of(context)** for dynamic styling
4. **Check constants.dart** for common values
5. **Use extensions** for common operations

---

Happy designing! 🎨
