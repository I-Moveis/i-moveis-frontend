import 'dart:math';
import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/tokens/app_spacing.dart';

// =============================================================================
//  1. FULLSCREEN MENU
//  Overlay fullscreen navigation inspired by p5aholic / LQVE.
//  Covers entire screen with dark blurred background. Menu items in MASSIVE
//  typography animate staggered from the left. Close (X) top-right.
// =============================================================================

/// Data model for a fullscreen menu entry.
class FullscreenMenuItem {
  const FullscreenMenuItem({
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
}

/// Data model for a social link shown at the bottom of the fullscreen menu.
class SocialLink {
  const SocialLink({
    required this.label,
    this.url,
    this.icon,
    this.onTap,
  });

  final String label;
  final String? url;
  final IconData? icon;
  final VoidCallback? onTap;
}

/// Overlay fullscreen navigation (p5aholic / LQVE style).
///
/// Usage:
/// ```dart
/// FullscreenMenu(
///   isOpen: _menuOpen,
///   items: [ FullscreenMenuItem(label: 'Work', onTap: () {}) ],
///   currentIndex: 0,
///   onClose: () => setState(() => _menuOpen = false),
/// )
/// ```
class FullscreenMenu extends StatefulWidget {
  const FullscreenMenu({
    required this.isOpen, required this.items, required this.onClose, super.key,
    this.currentIndex = 0,
    this.socialLinks = const [],
    this.backgroundColor,
    this.textColor,
    this.activeTextColor,
    this.indexColor,
  });

  final bool isOpen;
  final List<FullscreenMenuItem> items;
  final VoidCallback onClose;
  final int currentIndex;
  final List<SocialLink> socialLinks;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? activeTextColor;
  final Color? indexColor;

  @override
  State<FullscreenMenu> createState() => _FullscreenMenuState();
}

class _FullscreenMenuState extends State<FullscreenMenu>
    with TickerProviderStateMixin {
  late final AnimationController _overlayController;
  late final Animation<double> _overlayOpacity;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<Offset>> _itemSlides = [];
  final List<Animation<double>> _itemFades = [];

  late AnimationController _closeButtonController;
  late Animation<double> _closeButtonFade;
  late Animation<double> _closeButtonRotation;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _overlayOpacity = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );

    _closeButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _closeButtonFade = CurvedAnimation(
      parent: _closeButtonController,
      curve: const Interval(0, 1, curve: Curves.easeOut),
    );
    _closeButtonRotation = Tween<double>(begin: -0.25, end: 0).animate(
      CurvedAnimation(
        parent: _closeButtonController,
        curve: Curves.easeOut,
      ),
    );

    _buildItemAnimations();

    if (widget.isOpen) {
      _playOpen();
    }
  }

  void _buildItemAnimations() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    _itemControllers.clear();
    _itemSlides.clear();
    _itemFades.clear();

    for (var i = 0; i < widget.items.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final slide = Tween<Offset>(
        begin: const Offset(-0.15, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
      final fade = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );
      _itemControllers.add(controller);
      _itemSlides.add(slide);
      _itemFades.add(fade);
    }
  }

  @override
  void didUpdateWidget(FullscreenMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      _buildItemAnimations();
    }

