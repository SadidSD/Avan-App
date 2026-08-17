import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';

class AnimatedCosmicBackground extends StatefulWidget {
  final Widget child;
  final AppMode mode;

  const AnimatedCosmicBackground({
    Key? key,
    required this.child,
    required this.mode,
  }) : super(key: key);

  @override
  State<AnimatedCosmicBackground> createState() => _AnimatedCosmicBackgroundState();
}

class _AnimatedCosmicBackgroundState extends State<AnimatedCosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _modeController;
  late Animation<Color?> _topColorAnim;
  late Animation<Color?> _midColorAnim;
  late Animation<Color?> _bottomColorAnim;
  late Animation<Color?> _orbColorAnim;

  AppMode _prevMode = AppMode.growth;

  @override
  void initState() {
    super.initState();
    _prevMode = widget.mode;

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _setupColorTweens();
  }

  void _setupColorTweens() {
    Color topGrowth = const Color(0xFF1A2A1D);
    Color midGrowth = const Color(0xFF1A110D);
    Color bottomGrowth = const Color(0xFF0F0A07);
    Color orbGrowth = AppColors.growthAccent.withOpacity(0.12);

    Color topHealing = const Color(0xFF0D1F1F);
    Color midHealing = const Color(0xFF1A110D);
    Color bottomHealing = const Color(0xFF0F0A07);
    Color orbHealing = AppColors.healingAccent.withOpacity(0.12);

    Color topStart = _prevMode == AppMode.growth ? topGrowth : topHealing;
    Color topEnd = widget.mode == AppMode.growth ? topGrowth : topHealing;

    Color midStart = _prevMode == AppMode.growth ? midGrowth : midHealing;
    Color midEnd = widget.mode == AppMode.growth ? midGrowth : midHealing;

    Color bottomStart = _prevMode == AppMode.growth ? bottomGrowth : bottomHealing;
    Color bottomEnd = widget.mode == AppMode.growth ? bottomGrowth : bottomHealing;

    Color orbStart = _prevMode == AppMode.growth ? orbGrowth : orbHealing;
    Color orbEnd = widget.mode == AppMode.growth ? orbGrowth : orbHealing;

    _topColorAnim = ColorTween(begin: topStart, end: topEnd).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _midColorAnim = ColorTween(begin: midStart, end: midEnd).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _bottomColorAnim = ColorTween(begin: bottomStart, end: bottomEnd).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _orbColorAnim = ColorTween(begin: orbStart, end: orbEnd).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedCosmicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _prevMode = oldWidget.mode;
      _setupColorTweens();
      _modeController.forward(from: 0.0);
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
      animation: Listenable.merge([_orbController, _modeController]),
      builder: (context, _) {
        final double t = _orbController.value * 2 * math.pi;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _topColorAnim.value ?? const Color(0xFF1A110D),
                    _midColorAnim.value ?? const Color(0xFF1A110D),
                    _bottomColorAnim.value ?? const Color(0xFF0F0A07),
                  ],
                ),
              ),
            ),
            // Ambient glow patches
            Positioned(
              left: -50,
              top: MediaQuery.of(context).size.height * 0.2 + math.sin(t) * 20,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2C1810).withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C1810).withOpacity(0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: MediaQuery.of(context).size.height * 0.1 + math.cos(t) * 20,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2C1810).withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C1810).withOpacity(0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            // Floating Orbs
            Positioned(
              left: MediaQuery.of(context).size.width * 0.2 + math.cos(t) * 50,
              top: MediaQuery.of(context).size.height * 0.1 + math.sin(t) * 50,
              child: _buildOrb(240, _orbColorAnim.value),
            ),
            Positioned(
              right: MediaQuery.of(context).size.width * 0.1 + math.sin(t * 1.2) * 60,
              top: MediaQuery.of(context).size.height * 0.4 + math.cos(t * 1.2) * 60,
              child: _buildOrb(200, _orbColorAnim.value),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.3 + math.cos(t * 0.8) * 40,
              bottom: MediaQuery.of(context).size.height * 0.15 + math.sin(t * 0.8) * 40,
              child: _buildOrb(160, _orbColorAnim.value),
            ),
            widget.child,
          ],
        );
      },
    );
  }

  Widget _buildOrb(double size, Color? color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color ?? Colors.transparent,
            (color ?? Colors.transparent).withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
