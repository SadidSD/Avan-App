import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class LiquidGlassChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const LiquidGlassChip({
    Key? key,
    required this.label,
    this.emoji,
    this.isSelected = false,
    required this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.growthAccent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.18)
              : AppColors.surfaceElevated.withOpacity(0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent.withOpacity(0.6) : const Color(0x1FFFFFFF),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null && emoji!.isNotEmpty) ...[
              Text(
                emoji!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_rounded,
                size: 14,
                color: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
