import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. ScrollReveal
// ---------------------------------------------------------------------------
/// Direction from which the widget enters during its reveal animation.
enum RevealDirection { up, down, left, right, fade }

/// A widget that animates into view when it first becomes visible inside a
/// scrollable ancestor.
///
/// Inspired by the reveal-on-scroll patterns seen on p5aholic, LQVE and
/// obake.blue portfolios. The animation fires only once -- scrolling back
/// up will *not* re-trigger it.
///
/// Works without any third-party visibility-detection package by measuring
/// the widget's position relative to the nearest [Scrollable] viewport.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    required this.child, super.key,
    this.direction = RevealDirection.up,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.offset = 60.0,
    this.visibleThreshold = 0.15,
  });

  /// The widget to reveal.
  final Widget child;

  /// Direction the widget slides in from. [RevealDirection.fade] applies a
  /// pure opacity fade with no translation.
  final RevealDirection direction;

  /// How long the entrance animation takes.
  final Duration duration;

  /// Optional delay before the animation starts once visibility is detected.
  final Duration delay;

  /// Easing curve for the animation.
  final Curve curve;

  /// Translation distance in logical pixels (ignored for [RevealDirection.fade]).
  final double offset;

  /// Fraction of the widget that must be inside the viewport before the
  /// animation triggers (0.0 = top edge enters, 1.0 = fully visible).
  final double visibleThreshold;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curvedAnimation;
  bool _hasTriggered = false;
  final GlobalKey _itemKey = GlobalKey();
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;
    final box = _itemKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final screenPos = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = box.size.height;

    final visibleTop = max(0, screenPos.dy);
    final visibleBottom = min(screenHeight, screenPos.dy + itemHeight);
    final visibleH = max(0, visibleBottom - visibleTop);
    final fraction = itemHeight > 0 ? visibleH / itemHeight : 0.0;

    if (fraction >= widget.visibleThreshold && !_hasTriggered) {
      _hasTriggered = true;
      if (widget.delay > Duration.zero) {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      } else {
        _controller.forward();
      }
    } else if (_hasTriggered && fraction == 0.0) {
      _hasTriggered = false;
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _RevealTransition(
      key: _itemKey,
      animation: _curvedAnimation,
      direction: widget.direction,
      offset: widget.offset,
      child: widget.child,
    );
  }
}

/// Internal helper that applies directional translate + opacity based on an
/// [Animation] value.
class _RevealTransition extends AnimatedWidget {
  const _RevealTransition({
    required Animation<double> animation, required this.direction, required this.offset, required this.child, super.key,
  }) : super(listenable: animation);

  final RevealDirection direction;
  final double offset;
  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;

