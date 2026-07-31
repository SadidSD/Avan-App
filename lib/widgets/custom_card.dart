import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final Gradient? gradient;
  final bool hasGlassMorphism;
  final bool hasShadowGlow;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.backgroundColor = AppColors.cardSurface,
    this.onTap,
    this.borderRadius = 24.0,
    this.gradient,
    this.hasGlassMorphism = false,
    this.hasShadowGlow = false,
  }) : super(key: key);

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.04, // Scale down by 4%
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;
    
    Widget content = Padding(
      padding: widget.padding,
      child: widget.child,
    );

    if (widget.hasGlassMorphism) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: AppColors.glassBorder, width: 1.0),
            ),
            child: content,
          ),
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: widget.gradient == null ? widget.backgroundColor : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.borderSoft, width: 0.5),
        ),
        child: content,
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.hasShadowGlow
                ? [
                    const BoxShadow(
                      color: AppColors.glowAccent,
                      blurRadius: 24,
                      spreadRadius: -4,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [
                    // Premium double shadow
                    const BoxShadow(
                      color: Color(0x054A3E37),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                    const BoxShadow(
                      color: Color(0x0A4A3E37),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: content,
        ),
      ),
    );
  }
}
