import 'package:flutter/material.dart';

/// Text reveal animation.
///
/// p5aholic.me uses cubic-bezier(.3,.1,.2,1) for cover transitions.
/// This widget clips text with an animated mask that slides away,
/// revealing the text underneath. The "audacious simplicity" effect.
class RevealText extends StatefulWidget {
  const RevealText({
    super.key,
    required this.text,
    required this.style,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final Duration delay;
  final Duration duration;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  State<RevealText> createState() => _RevealTextState();
}

class _RevealTextState extends State<RevealText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // p5aholic cubic-bezier(.3,.1,.2,1) — fast start, smooth settle
    const curve = Cubic(0.3, 0.1, 0.2, 1.0);

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: FractionalTranslation(
              translation: Offset(0, _slideAnimation.value * 0.3),
              child: child,
            ),
          ),
        );
      },
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }
}
