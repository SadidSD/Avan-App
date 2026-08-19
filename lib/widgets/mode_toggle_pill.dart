import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

class ModeTogglePill extends StatelessWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;

  const ModeTogglePill({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isGrowth = currentMode == AppMode.growth;
    final Color activeAccent = isGrowth ? AppColors.growthAccent : AppColors.healingAccent;

    return GestureDetector(
      onTap: () {
        onModeChanged(isGrowth ? AppMode.healing : AppMode.growth);
      },
      child: Container(
        height: 36.0,
        width: 180.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: isGrowth ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: activeAccent,
                    end: activeAccent,
                  ),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, color, child) {
                    return Container(
                      margin: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: (color ?? Colors.transparent).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: (color ?? Colors.transparent).withOpacity(0.35),
                          width: 1.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '🌿 Growth',
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        fontWeight: isGrowth ? FontWeight.w600 : FontWeight.w500,
                        color: isGrowth ? AppColors.growthAccent : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '🌊 Healing',
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        fontWeight: !isGrowth ? FontWeight.w600 : FontWeight.w500,
                        color: !isGrowth ? AppColors.healingAccent : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
