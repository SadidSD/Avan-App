import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_cosmic_background.dart';
import '../../widgets/mode_toggle_pill.dart';
import '../../widgets/liquid_glass_search_bar.dart';
import '../../widgets/affirmation_card.dart';
import '../../widgets/premium_cta_banner.dart';
import '../../widgets/paywall_modal.dart';
import '../../data/playlists_data.dart';
import '../../models/playlist.dart';
import '../../models/affirmation.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _entryController;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  int _parseDurationMinutes(String dur) {
    return int.tryParse(dur.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
  }

  int _getAffirmationDuration(Playlist playlist) {
    if (playlist.affirmations.isEmpty) return 1;
    final totalMinutes = _parseDurationMinutes(playlist.duration);
    return (totalMinutes / playlist.affirmations.length).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    
    final bool isGrowth = appProvider.isGrowthMode;
    final Color accent = isGrowth ? AppColors.growthAccent : AppColors.healingAccent;
    final bool isPremium = appProvider.isPremium;

    // Build Favorites List
    List<Map<String, dynamic>> favoriteItems = [];
    for (var playlist in allPlaylists) {
      for (var aff in playlist.affirmations) {
        if (appProvider.favoriteAffirmations.contains(aff.id)) {
          if (_searchQuery.isEmpty || aff.quote.toLowerCase().contains(_searchQuery.toLowerCase())) {
            favoriteItems.add({
              'affirmation': aff,
              'playlist': playlist,
            });
          }
        }
      }
    }

    // Build Just For You List
    List<Map<String, dynamic>> justForYouItems = [];
    if (isGrowth) {
      for (var i = 0; i < math.min(2, freePlaylists.length); i++) {
        var playlist = freePlaylists[i];
        for (var aff in playlist.affirmations) {
          justForYouItems.add({
            'affirmation': aff,
            'playlist': playlist,
          });
        }
      }
      justForYouItems.shuffle();
      if (justForYouItems.length > 8) justForYouItems = justForYouItems.sublist(0, 8);
    } else {
      for (var playlist in premiumPlaylists) {
        if (playlist.category == 'Anxiety Relief' || 
            playlist.category == 'Self Love' || 
            playlist.category == 'Calm Mind') {
          for (var aff in playlist.affirmations) {
            justForYouItems.add({
              'affirmation': aff,
              'playlist': playlist,
            });
          }
        }
      }
      justForYouItems.shuffle();
      if (justForYouItems.length > 8) justForYouItems = justForYouItems.sublist(0, 8);
    }

    if (_searchQuery.isNotEmpty) {
      justForYouItems = justForYouItems.where((item) {
        Affirmation aff = item['affirmation'];
        return aff.quote.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Build Explored Playlists
    List<Playlist> exploredPlaylists = allPlaylists;
    if (_searchQuery.isNotEmpty) {
      exploredPlaylists = exploredPlaylists.where((p) => 
        p.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 52) / 2;

    return AnimatedCosmicBackground(
      mode: appProvider.appModeSetting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryAnimation,
            child: CustomScrollView(
              slivers: [
                // Top Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: Row(
                      children: [
                        Text(
                          'AVAN',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        ModeTogglePill(
                          currentMode: appProvider.appModeSetting,
                          onModeChanged: (mode) {
                            appProvider.setAppMode(mode);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: LiquidGlassSearchBar(
                      onChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                      accentColor: accent,
                    ),
                  ),
                ),

                // Favorites Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '❤️ Favorites',
                              style: AppTextStyles.sectionHeader,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (favoriteItems.isEmpty)
                          GlassCard(
                            accentColor: accent,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'Tap ❤️ on any affirmation to save it here',
                                  style: AppTextStyles.cardSubtitle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: favoriteItems.length,
                              itemBuilder: (context, index) {
                                final item = favoriteItems[index];
                                final Affirmation aff = item['affirmation'];
                                final Playlist playlist = item['playlist'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: screenWidth * 0.7,
                                    child: AffirmationCard(
                                      quote: aff.quote,
                                      playlistName: playlist.title,
                                      imagePath: playlist.imagePath,
                                      durationMinutes: _getAffirmationDuration(playlist),
                                      isFavorite: true,
                                      accentColor: accent,
                                      onTap: () {
                                        audioProvider.openPlaylist(playlist, context);
                                      },
                                      onFavoriteToggle: () {
                                        appProvider.toggleFavorite(aff.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Just for You Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '✨ Just for You',
                              style: AppTextStyles.sectionHeader,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (justForYouItems.isNotEmpty)
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: justForYouItems.length,
                              itemBuilder: (context, index) {
                                final item = justForYouItems[index];
                                final Affirmation aff = item['affirmation'];
                                final Playlist playlist = item['playlist'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: screenWidth * 0.7,
                                    child: AffirmationCard(
                                      quote: aff.quote,
                                      playlistName: playlist.title,
                                      imagePath: playlist.imagePath,
                                      durationMinutes: _getAffirmationDuration(playlist),
                                      isFavorite: appProvider.favoriteAffirmations.contains(aff.id),
                                      accentColor: accent,
                                      onTap: () {
                                        audioProvider.openPlaylist(playlist, context);
                                      },
                                      onFavoriteToggle: () {
                                        appProvider.toggleFavorite(aff.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Premium CTA
                if (!isPremium)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                      child: PremiumCtaBanner(
                        onTap: () => PaywallModal.show(context),
                      ),
                    ),
                  ),

                // Explore Playlists Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 14),
                    child: Row(
                      children: [
                        Text(
                          '📚 Explore Playlists',
                          style: AppTextStyles.sectionHeader,
                        ),
                        const Spacer(),
                        Text(
                          'See All',
                          style: AppTextStyles.modeLabel(accent),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: exploredPlaylists.map((playlist) {
                        return GestureDetector(
                          onTap: () {
                            if (playlist.isPremium && !isPremium) {
                              PaywallModal.show(context);
                            } else {
                              audioProvider.openPlaylist(playlist, context);
                            }
                          },
                          child: SizedBox(
                            width: cardWidth,
                            child: GlassCard(
                              accentColor: accent,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 100,
                                      width: double.infinity,
                                      child: Image.asset(
                                        playlist.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.white10,
                                          child: const Icon(Icons.image, color: Colors.white24),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          playlist.title,
                                          style: AppTextStyles.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (playlist.isPremium)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            size: 14,
                                            color: AppColors.goldAccent,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${playlist.affirmations.length} affirmations',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const Spacer(),
                                      Text(
                                        playlist.duration,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Bottom Spacer
                const SliverToBoxAdapter(
                  child: SizedBox(height: 140),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
