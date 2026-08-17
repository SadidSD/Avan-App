import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AffirmationCard extends StatelessWidget {
  final String quote;
  final String playlistName;
  final String imagePath;
  final int durationMinutes;
  final bool isFavorite;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const AffirmationCard({
    Key? key,
    required this.quote,
    required this.playlistName,
    required this.imagePath,
    required this.durationMinutes,
    required this.isFavorite,
    required this.accentColor,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            const BoxShadow(
              color: Color(0x44000000),
              blurRadius: 14.0,
              offset: Offset(0, 5),
            ),
            if (isFavorite)
              BoxShadow(
                color: accentColor.withOpacity(0.28),
                blurRadius: 16.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x14FFDDBE),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isFavorite
                      ? accentColor.withOpacity(0.45)
                      : const Color(0x22FFFFFF),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Cover Image with Frosted Overlays
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(19.0),
                          topRight: Radius.circular(19.0),
                          bottomLeft: Radius.circular(14.0),
                          bottomRight: Radius.circular(14.0),
                        ),
                        child: SizedBox(
                          height: 108.0,
                          width: double.infinity,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFF2C1810),
                              child: const Icon(
                                Icons.self_improvement_rounded,
                                color: AppColors.tanAccent,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Liquid dark gradient overlay on image for cinematic feel
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(19.0),
                            topRight: Radius.circular(19.0),
                            bottomLeft: Radius.circular(14.0),
                            bottomRight: Radius.circular(14.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0x401A110D),
                                  const Color(0xAA1A110D),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Duration badge (top-left)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0x801A110D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0x33FFFFFF),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${durationMinutes}m',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Favorite heart button (top-right)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onFavoriteToggle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.all(5.5),
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? accentColor.withOpacity(0.3)
                                      : const Color(0x801A110D),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isFavorite
                                        ? accentColor.withOpacity(0.6)
                                        : const Color(0x33FFFFFF),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorite
                                      ? accentColor
                                      : Colors.white.withOpacity(0.85),
                                  size: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Affirmation Text & Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 9.0, 10.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quote Text
                        Text(
                          quote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        // Playlist Tag Row
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: Text(
                                playlistName,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
