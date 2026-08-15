import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

/// Animated pill toggle between Growth and Healing modes.
/// Sliding indicator animates between two sides with a color transition.
class ModeTogglePill extends StatefulWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;

  const ModeTogglePill({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  State<ModeTogglePill> createState() => _ModeTogglePillState();
}

class _ModeTogglePillState extends State<ModeTogglePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    );
    _colorAnimation = ColorTween(
      begin: AppColors.growthAccent,
      end: AppColors.healingAccent,
    ).animate(_slideAnimation);
    if (widget.currentMode == AppMode.healing) {
      _slideController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModeTogglePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMode != widget.currentMode) {
      if (widget.currentMode == AppMode.growth) {
        _slideController.reverse();
      } else if (widget.currentMode == AppMode.healing) {
        _slideController.forward();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final accent = _colorAnimation.value ?? AppColors.growthAccent;
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Sliding indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                alignment: widget.currentMode == AppMode.growth
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: accent.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Labels row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onModeChanged(AppMode.growth),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\uD83D\uDE80', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Growth',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: widget.currentMode == AppMode.growth
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: widget.currentMode == AppMode.growth
                                    ? AppColors.growthAccent
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onModeChanged(AppMode.healing),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\uD83D\uDC9A', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Healing',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: widget.currentMode == AppMode.healing
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: widget.currentMode == AppMode.healing
                                    ? AppColors.healingAccent
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
