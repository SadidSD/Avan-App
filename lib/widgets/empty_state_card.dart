import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Reusable elegant empty state card with icon halo glow, typography,
/// and an optional call-to-action button.
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? accentColor;
  final double padding;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.accentColor,
    this.padding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.goldAccent;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Halo Container
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: effectiveAccent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveAccent.withOpacity(0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveAccent.withOpacity(0.18),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: effectiveAccent,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          // Optional Action Button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: effectiveAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: effectiveAccent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: effectiveAccent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: effectiveAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
