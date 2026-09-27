import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color accentColor;
  final double borderRadius;
  final double glowIntensity;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final bool? enableBlur;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    required this.accentColor,
    this.borderRadius = 20.0,
    this.glowIntensity = 0.0,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
    this.enableBlur,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // High-performance optimization: On Android devices, bypass heavy BackdropFilter
    // offscreen buffer copy unless explicitly enabled, preventing Skia/Impeller frame drops.
    final bool shouldBlur = widget.enableBlur ??
        (!kIsWeb && defaultTargetPlatform != TargetPlatform.android);

    Widget content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(shouldBlur ? 0.85 : 0.94),
                Colors.white.withOpacity(shouldBlur ? 0.65 : 0.86),
              ],
            ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.0,
        ),
      ),
      child: widget.child,
    );

    if (shouldBlur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: content,
      );
    }

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (widget.glowIntensity > 0)
                BoxShadow(
                  color: widget.accentColor.withOpacity(widget.glowIntensity * 0.2),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: content,
          ),
        ),
      ),
    );
  }
}
