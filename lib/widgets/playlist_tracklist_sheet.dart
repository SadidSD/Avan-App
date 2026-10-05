import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../providers/app_provider.dart';
import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../screens/say_after_me/say_after_me_tab.dart';
import 'paywall_modal.dart';

/// Modal bottom sheet displaying the playlist overview and its 10 affirmations.
class PlaylistTracklistSheet extends StatelessWidget {
  final Playlist playlist;
  final Color accentColor;

  const PlaylistTracklistSheet({
    Key? key,
    required this.playlist,
    required this.accentColor,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required Playlist playlist,
    required Color accentColor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaylistTracklistSheet(
        playlist: playlist,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final isPremiumUser = appProvider.isPremium;
    final isLocked = playlist.isPremium && !isPremiumUser;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  children: [
                    // Header Artwork & Details Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              playlist.imagePath,
                              fit: BoxFit.cover,
                              cacheWidth: 250,
                              cacheHeight: 250,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceElevated,
                                child: const Icon(
                                  Icons.self_improvement_rounded,
                                  color: AppColors.textMuted,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PRO or FREE badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? AppColors.goldAccent.withOpacity(0.18)
                                          : (playlist.isPremium
                                              ? AppColors.goldAccent.withOpacity(0.18)
                                              : accentColor.withOpacity(0.18)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isLocked
                                            ? AppColors.goldAccent.withOpacity(0.5)
                                            : (playlist.isPremium
                                                ? AppColors.goldAccent.withOpacity(0.5)
                                                : accentColor.withOpacity(0.5)),
                                      ),
                                    ),
                                    child: Text(
                                      isLocked
                                          ? 'PRO 🔒'
                                          : (playlist.isPremium ? 'UNLOCKED ✨' : 'FREE 🌿'),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isLocked || playlist.isPremium
                                            ? AppColors.goldAccent
                                            : accentColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${playlist.affirmations.length} tracks · ${playlist.duration}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                playlist.title,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                playlist.category,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Play All Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLocked ? AppColors.goldAccent : accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (isLocked) {
                          PaywallModal.show(context);
                        } else {
                          Navigator.pop(context);
                          audioProvider.openPlaylist(
                            appProvider.adaptPlaylistForUser(playlist),
                            context,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLocked ? Icons.lock_open_rounded : Icons.play_arrow_rounded,
                            size: 20,
                            color: isLocked ? Colors.black87 : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLocked ? 'Unlock with PRO' : 'Play Full Session',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isLocked ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Practice in Say After Me Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLocked ? AppColors.goldAccent : accentColor,
                        side: BorderSide(
                          color: (isLocked ? AppColors.goldAccent : accentColor).withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (isLocked) {
                          PaywallModal.show(context);
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SayAfterMeTab(
                                initialModeIndex: 0,
                                initialPlaylist: playlist,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.record_voice_over_rounded,
                            size: 18,
                            color: isLocked ? AppColors.goldAccent : accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Practice in Say After Me 🎙️',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isLocked ? AppColors.goldAccent : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Affirmations Tracklist Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SESSION TRACKS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Tap track to start',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tracks List
                    ...playlist.affirmations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final aff = entry.value;
                      final isFav = appProvider.favoriteAffirmations.contains(aff.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: accentColor.withOpacity(0.14),
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            title: Text(
                              aff.quote,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? accentColor : AppColors.textMuted,
                                size: 18,
                              ),
                              onPressed: () {
                                appProvider.toggleFavorite(aff.id);
                              },
                            ),
                            onTap: () {
                              if (isLocked) {
                                PaywallModal.show(context);
                              } else {
                                Navigator.pop(context);
                                audioProvider.openPlaylist(playlist, context, index);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
