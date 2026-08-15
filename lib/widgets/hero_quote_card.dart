import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// A premium glassmorphism quote card with Cormorant Garamond text,
/// animated shimmer border, and mode-aware styling.
class HeroQuoteCard extends StatefulWidget {
  final String quote;
  final bool isGrowth;
  final VoidCallback? onListen;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  const HeroQuoteCard({
    Key? key,
    required this.quote,
    required this.isGrowth,
    this.onListen,
    this.onFavorite,
    this.onShare,
  }) : super(key: key);

  @override
  State<HeroQuoteCard> createState() => _HeroQuoteCardState();
}

class _HeroQuoteCardState extends State<HeroQuoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isGrowth
        ? AppColors.growthAccent
        : AppColors.healingAccent;
    final gradient = widget.isGrowth
        ? AppColors.growthCardGradient
        : AppColors.healingCardGradient;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accent.withOpacity(
                      0.15 + 0.1 * _shimmerController.value,
                    ),
                    width: 1.0,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote mark
          Text(
            '\u201C',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 60,
              color: widget.isGrowth
                  ? AppColors.growthAccent.withOpacity(0.5)
                  : AppColors.healingAccent.withOpacity(0.5),
              height: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Quote text
          Text(
            widget.quote,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(
                icon: Icons.favorite_outline_rounded,
                label: 'Save',
                onTap: widget.onFavorite,
              ),
              const SizedBox(width: 4),
              _actionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: widget.onShare,
              ),
              const SizedBox(width: 8),
              // Listen button
              GestureDetector(
                onTap: widget.onListen,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isGrowth
                        ? AppColors.growthAccent.withOpacity(0.15)
                        : AppColors.healingAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isGrowth
                          ? AppColors.growthAccent.withOpacity(0.4)
                          : AppColors.healingAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: widget.isGrowth
                            ? AppColors.growthAccent
                            : AppColors.healingAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Listen',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.isGrowth
                              ? AppColors.growthAccent
                              : AppColors.healingAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: AppColors.textMuted),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textMuted,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
