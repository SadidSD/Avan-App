import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// A premium glassmorphism quote card with Cormorant Garamond text,
/// animated shimmer border, and mode-aware warm light styling.
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
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentForMode(widget.isGrowth);
    final gradient = AppColors.cardGradientForMode(widget.isGrowth);

    final bool shouldBlur = !kIsWeb && defaultTargetPlatform != TargetPlatform.android;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          Widget card = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accent.withOpacity(
                  0.2 + 0.15 * _shimmerController.value,
                ),
                width: 1.0,
              ),
            ),
            child: child,
          );

          if (shouldBlur) {
            card = ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: card,
              ),
            );
          }

          return card;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative quotation mark
            Text(
              '“',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 60,
                color: accent.withOpacity(0.6),
                height: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Quote text
            Text(
              widget.quote,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                height: 1.5,
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
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Listen',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: AppColors.textSecondary),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textSecondary,
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