    if (widget.isOpen && !oldWidget.isOpen) {
      _playOpen();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _playClose();
    }
  }

  Future<void> _playOpen() async {
    _overlayController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _closeButtonController.forward();
    for (var i = 0; i < _itemControllers.length; i++) {
      Future<void>.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted && i < _itemControllers.length) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  Future<void> _playClose() async {
    _closeButtonController.reverse();
    for (var i = _itemControllers.length - 1; i >= 0; i--) {
      Future<void>.delayed(
          Duration(milliseconds: 40 * (_itemControllers.length - 1 - i)), () {
        if (mounted && i < _itemControllers.length) {
          _itemControllers[i].reverse();
        }
      });
    }
    await Future<void>.delayed(Duration(
      milliseconds: 40 * _itemControllers.length + 200,
    ));
    if (mounted) {
      _overlayController.reverse();
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _closeButtonController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.black.withValues(alpha: 0.96);
    final textCol = widget.textColor ?? AppColors.whiteMuted;
    final activeCol = widget.activeTextColor ?? AppColors.white;
    final idxCol = widget.indexColor ?? AppColors.whiteFaint;

    return AnimatedBuilder(
      animation: _overlayOpacity,
      builder: (context, child) {
        if (_overlayOpacity.value == 0.0 && !widget.isOpen) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: _overlayOpacity.value,
          child: child,
        );
      },
      child: Material(
        color: bg,
        child: SizedBox.expand(
          child: SafeArea(
            child: Stack(
              children: [
                // --- Menu items ---
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.huge,
                      vertical: AppSpacing.gigantic,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.items.length, (i) {
                        final item = widget.items[i];
                        final isActive = i == widget.currentIndex;
                        final indexStr =
                            (i + 1).toString().padLeft(2, '0');

                        return SlideTransition(
                          position: i < _itemSlides.length
                              ? _itemSlides[i]
                              : const AlwaysStoppedAnimation(Offset.zero),
                          child: FadeTransition(
                            opacity: i < _itemFades.length
                                ? _itemFades[i]
                                : const AlwaysStoppedAnimation(1),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                item.onTap?.call();
                                widget.onClose();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    // Index number
                                    SizedBox(
                                      width: 48,
                                      child: Text(
                                        indexStr,
                                        style:
                                            AppTypography.mono.copyWith(
                                          color: isActive
                                              ? activeCol
                                              : idxCol,
                                          fontSize: 13,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    // Label
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.label,
                                            style: AppTypography
                                                .displayLarge
                                                .copyWith(
                                              color: isActive
                                                  ? activeCol
                                                  : textCol,
                                              fontSize: 56,
                                            ),
                                          ),
                                          if (item.subtitle != null) ...[
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              item.subtitle!,
                                              style: AppTypography
                                                  .bodySmall
                                                  .copyWith(
                                                color: idxCol,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Active indicator
                                    if (isActive)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: activeCol,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // --- Close button (X) top-right ---
                Positioned(
                  top: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: FadeTransition(
                    opacity: _closeButtonFade,
                    child: RotationTransition(
                      turns: _closeButtonRotation,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.whiteFaint.withValues(alpha: 0.3),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: activeCol,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Social links at bottom ---
                if (widget.socialLinks.isNotEmpty)
                  Positioned(
                    bottom: AppSpacing.xxl,
                    left: AppSpacing.huge,
                    right: AppSpacing.huge,
                    child: FadeTransition(
                      opacity: _closeButtonFade,
                      child: Row(
                        children: widget.socialLinks.map((link) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xxl,
                            ),
                            child: GestureDetector(
                              onTap: link.onTap,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (link.icon != null) ...[
                                    Icon(
                                      link.icon,
                                      color: idxCol,
                                      size: 14,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                  ],
                                  Text(
                                    link.label.toUpperCase(),
                                    style:
                                        AppTypography.labelMedium.copyWith(
                                      color: idxCol,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  2. SIDEBAR NAV
//  Fixed vertical sidebar inspired by punchred.xyz.
//  Vertical text labels, active indicator line, collapse/expand.
// =============================================================================

/// Data model for a sidebar navigation item.
class SidebarNavItem {
  const SidebarNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Vertical sidebar navigation (punchred.xyz style).
///
/// Place it in a [Row] with your main content.
/// ```dart
/// Row(children: [
///   SidebarNav(items: [...], currentIndex: 0, onItemTap: (i) {}),
///   Expanded(child: content),
/// ])
/// ```
class SidebarNav extends StatefulWidget {
  const SidebarNav({
    required this.items, super.key,
    this.currentIndex = 0,
    this.onItemTap,
    this.expanded = true,
    this.onToggle,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.collapsedWidth = 64,
    this.expandedWidth = 200,
  });

  final List<SidebarNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onItemTap;
  final bool expanded;
  final VoidCallback? onToggle;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? indicatorColor;
  final double collapsedWidth;
  final double expandedWidth;

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends State<SidebarNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.expanded ? 1.0 : 0.0,
    );
    _widthFactor = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(SidebarNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.darkSurface;
    final activeCol = widget.activeColor ?? AppColors.white;
    final inactiveCol = widget.inactiveColor ?? AppColors.whiteFaint;
    final indicatorCol = widget.indicatorColor ?? AppColors.white;

    return AnimatedBuilder(
      animation: _widthFactor,
      builder: (context, _) {
        final w = _lerpDouble(
          widget.collapsedWidth,
          widget.expandedWidth,
          _widthFactor.value,
        );

        return Container(
          width: w,
          color: bg,
          child: SafeArea(
            right: false,
            child: Column(
              children: [
                // Toggle button
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AnimatedRotation(
                      turns: widget.expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.chevron_right,
                        color: inactiveCol,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.items.length,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      final item = widget.items[i];
                      final isActive = i == widget.currentIndex;

                      return GestureDetector(
                        onTap: () {
                          widget.onItemTap?.call(i);
                          item.onTap?.call();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isActive
                                    ? indicatorCol
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon (always visible)
                              SizedBox(
                                width: widget.collapsedWidth,
                                child: Center(
                                  child: Icon(
                                    item.icon,
                                    color: isActive ? activeCol : inactiveCol,
                                    size: 20,
                                  ),
                                ),
                              ),
                              // Label (visible when expanded)
                              if (_widthFactor.value > 0.3)
                                Expanded(
                                  child: Opacity(
                                    opacity:
                                        ((_widthFactor.value - 0.3) / 0.7)
                                            .clamp(0.0, 1.0),
                                    child: Text(
                                      item.label.toUpperCase(),
                                      style:
                                          AppTypography.labelLarge.copyWith(
                                        color: isActive
                                            ? activeCol
                                            : inactiveCol,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Linear interpolation helper for two doubles.
double _lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}

// =============================================================================
//  3. FLOATING NAV
//  Floating pill navigation inspired by LQVE.
//  Glass/blur background, compact icon + label items, auto-hide on scroll.
// =============================================================================

/// Data model for a floating navigation item.
class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Floating pill navigation (LQVE style).
///
/// Wrap your scrollable content and pass its [ScrollController].
/// The pill auto-hides on scroll-down, reappears on scroll-up.
///
/// ```dart
/// FloatingNav(
///   items: [ FloatingNavItem(icon: Icons.home, label: 'Home') ],
///   currentIndex: 0,
///   onItemTap: (i) {},
///   scrollController: _scrollController,
///   child: ListView(..., controller: _scrollController),
/// )
/// ```
class FloatingNav extends StatefulWidget {
  const FloatingNav({
    required this.items, super.key,
    this.currentIndex = 0,
    this.onItemTap,
    this.scrollController,
    this.child,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.activeFillColor,
    this.bottomPadding = 32,
  });

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onItemTap;
  final ScrollController? scrollController;
  final Widget? child;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeFillColor;
  final double bottomPadding;

  @override
  State<FloatingNav> createState() => _FloatingNavState();
}

class _FloatingNavState extends State<FloatingNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _visibilityController;
  late final Animation<Offset> _slideAnimation;
  double _lastScrollOffset = 0;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutCubic,
    ));

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(FloatingNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return;

    final current = sc.offset;
    final delta = current - _lastScrollOffset;

    if (delta > 8 && _isVisible && current > 50) {
      _isVisible = false;
      _visibilityController.reverse();
    } else if (delta < -8 && !_isVisible) {
      _isVisible = true;
      _visibilityController.forward();
    }

    _lastScrollOffset = current;
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg =
        widget.backgroundColor ?? AppColors.blackLight.withValues(alpha: 0.85);
    final activeCol = widget.activeColor ?? AppColors.white;
    final inactiveCol = widget.inactiveColor ?? AppColors.whiteMuted;
    final activeFill =
        widget.activeFillColor ?? AppColors.white.withValues(alpha: 0.1);

    final pill = SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: widget.bottomPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.glassBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (i) {
            final item = widget.items[i];
            final isActive = i == widget.currentIndex;

            return GestureDetector(
              onTap: () {
                widget.onItemTap?.call(i);
                item.onTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isActive ? activeFill : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isActive ? activeCol : inactiveCol,
                      size: 18,
                    ),
                    if (isActive) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        item.label.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: activeCol,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );

    if (widget.child != null) {
      return Stack(
        children: [
          widget.child!,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(child: pill),
          ),
        ],
      );
    }

    return pill;
  }
}

// =============================================================================
//  4. BREADCRUMB NAV
//  Minimalist breadcrumb navigation inspired by obake.blue.
//  Path-like navigation with slash separators, monospace font.
// =============================================================================

/// A single breadcrumb segment.
class BreadcrumbItem {
  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}

/// Minimalist breadcrumb navigation (obake.blue style).
///
/// ```dart
/// BreadcrumbNav(
///   items: [
///     BreadcrumbItem(label: 'Home', onTap: () {}),
///     BreadcrumbItem(label: 'Projects', onTap: () {}),
///     BreadcrumbItem(label: 'Detail'),
///   ],
/// )
/// ```
class BreadcrumbNav extends StatelessWidget {
  const BreadcrumbNav({
    required this.items, super.key,
    this.separator = '/',
    this.textColor,
    this.activeColor,
    this.separatorColor,
    this.useMono = true,
    this.fontSize,
  });

  final List<BreadcrumbItem> items;
  final String separator;
  final Color? textColor;
  final Color? activeColor;
  final Color? separatorColor;
  final bool useMono;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        useMono ? AppTypography.monoSmall : AppTypography.bodySmall;
    final fs = fontSize ?? baseStyle.fontSize ?? 11;
    final txtCol = textColor ?? AppColors.whiteMuted;
    final activeCol = activeColor ?? AppColors.white;
    final sepCol = separatorColor ?? AppColors.whiteFaint;

    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(max(0, items.length * 2 - 1), (i) {
          // Even indices are items, odd are separators
          if (i.isOdd) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                separator,
                style: baseStyle.copyWith(
                  color: sepCol,
                  fontSize: fs,
                ),
              ),
            );
          }

          final itemIndex = i ~/ 2;
          final item = items[itemIndex];
          final isLast = itemIndex == items.length - 1;

          return GestureDetector(
            onTap: isLast ? null : item.onTap,
            child: MouseRegion(
              cursor: isLast
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              child: Text(
                item.label,
                style: baseStyle.copyWith(
                  color: isLast ? activeCol : txtCol,
                  fontSize: fs,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
//  5. PROGRESS NAV
//  Scroll progress indicator inspired by Starpeggio.
//  Fixed side dots or top progress bar showing current section.
//  Clickable to jump to sections. Smooth animated indicator.
// =============================================================================

/// A section for the progress nav.
class ProgressNavSection {
  const ProgressNavSection({
    required this.label,
    this.key,
  });

  final String label;
  final GlobalKey? key;
}

/// Which visual mode the progress nav uses.
enum ProgressNavMode {
  /// Vertical dots on the side.
  dots,

  /// Horizontal progress bar at the top.
  bar,
}

/// Scroll progress indicator (Starpeggio style).
///
/// In [ProgressNavMode.dots] mode, renders a vertical column of dots
/// fixed on the right side. In [ProgressNavMode.bar] mode, renders
/// a thin progress bar at the top.
///
/// ```dart
/// ProgressNav(
///   sections: [
///     ProgressNavSection(label: 'Intro', key: _introKey),
///     ProgressNavSection(label: 'Work', key: _workKey),
///     ProgressNavSection(label: 'Contact', key: _contactKey),
///   ],
///   currentIndex: _currentSection,
///   scrollProgress: _scrollFraction,
///   onSectionTap: (i) { /* scroll to section */ },
/// )
/// ```
class ProgressNav extends StatefulWidget {
  const ProgressNav({
    required this.sections, super.key,
    this.currentIndex = 0,
    this.scrollProgress = 0.0,
    this.onSectionTap,
    this.mode = ProgressNavMode.dots,
    this.activeColor,
    this.inactiveColor,
    this.barColor,
    this.barBackgroundColor,
    this.dotSize = 10.0,
    this.barHeight = 3.0,
    this.showLabels = true,
  });

  final List<ProgressNavSection> sections;
  final int currentIndex;
  final double scrollProgress;
  final ValueChanged<int>? onSectionTap;
  final ProgressNavMode mode;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? barColor;
  final Color? barBackgroundColor;
  final double dotSize;
  final double barHeight;
  final bool showLabels;

  @override
  State<ProgressNav> createState() => _ProgressNavState();
}

class _ProgressNavState extends State<ProgressNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _indicatorController;
  late Animation<double> _indicatorPosition;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _previousIndex = widget.currentIndex;
    _indicatorPosition = AlwaysStoppedAnimation(
      widget.currentIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(ProgressNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _indicatorPosition = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOutCubic,
      ));
      _previousIndex = widget.currentIndex;
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == ProgressNavMode.bar) {
      return _buildBar(context);
    }
    return _buildDots(context);
  }

  Widget _buildBar(BuildContext context) {
    final barCol = widget.barColor ?? AppColors.white;
    final barBg = widget.barBackgroundColor ?? AppColors.blackLighter;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        SizedBox(
          height: widget.barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Stack(
                children: [
                  // Background
                  Container(
                    width: totalWidth,
                    height: widget.barHeight,
                    color: barBg,
                  ),
                  // Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width:
                        totalWidth * widget.scrollProgress.clamp(0.0, 1.0),
                    height: widget.barHeight,
                    color: barCol,
                  ),
                ],
              );
            },
          ),
        ),
        // Section labels
        if (widget.showLabels)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.sections.length, (i) {
                final section = widget.sections[i];
                final isActive = i == widget.currentIndex;

                return GestureDetector(
                  onTap: () => widget.onSectionTap?.call(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      section.label.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive
                            ? (widget.activeColor ?? AppColors.white)
                            : (widget.inactiveColor ??
                                AppColors.whiteFaint),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildDots(BuildContext context) {
    final activeCol = widget.activeColor ?? AppColors.white;
    final inactiveCol = widget.inactiveColor ?? AppColors.whiteFaint;
    final dotSpacing = widget.dotSize * 2.5;

    return AnimatedBuilder(
      animation: _indicatorController,
      builder: (context, _) {
        final animatedIndex = _indicatorPosition.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.sections.length, (i) {
            final section = widget.sections[i];
            final isActive = i == widget.currentIndex;
            final distFromIndicator = (i - animatedIndex).abs();
            final proximity = (1.0 - distFromIndicator).clamp(0.0, 1.0);

            // Dot size scales based on proximity to the animated indicator
            final currentDotSize =
                widget.dotSize * 0.5 + widget.dotSize * 0.5 * proximity;
            final currentColor =
                Color.lerp(inactiveCol, activeCol, proximity)!;

            return GestureDetector(
              onTap: () => widget.onSectionTap?.call(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: dotSpacing,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: currentDotSize,
                      height: currentDotSize,
                      decoration: BoxDecoration(
                        color: isActive ? activeCol : Colors.transparent,
                        border: Border.all(
                          color: currentColor,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Label
                    if (widget.showLabels) ...[
                      const SizedBox(width: AppSpacing.md),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTypography.labelSmall.copyWith(
                          color: currentColor,
                          letterSpacing: isActive ? 3.0 : 2.5,
                        ),
                        child: Text(section.label.toUpperCase()),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
