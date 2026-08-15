import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A glassmorphism card with backdrop blur, light white surface,
/// thin warm border, and soft warm shadow.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final double borderRadius;
  final double glowIntensity; // 0.0 - 1.0
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.accentColor,
    this.borderRadius = 20,
    this.glowIntensity = 0.0,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.growthAccent;
    final borderColor = accent.withOpacity(0.25);
    final glowColor = accent.withOpacity(0.12 * widget.glowIntensity);

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => _pressController.forward()
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _pressController.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => _pressController.reverse()
          : null,
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
            boxShadow: widget.glowIntensity > 0
                ? [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 24 * widget.glowIntensity,
                      spreadRadius: -2,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0A4A3E37),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  color: widget.gradient == null
                      ? AppColors.surface.withOpacity(0.9)
                      : null,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.gradient == null ? AppColors.border : borderColor,
                    width: 1.0,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
