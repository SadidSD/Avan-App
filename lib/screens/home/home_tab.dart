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
import '../../models/user_archetype.dart';

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
    final Color accent =
        isGrowth ? AppColors.growthAccent : AppColors.healingAccent;
    final bool isPremium = appProvider.isPremium;

    // Build Favorites List
    List<Map<String, dynamic>> favoriteItems = [];
    for (var playlist in allPlaylists) {
      for (var aff in playlist.affirmations) {
        if (appProvider.favoriteAffirmations.contains(aff.id)) {
          if (_searchQuery.isEmpty ||
              aff.quote.toLowerCase().contains(_searchQuery.toLowerCase())) {
            favoriteItems.add({
              'affirmation': aff,
              'playlist': playlist,
            });
          }
        }
      }
    }

    // Build Just For You List using Vector Personalization Engine
    final personalizedAffs = appProvider.getPersonalizedFeed(limit: 12);
    List<Map<String, dynamic>> justForYouItems = [];

    for (var aff in personalizedAffs) {
      if (_searchQuery.isEmpty ||
          aff.quote.toLowerCase().contains(_searchQuery.toLowerCase())) {
        final matchingPlaylist = allPlaylists.firstWhere(
          (p) => p.category == aff.category || p.affirmations.any((a) => a.id == aff.id),
          orElse: () => allPlaylists.first,
        );
        justForYouItems.add({
          'affirmation': aff,
          'playlist': matchingPlaylist,
        });
      }
    }

    // Filter Playlists
    List<Playlist> displayedPlaylists = allPlaylists;
    if (_searchQuery.isNotEmpty) {
      displayedPlaylists = allPlaylists.where((p) {
        final matchesTitle =
            p.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesAffirmation = p.affirmations.any((a) =>
            a.quote.toLowerCase().contains(_searchQuery.toLowerCase()));
        return matchesTitle || matchesAffirmation;
      }).toList();
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedCosmicBackground(
      mode: appProvider.appModeSetting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Top Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 16),
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

                // 2. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: LiquidGlassSearchBar(
                      onChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                      accentColor: accent,
                    ),
                  ),
                ),

                // 3. Favorites Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 24),
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
                                      durationMinutes:
                                          _getAffirmationDuration(playlist),
                                      isFavorite: true,
                                      accentColor: accent,
                                      onTap: () {
                                        audioProvider.openAffirmation(
                                          affirmation: aff,
                                          parentPlaylist: playlist,
                                          context: context,
                                        );
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

                // 4. Just for You Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '✨ Just for You',
                              style: AppTextStyles.sectionHeader,
                            ),
                            const SizedBox(width: 8),
                            if (appProvider.userProfileVector.primaryArchetypes.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accent.withOpacity(0.25)),
                                ),
                                child: Text(
                                  appProvider.userProfileVector.selectedSubLevels.isNotEmpty
                                      ? appProvider.userProfileVector.selectedSubLevels.first
                                      : ArchetypeRegistry.getMetadata(appProvider.userProfileVector.primaryArchetypes.first).title,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
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
                                      durationMinutes:
                                          _getAffirmationDuration(playlist),
                                      isFavorite: appProvider
                                          .favoriteAffirmations
                                          .contains(aff.id),
                                      accentColor: accent,
                                      onTap: () {
                                        audioProvider.openAffirmation(
                                          affirmation: aff,
                                          parentPlaylist: playlist,
                                          context: context,
                                        );
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

                // 5. Premium CTA Banner
                if (!isPremium)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 24),
                      child: PremiumCtaBanner(
                        onTap: () => PaywallModal.show(context),
                      ),
                    ),
                  ),

                // 6. Other Playlist Sections (Each with Playlist Title + Horizontal Affirmation Cards)
                ...displayedPlaylists.map((playlist) {
                  // If searching, filter affirmations matching the search query within this playlist
                  final affirmations = _searchQuery.isEmpty
                      ? playlist.affirmations
                      : playlist.affirmations
                          .where((a) => a.quote
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (affirmations.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Playlist Header Row
                          Row(
                            children: [
                              Text(
                                playlist.title,
                                style: AppTextStyles.sectionHeader,
                              ),
                              if (playlist.isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.goldAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.goldAccent
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.lock_rounded,
                                          size: 10,
                                          color: AppColors.goldAccent),
                                      SizedBox(width: 3),
                                      Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.goldAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  if (playlist.isPremium && !isPremium) {
                                    PaywallModal.show(context);
                                  } else {
                                    audioProvider.openPlaylist(
                                        playlist, context);
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill_rounded,
                                      size: 16,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Play All',
                                      style: AppTextStyles.modeLabel(accent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Horizontal Carousel of Affirmation Cards for this Playlist
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: affirmations.length,
                              itemBuilder: (context, index) {
                                final aff = affirmations[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: screenWidth * 0.7,
                                    child: AffirmationCard(
                                      quote: aff.quote,
                                      playlistName: playlist.title,
                                      imagePath: playlist.imagePath,
                                      durationMinutes:
                                          _getAffirmationDuration(playlist),
                                      isFavorite: appProvider
                                          .favoriteAffirmations
                                          .contains(aff.id),
                                      accentColor: accent,
                                      onTap: () {
                                        if (playlist.isPremium && !isPremium) {
                                          PaywallModal.show(context);
                                        } else {
                                          audioProvider.openPlaylist(
                                              playlist, context, index);
                                        }
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
                  );
                }).toList(),

                // Bottom Spacer for floating nav bar
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
