import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An elegant typewriter animation widget that progressively reveals text
/// character-by-character with an optional subtle cursor and tap-to-complete agency.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration durationPerChar;
  final Duration initialDelay;
  final VoidCallback? onComplete;
  final bool showCursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double cursorHeightRatio;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.durationPerChar = const Duration(milliseconds: 22),
    this.initialDelay = const Duration(milliseconds: 100),
    this.onComplete,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeightRatio = 0.85,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _charController;
  Timer? _delayTimer;
  Timer? _cursorBlinkTimer;
  bool _cursorVisible = true;
  bool _isTypingComplete = false;
  int _displayedLength = 0;

  @override
  void initState() {
    super.initState();
    _initAndStart();
  }

  void _initAndStart() {
    final totalCharCount = widget.text.length;
    final totalDurationMs =
        totalCharCount > 0 ? totalCharCount * widget.durationPerChar.inMilliseconds : 10;

    _charController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDurationMs),
    );

    _charController.addListener(() {
      if (!mounted) return;
      final newLength =
          (_charController.value * widget.text.length).round().clamp(0, widget.text.length);
      if (newLength != _displayedLength) {
        setState(() {
          _displayedLength = newLength;
        });
      }
    });

    _charController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTypingFinished();
      }
    });

    _startCursorBlink();

    if (widget.initialDelay > Duration.zero) {
      _delayTimer = Timer(widget.initialDelay, () {
        if (mounted && !_charController.isAnimating && !_isTypingComplete) {
          _charController.forward();
        }
      });
    } else {
      _charController.forward();
    }
  }

  void _startCursorBlink() {
    _cursorBlinkTimer?.cancel();
    _cursorBlinkTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
      if (mounted) {
        setState(() {
          _cursorVisible = !_cursorVisible;
        });
      }
    });
  }

  void _onTypingFinished() {
    if (!mounted) return;
    _cursorBlinkTimer?.cancel();
    _cursorBlinkTimer = null;
    setState(() {
      _isTypingComplete = true;
      _cursorVisible = false;
      _displayedLength = widget.text.length;
    });
    widget.onComplete?.call();
  }

  /// Allows fast tapping to instantly skip and reveal full text
  void _skipToEnd() {
    if (_isTypingComplete) return;
    _delayTimer?.cancel();
    _cursorBlinkTimer?.cancel();
    _charController.value = 1.0;
    _onTypingFinished();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _delayTimer?.cancel();
      _cursorBlinkTimer?.cancel();
      _charController.dispose();
      _isTypingComplete = false;
      _displayedLength = 0;
      _initAndStart();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _cursorBlinkTimer?.cancel();
    _charController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final cursorColor = widget.cursorColor ?? AppColors.goldAccent;
    final fontSize = effectiveStyle.fontSize ?? 16.0;

    if (_isTypingComplete) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skipToEnd,
        child: Text(
          widget.text,
          style: effectiveStyle,
          textAlign: widget.textAlign,
        ),
      );
    }

    final String visibleText = widget.text.substring(0, _displayedLength);

    return Semantics(
      label: widget.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skipToEnd,
        child: RichText(
          textAlign: widget.textAlign,
          text: TextSpan(
            style: effectiveStyle,
            children: [
              TextSpan(text: visibleText),
              if (widget.showCursor && _cursorVisible)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(left: 2),
                    width: widget.cursorWidth,
                    height: fontSize * widget.cursorHeightRatio,
                    decoration: BoxDecoration(
                      color: cursorColor,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: cursorColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A playful and tactile pop-on from bottom animation wrapper.
/// Used for options cards, buttons, and questionnaire items.
class BottomPopItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration staggerDelay;
  final Duration duration;
  final double offsetDistance;
  final Curve curve;

  const BottomPopItem({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 280),
    this.staggerDelay = const Duration(milliseconds: 65),
    this.duration = const Duration(milliseconds: 440),
    this.offsetDistance = 38.0,
    this.curve = Curves.easeOutBack,
  });

  @override
  State<BottomPopItem> createState() => _BottomPopItemState();
}

class _BottomPopItemState extends State<BottomPopItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _delayTimer;

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

    final totalDelay = widget.baseDelay + (widget.staggerDelay * widget.index);
    _delayTimer = Timer(totalDelay, () {
      if (mounted && !_controller.isAnimating && !_controller.isCompleted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        // Slide from offsetDistance down to 0
        final translateY = (1.0 - val.clamp(0.0, 1.0)) * widget.offsetDistance;
        // Scale from 0.88 to 1.0 with subtle spring overshoot
        final scale = 0.88 + (0.12 * val);
        // Fade in from 0.0 to 1.0
        final opacity = val.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