  Offset _translateOffset(double t) {
    final remaining = (1.0 - t) * offset;
    switch (direction) {
      case RevealDirection.up:
        return Offset(0, remaining);
      case RevealDirection.down:
        return Offset(0, -remaining);
      case RevealDirection.left:
        return Offset(remaining, 0);
      case RevealDirection.right:
        return Offset(-remaining, 0);
      case RevealDirection.fade:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _animation.value;
    return FadeTransition(
      opacity: _animation,
      child: Transform.translate(
        offset: _translateOffset(t),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. ParallaxContainer
// ---------------------------------------------------------------------------
/// Wraps a child so that it translates at a different rate than the
/// surrounding scroll, producing a classic parallax depth effect (inspired by
/// ILY GIRL's layered scrolling).
///
/// [factor] controls how strongly the child reacts to scroll offset:
/// * 0.0 = child scrolls normally (no parallax).
/// * 0.5 = child moves at half the scroll speed.
/// * 1.0 = child stays completely fixed while the page scrolls.
///
/// A negative factor makes the child scroll *faster* than normal (use
/// sparingly).
class ParallaxContainer extends StatelessWidget {
  const ParallaxContainer({
    required this.child, super.key,
    this.factor = 0.3,
    this.direction = Axis.vertical,
  }) : assert(factor >= -1.0 && factor <= 1.0);

  final Widget child;

  /// Parallax strength. 0 = no effect, 1 = fully pinned.
  final double factor;

  /// Axis along which the parallax is applied.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollable = Scrollable.maybeOf(context);
        if (scrollable == null) return child;

        return _ParallaxAnimator(
          position: scrollable.position,
          factor: factor,
          direction: direction,
          child: child,
        );
      },
    );
  }
}

class _ParallaxAnimator extends AnimatedWidget {
  const _ParallaxAnimator({
    required ScrollPosition position,
    required this.factor,
    required this.direction,
    required this.child,
  }) : super(listenable: position);

  final double factor;
  final Axis direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final position = listenable as ScrollPosition;
    final pixels = position.hasPixels ? position.pixels : 0.0;
    final translation = pixels * factor;

    final offset = direction == Axis.vertical
        ? Offset(0, -translation)
        : Offset(-translation, 0);

    return ClipRect(
      child: Transform.translate(
        offset: offset,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. StaggeredReveal
// ---------------------------------------------------------------------------
/// Animates a list of [children] into view with a staggered delay between
/// each child, combining with the same scroll-visibility trigger used by
/// [ScrollReveal].
///
/// Inspired by LQVE's sequential element entrances and obake.blue's
/// project-item cascade.
class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    required this.children, super.key,
    this.direction = RevealDirection.up,
    this.itemDuration = const Duration(milliseconds: 600),
    this.staggerDelay = const Duration(milliseconds: 120),
    this.curve = Curves.easeOutCubic,
    this.offset = 50.0,
    this.visibleThreshold = 0.10,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.axis = Axis.vertical,
  });

  final List<Widget> children;
  final RevealDirection direction;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Curve curve;
  final double offset;
  final double visibleThreshold;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis axis;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggered = false;
  final GlobalKey _containerKey = GlobalKey();

  /// Total animation duration accounts for the last child's stagger offset
  /// plus its own item duration.
  Duration get _totalDuration {
    final count = widget.children.length;
    if (count == 0) return Duration.zero;
    final staggerTotal = widget.staggerDelay * (count - 1);
    return staggerTotal + widget.itemDuration;
  }

  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;
    final box = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final screenPos = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = box.size.height;

    final visibleTop = max(0, screenPos.dy);
    final visibleBottom = min(screenHeight, screenPos.dy + itemHeight);
    final visibleH = max(0, visibleBottom - visibleTop);
    final fraction = itemHeight > 0 ? visibleH / itemHeight : 0.0;

    if (fraction >= widget.visibleThreshold && !_hasTriggered) {
      _hasTriggered = true;
      _controller.forward();
    } else if (_hasTriggered && fraction == 0.0) {
      _hasTriggered = false;
      _controller.reset();
    }
  }

  Animation<double> _animationFor(int index) {
    final totalUs = _totalDuration.inMicroseconds.toDouble();
    if (totalUs == 0) return const AlwaysStoppedAnimation(1);
    final startUs = widget.staggerDelay.inMicroseconds.toDouble() * index;
    final endUs = startUs + widget.itemDuration.inMicroseconds.toDouble();
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (startUs / totalUs).clamp(0.0, 1.0),
        (endUs / totalUs).clamp(0.0, 1.0),
        curve: widget.curve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      items.add(
        _StaggeredItemTransition(
          animation: _animationFor(i),
          direction: widget.direction,
          offset: widget.offset,
          child: widget.children[i],
        ),
      );
    }

    return widget.axis == Axis.vertical
        ? Column(
            key: _containerKey,
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: items,
          )
        : Row(
            key: _containerKey,
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: items,
          );
  }
}

class _StaggeredItemTransition extends AnimatedWidget {
  const _StaggeredItemTransition({
    required Animation<double> animation,
    required this.direction,
    required this.offset,
    required this.child,
  }) : super(listenable: animation);

  final RevealDirection direction;
  final double offset;
  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;

