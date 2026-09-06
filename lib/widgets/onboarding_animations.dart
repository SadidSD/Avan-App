import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An ultra-smooth, hardware-accelerated typewriter animation widget.
/// Progressively reveals text character-by-character with a zero-allocation
/// text-based cursor and tap-to-complete agency.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration durationPerChar;
  final Duration initialDelay;
  final VoidCallback? onComplete;
  final bool showCursor;
  final Color? cursorColor;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.durationPerChar = const Duration(milliseconds: 18),
    this.initialDelay = const Duration(milliseconds: 180),
    this.onComplete,
    this.showCursor = true,
    this.cursorColor,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _charController;
  Timer? _delayTimer;
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

  void _onTypingFinished() {
    if (!mounted) return;
    setState(() {
      _isTypingComplete = true;
      _displayedLength = widget.text.length;
    });
    widget.onComplete?.call();
  }

  /// Allows fast tapping to instantly skip and reveal full text
  void _skipToEnd() {
    if (_isTypingComplete) return;
    _delayTimer?.cancel();
    _charController.value = 1.0;
    _onTypingFinished();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _delayTimer?.cancel();
      _charController.dispose();
      _isTypingComplete = false;
      _displayedLength = 0;
      _initAndStart();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _charController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final cursorColor = widget.cursorColor ?? AppColors.goldAccent;

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

    return RepaintBoundary(
      child: Semantics(
        label: widget.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _skipToEnd,
          child: Text.rich(
            TextSpan(
              style: effectiveStyle,
              children: [
                TextSpan(text: visibleText),
                if (widget.showCursor)
                  TextSpan(
                    text: ' ▍',
                    style: effectiveStyle.copyWith(
                      color: cursorColor,
                      fontWeight: FontWeight.w900,
                      fontSize: (effectiveStyle.fontSize ?? 16.0) * 0.82,
                    ),
                  ),
              ],
            ),
            textAlign: widget.textAlign,
          ),
        ),
      ),
    );
  }
}

/// A high-performance pop-on from bottom animation wrapper.
/// Uses isolated GPU RepaintBoundaries, unified Matrix4 transforms,
/// and automatically deallocates animation controllers upon completion.
class BottomPopItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Duration baseDelay;
  final Duration staggerDelay;
  final Duration duration;
  final double offsetDistance;
  final Curve curve;

  const BottomPopItem({
    super.key,
    required this.child,
    this.index = 0,
    this.delay,
    this.baseDelay = const Duration(milliseconds: 260),
    this.staggerDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 320),
    this.offsetDistance = 24.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<BottomPopItem> createState() => _BottomPopItemState();
}

class _BottomPopItemState extends State<BottomPopItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _delayTimer;
  bool _isCompleted = false;

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

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _isCompleted = true;
        });
      }
    });

    final totalDelay = widget.delay ?? (widget.baseDelay + (widget.staggerDelay * widget.index));
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
    // When completed, render pure child with 0 GPU composition overhead
    if (_isCompleted) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final val = _animation.value;
          final translateY = (1.0 - val.clamp(0.0, 1.0)) * widget.offsetDistance;
          final scale = 0.94 + (0.06 * val);
          final opacity = val.clamp(0.0, 1.0);

          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, translateY)
              ..scale(scale),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}
