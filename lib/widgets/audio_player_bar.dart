import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../screens/player/player_screen.dart';

class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({Key? key}) : super(key: key);

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final playlist = audioProvider.currentPlaylist;

    if (playlist == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: const [
          // Stronger layered shadow
          BoxShadow(
            color: Color(0x0A4A3E37),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x144A3E37),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.94),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlayerScreen()),
                );
              },
              child: Stack(
                children: [
                  // Animated gradient progress line at the top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          height: 2.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentForMode(
                                        appProvider.isGrowthMode)
                                    .withOpacity(0.3),
                                AppColors.accentForMode(
                                    appProvider.isGrowthMode),
                                AppColors.accentForMode(
                                        appProvider.isGrowthMode)
                                    .withOpacity(0.3),
                              ],
                              stops: [
                                0.0,
                                _progressController.value,
                                1.0,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      children: [
                        // Rounded album art with subtle ring/glow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.glowAccent,
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ],
                            border: Border.all(
                                color: AppColors.goldAccent.withOpacity(0.3),
                                width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.5),
                            child: Image.asset(
                              playlist.imagePath,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.surfaceElevated,
                                  child: const Icon(Icons.spa,
                                      color: AppColors.textPrimary),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                playlist.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                audioProvider.currentAffirmation?.quote ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: IconButton(
                            key: ValueKey<bool>(audioProvider.isPlaying),
                            icon: Icon(
                              audioProvider.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: AppColors.accentForMode(
                                  appProvider.isGrowthMode),
                              size: 38,
                            ),
                            onPressed: () {
                              audioProvider.togglePlayPause();
                            },
                          ),
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