  Offset _translateOffset(double t) {
    final remaining = (1.0 - t) * offset;
    switch (direction) {
      case RevealDirection.up:
        return Offset(0, remaining);
      case RevealDirection.down:
        return Offset(0, -remaining);
      case RevealDirection.left:
        return Offset(remaining, 0);
      case RevealDirection.right:
        return Offset(-remaining, 0);
      case RevealDirection.fade:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _animation.value;
    return FadeTransition(
      opacity: _animation,
      child: Transform.translate(
        offset: _translateOffset(t),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. TextReveal
// ---------------------------------------------------------------------------
/// Reveals text character-by-character (or word-by-word) with each unit
/// fading and sliding in from below, inspired by p5aholic's portfolio text
/// entrance.
///
/// The animation is triggered once the widget scrolls into view.
class TextReveal extends StatefulWidget {
  const TextReveal({
    required this.text, super.key,
    this.style,
    this.perWord = false,
    this.unitDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 35),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 24.0,
    this.textAlign = TextAlign.start,
    this.visibleThreshold = 0.10,
  });

  /// The text to reveal.
  final String text;

  /// Text style applied to every unit (character or word).
  final TextStyle? style;

  /// When `true` the text is split by whitespace and each *word* animates
  /// independently; otherwise every character is a separate unit.
  final bool perWord;

  /// Duration each individual unit takes to fully appear.
  final Duration unitDuration;

  /// Delay between the start of each successive unit's animation.
  final Duration staggerDelay;

  /// Easing curve for each unit.
  final Curve curve;

  /// How far (in logical pixels) each unit slides up from below.
  final double slideOffset;

  final TextAlign textAlign;

  final double visibleThreshold;

  @override
  State<TextReveal> createState() => _TextRevealState();
}

class _TextRevealState extends State<TextReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<String> _units;
  bool _hasTriggered = false;
  final GlobalKey _key = GlobalKey();

  Duration get _totalDuration {
    final count = _units.length;
    if (count == 0) return Duration.zero;
    final staggerTotal = widget.staggerDelay * (count - 1);
    return staggerTotal + widget.unitDuration;
  }

  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _units = _splitText(widget.text);
    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didUpdateWidget(covariant TextReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.perWord != widget.perWord) {
      _units = _splitText(widget.text);
      _controller.duration = _totalDuration;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  List<String> _splitText(String text) {
    if (widget.perWord) {
      final regex = RegExp(r'\S+|\s+');
      return regex.allMatches(text).map((m) => m.group(0)!).toList();
    }
    return text.split('');
  }

  void _checkVisibility() {
    if (!mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final screenPos = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = box.size.height;

    final visTop = max(0, screenPos.dy);
    final visBot = min(screenHeight, screenPos.dy + itemHeight);
    final visH = max(0, visBot - visTop);
    final frac = itemHeight > 0 ? visH / itemHeight : 0.0;

    if (frac >= widget.visibleThreshold && !_hasTriggered) {
      _hasTriggered = true;
      _controller.forward();
    } else if (_hasTriggered && frac == 0.0) {
      _hasTriggered = false;
      _controller.reset();
    }
  }

  Animation<double> _animationFor(int index) {
    final totalUs = _totalDuration.inMicroseconds.toDouble();
    if (totalUs == 0) return const AlwaysStoppedAnimation(1);
    final startUs = widget.staggerDelay.inMicroseconds.toDouble() * index;
    final endUs = startUs + widget.unitDuration.inMicroseconds.toDouble();
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (startUs / totalUs).clamp(0.0, 1.0),
        (endUs / totalUs).clamp(0.0, 1.0),
        curve: widget.curve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = widget.style ?? DefaultTextStyle.of(context).style;

    return Wrap(
      key: _key,
      alignment: _wrapAlignment(widget.textAlign),
      children: List.generate(_units.length, (i) {
        final unit = _units[i];
        if (unit.trim().isEmpty) {
          return Text(unit, style: defaultStyle);
        }
        return _TextUnitTransition(
          animation: _animationFor(i),
          text: unit,
          style: defaultStyle,
          slideOffset: widget.slideOffset,
        );
      }),
    );
  }

  WrapAlignment _wrapAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
        return WrapAlignment.start;
    }
  }
}

class _TextUnitTransition extends AnimatedWidget {
  const _TextUnitTransition({
    required Animation<double> animation,
    required this.text,
    required this.style,
    required this.slideOffset,
  }) : super(listenable: animation);

  final String text;
  final TextStyle style;
  final double slideOffset;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = _animation.value;
    return FadeTransition(
      opacity: _animation,
      child: Transform.translate(
        offset: Offset(0, (1.0 - t) * slideOffset),
        child: Text(text, style: style),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. CountUpText
// ---------------------------------------------------------------------------
/// Animates a numeric value from [from] (default 0) up to [value], formatted
/// with an optional [prefix] and [suffix].
///
/// Inspired by obake.blue's "01", "02" section numbering that counts up as
/// you scroll into view.
class CountUpText extends StatefulWidget {
  const CountUpText({
    required this.value, super.key,
    this.from = 0,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.padLeft = 0,
    this.decimalPlaces = 0,
    this.visibleThreshold = 0.15,
  });

  /// The target number.
  final double value;

  /// The starting number (defaults to 0).
  final double from;

  /// Total animation duration.
  final Duration duration;

  /// Easing curve.
  final Curve curve;

  /// Text style.
  final TextStyle? style;

  /// Text prepended to the number (e.g. "$").
  final String prefix;

  /// Text appended to the number (e.g. "%").
  final String suffix;

  /// Zero-pad the integer part to at least this many digits.
  final int padLeft;

  /// Number of decimal places to display.
  final int decimalPlaces;

  final double visibleThreshold;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasTriggered = false;
  final GlobalKey _key = GlobalKey();
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final screenPos = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = box.size.height;

    final visTop = max(0, screenPos.dy);
    final visBot = min(screenHeight, screenPos.dy + itemHeight);
    final visH = max(0, visBot - visTop);
    final frac = itemHeight > 0 ? visH / itemHeight : 0.0;

    if (frac >= widget.visibleThreshold && !_hasTriggered) {
      _hasTriggered = true;
      _controller.forward();
    } else if (_hasTriggered && frac == 0.0) {
      _hasTriggered = false;
      _controller.reset();
    }
  }

  String _format(double v) {
    final str = v.toStringAsFixed(widget.decimalPlaces);
    if (widget.padLeft > 0 && widget.decimalPlaces == 0) {
      return str.padLeft(widget.padLeft, '0');
    }
    if (widget.padLeft > 0) {
      final parts = str.split('.');
      parts[0] = parts[0].padLeft(widget.padLeft, '0');
      return parts.join('.');
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return _CountUpBody(
      key: _key,
      animation: _animation,
      from: widget.from,
      to: widget.value,
      format: _format,
      prefix: widget.prefix,
      suffix: widget.suffix,
      style: widget.style,
    );
  }
}

class _CountUpBody extends AnimatedWidget {
  const _CountUpBody({
    required Animation<double> animation, required this.from, required this.to, required this.format, required this.prefix, required this.suffix, super.key,
    this.style,
  }) : super(listenable: animation);

  final double from;
  final double to;
  final String Function(double) format;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final current = from + (to - from) * t;
    return Text(
      '$prefix${format(current)}$suffix',
      style: style,
    );
  }
}
