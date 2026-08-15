import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated floating orb background for the warm light Stella-inspired aesthetic.
/// Renders 3 slow-moving glowing pastel orbs that oscillate using sin/cos.
class AnimatedCosmicBackground extends StatefulWidget {
  final bool isGrowth;
  final Widget child;

  const AnimatedCosmicBackground({
    Key? key,
    required this.isGrowth,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedCosmicBackground> createState() =>
      _AnimatedCosmicBackgroundState();
}

class _AnimatedCosmicBackgroundState extends State<AnimatedCosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _modeController;
  late Animation<double> _modeAnimation;
  bool _wasGrowth = true;

  @override
  void initState() {
    super.initState();
    _wasGrowth = widget.isGrowth;
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(AnimatedCosmicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGrowth != widget.isGrowth) {
      _wasGrowth = oldWidget.isGrowth;
      _modeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbController, _modeAnimation]),
      builder: (context, child) {
        final growthColor1 = const Color(0xFFF9F6F0);
        final growthColor2 = const Color(0xFFE6F4F1);
        final healingColor1 = const Color(0xFFFDF7F0);
        final healingColor2 = const Color(0xFFFDF0F5);

        final t = _modeAnimation.value;
        final fromC1 = _wasGrowth ? growthColor1 : healingColor1;
        final fromC2 = _wasGrowth ? growthColor2 : healingColor2;
        final toC1 = widget.isGrowth ? growthColor1 : healingColor1;
        final toC2 = widget.isGrowth ? growthColor2 : healingColor2;

        final bgColor1 = Color.lerp(fromC1, toC1, t) ?? toC1;
        final bgColor2 = Color.lerp(fromC2, toC2, t) ?? toC2;

        final orbColor = widget.isGrowth
            ? AppColors.growthAccent.withOpacity(0.14)
            : AppColors.healingAccent.withOpacity(0.14);

        return Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor1, bgColor2],
                  ),
                ),
              ),
            ),
            // Floating orbs
            Positioned(
              top: _orbY(0.15, 0.08, 0.0),
              left: _orbX(0.2, 0.06, 0.0),
              child: _buildOrb(220, orbColor),
            ),
            Positioned(
              top: _orbY(0.5, 0.06, 0.33),
              right: _orbX(0.1, 0.05, 0.33),
              child: _buildOrb(180, orbColor.withOpacity(0.10)),
            ),
            Positioned(
              bottom: _orbY(0.1, 0.05, 0.66),
              left: _orbX(0.35, 0.04, 0.66),
              child: _buildOrb(150, orbColor.withOpacity(0.08)),
            ),
            // Content on top
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  double _orbY(double base, double amplitude, double phaseOffset) {
    final screenH = MediaQuery.of(context).size.height;
    final t = _orbController.value * 2 * math.pi + phaseOffset * 2 * math.pi;
    return screenH * base + screenH * amplitude * math.sin(t);
  }

  double _orbX(double base, double amplitude, double phaseOffset) {
    final screenW = MediaQuery.of(context).size.width;
    final t = _orbController.value * 2 * math.pi + phaseOffset * 2 * math.pi;
    return screenW * base + screenW * amplitude * math.cos(t * 0.7);
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
