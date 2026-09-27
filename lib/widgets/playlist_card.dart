import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/playlist.dart';
import '../theme/app_colors.dart';

/// A card representing a curated audio Playlist entity.
/// Replaces individual affirmation quote cards on discovery & browse surfaces.
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final Color accentColor;
  final String? matchPercent;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final double? width;
  final double imageHeight;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    required this.accentColor,
    this.matchPercent,
    this.onTap,
    this.onPlayTap,
    this.width,
    this.imageHeight = 116.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16.0,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Cover Image with Metadata Badges & Quick Play
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(19.0),
                    topRight: Radius.circular(19.0),
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      playlist.imagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 420,
                      cacheHeight: 260,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: Icon(
                            Icons.self_improvement_rounded,
                            color: AppColors.textMuted,
                            size: 44.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category atmospheric tint overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(19.0),
                      topRight: Radius.circular(19.0),
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-Left: Duration Badge (Zero-overhead high performance frosted glass)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.5, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1A110D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          playlist.duration,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-Right: PRO or FREE Badge (Zero-overhead high performance frosted glass)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: playlist.isPremium
                          ? const Color(0xEE2A1E11)
                          : const Color(0xEE16261B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: playlist.isPremium
                            ? AppColors.goldAccent.withOpacity(0.8)
                            : accentColor.withOpacity(0.7),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          playlist.isPremium
                              ? Icons.lock_rounded
                              : Icons.auto_awesome_rounded,
                          size: 9.5,
                          color: playlist.isPremium
                              ? AppColors.goldAccent
                              : Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          playlist.isPremium ? 'PRO' : 'FREE',
                          style: GoogleFonts.inter(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: playlist.isPremium
                                ? AppColors.goldAccent
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom-Left: Optional Vector Match Badge
                if (matchPercent != null && matchPercent!.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        matchPercent!,
                        style: GoogleFonts.inter(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                // Bottom-Right: Quick Play Button
                Positioned(
                  bottom: 7,
                  right: 7,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onPlayTap ?? onTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.45),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Playlist Title & Information
            Padding(
              padding: const EdgeInsets.fromLTRB(11.0, 10.0, 11.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    playlist.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5.0),

                  // Subtitle / Clinical Tag
                  Text(
                    _getSubtitleText(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7.0),

                  // Metadata Row: Track count & Category pill
                  Row(
                    children: [
                      const Icon(
                        Icons.headphones_rounded,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${playlist.affirmations.length} tracks',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
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
    );
  }

  String _getSubtitleText() {
    if (playlist.subtitle != null && playlist.subtitle!.isNotEmpty) {
      return playlist.subtitle!;
    }
    if (playlist.targetSubLevels != null &&
        playlist.targetSubLevels!.isNotEmpty) {
      return playlist.targetSubLevels!.first;
    }
    return playlist.category;
  }
}
