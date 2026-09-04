import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
import '../../services/personalization_engine.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  static const List<String> _libraryCategories = [
    'All',
    'Anxiety & Calm',
    'Career & Focus',
    'Heartbreak & Grief',
    'Neurodiversity',
    'Sleep & Rest',
  ];

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

  bool _matchesCategory(Playlist p, String category) {
    if (category == 'All') return true;
    final catLower = category.toLowerCase();
    if (catLower.contains('anxiety') || catLower.contains('calm')) {
      return p.category.toLowerCase().contains('anxiety') ||
          p.category.toLowerCase().contains('calm') ||
          p.id.contains('anxiety') ||
          p.id.contains('stress') ||
          p.title.toLowerCase().contains('anxiety') ||
          p.title.toLowerCase().contains('calm') ||
          (p.tags != null && p.tags!.any((t) => t.contains('anxiety') || t.contains('calm') || t.contains('stress')));
    }
    if (catLower.contains('career') || catLower.contains('focus')) {
      return p.category.toLowerCase().contains('career') ||
          p.category.toLowerCase().contains('focus') ||
          p.category.toLowerCase().contains('wealth') ||
          p.category.toLowerCase().contains('performance') ||
          p.id.contains('career') ||
          p.id.contains('wealth') ||
          p.id.contains('performance') ||
          p.id.contains('flow') ||
          p.title.toLowerCase().contains('career') ||
          p.title.toLowerCase().contains('focus') ||
          (p.tags != null && p.tags!.any((t) => t.contains('career') || t.contains('focus') || t.contains('wealth') || t.contains('flow')));
    }
    if (catLower.contains('heartbreak') || catLower.contains('grief')) {
      return p.category.toLowerCase().contains('heartbreak') ||
          p.category.toLowerCase().contains('grief') ||
          p.id.contains('heartbreak') ||
          p.id.contains('grief') ||
          p.title.toLowerCase().contains('heartbreak') ||
          p.title.toLowerCase().contains('grief') ||
          (p.tags != null && p.tags!.any((t) => t.contains('heartbreak') || t.contains('grief') || t.contains('breakup')));
    }
    if (catLower.contains('neurodiversity')) {
      return p.category.toLowerCase().contains('adhd') ||
          p.category.toLowerCase().contains('neuro') ||
          p.id.contains('adhd') ||
          p.id.contains('neuro') ||
          p.title.toLowerCase().contains('adhd') ||
          p.title.toLowerCase().contains('neuro') ||
          (p.tags != null && p.tags!.any((t) => t.contains('adhd') || t.contains('neuro')));
    }
    if (catLower.contains('sleep') || catLower.contains('rest')) {
      return p.category.toLowerCase().contains('sleep') ||
          p.category.toLowerCase().contains('rest') ||
          p.id.contains('sleep') ||
          p.id.contains('rest') ||
          p.title.toLowerCase().contains('sleep') ||
          p.title.toLowerCase().contains('rest') ||
          (p.tags != null && p.tags!.any((t) => t.contains('sleep') || t.contains('rest')));
    }
    return p.category.toLowerCase().contains(catLower);
  }

  bool _matchesAffirmation(Affirmation aff, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return aff.quote.toLowerCase().contains(q) ||
        aff.displayTitle.toLowerCase().contains(q) ||
        aff.category.toLowerCase().contains(q) ||
        aff.tags.any((t) => t.toLowerCase().contains(q)) ||
        aff.subLevels.any((s) => s.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    final bool isGrowth = appProvider.isGrowthMode;
    final Color accent =
        isGrowth ? AppColors.growthAccent : AppColors.healingAccent;
    final bool isPremium = appProvider.isPremium;
    final String query = _searchQuery.trim().toLowerCase();

    // Build Favorites List
    List<Map<String, dynamic>> favoriteItems = [];
    for (var playlist in allPlaylists) {
      for (var aff in playlist.affirmations) {
        if (appProvider.favoriteAffirmations.contains(aff.id)) {
          if (_matchesAffirmation(aff, query)) {
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
      if (_matchesAffirmation(aff, query)) {
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

    // Get Ranked Personalized Playlists using 16D Cosine Similarity
    final rankedMatches = appProvider.getPersonalizedPlaylists();
    List<PlaylistMatch> displayedMatches = rankedMatches;
    if (query.isNotEmpty) {
      displayedMatches = rankedMatches.where((m) {
        final p = m.playlist;
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesCategory = p.category.toLowerCase().contains(query);
        final matchesTags = p.tags != null && p.tags!.any((t) => t.toLowerCase().contains(query));
        final matchesSubLevels = p.targetSubLevels != null && p.targetSubLevels!.any((s) => s.toLowerCase().contains(query));
        final matchesAffirmations = p.affirmations.any((a) => _matchesAffirmation(a, query));
        return matchesTitle || matchesCategory || matchesTags || matchesSubLevels || matchesAffirmations;
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
                                      title: aff.displayTitle,
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
                              Flexible(
                                child: Container(
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                      title: aff.displayTitle,
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

                // 5. Daily Tailored Session (Dynamic Situational Playlist for Active User)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '🎯 Daily Tailored Session',
                                style: AppTextStyles.sectionHeader,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.goldAccent.withOpacity(0.3)),
                              ),
                              child: Text(
                                '100% Match',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final tailoredPlaylist = appProvider.getSituationalPlaylist();
                            final primaryArchetype = appProvider.userProfileVector.primaryArchetypes.isNotEmpty
                                ? appProvider.userProfileVector.primaryArchetypes.first
                                : UserArchetype.careerProfessional;
                            final primaryMeta = ArchetypeRegistry.getMetadata(primaryArchetype);
                            final userSubLevel = appProvider.userProfileVector.selectedSubLevels.isNotEmpty
                                ? appProvider.userProfileVector.selectedSubLevels.first
                                : primaryMeta.title;

                            return GlassCard(
                              accentColor: accent,
                              glowIntensity: 0.35,
                              onTap: () {
                                audioProvider.openPlaylist(
                                  appProvider.adaptPlaylistForUser(tailoredPlaylist),
                                  context,
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: accent.withOpacity(0.28)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        primaryMeta.icon,
                                        style: const TextStyle(fontSize: 26),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tailoredPlaylist.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Focus: $userSubLevel',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.goldAccent,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.headphones_rounded,
                                                size: 12, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${tailoredPlaylist.affirmations.length} tracks · ${tailoredPlaylist.duration}',
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: accent.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.play_arrow_rounded,
                                            size: 16, color: accent),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Play',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Premium CTA Banner
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

                // 7. Playlist Feed: Search Results OR Top 8 + Category Explorer
                if (query.isNotEmpty) ...[
                  ...displayedMatches.map((match) => _buildPlaylistSliver(
                        match: match,
                        accent: accent,
                        isPremium: isPremium,
                        audioProvider: audioProvider,
                        appProvider: appProvider,
                        screenWidth: screenWidth,
                        query: query,
                      )),
                ] else ...[
                  // 7a. Top 8 Personalized Playlists (shown only when category is 'All')
                  if (_selectedCategory == 'All') ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
                        child: Row(
                          children: [
                            Text(
                              '🔥 Top Recommendations',
                              style: AppTextStyles.sectionHeader,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Top 8',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...displayedMatches.take(8).map((match) => _buildPlaylistSliver(
                          match: match,
                          accent: accent,
                          isPremium: isPremium,
                          audioProvider: audioProvider,
                          appProvider: appProvider,
                          screenWidth: screenWidth,
                          query: '',
                        )),
                  ],

                  // 7b. Explore Library Header + Category Selector Pills
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: _selectedCategory == 'All' ? 36 : 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedCategory == 'All'
                                    ? '📚 Explore Library'
                                    : '📁 $_selectedCategory',
                                style: AppTextStyles.sectionHeader,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _selectedCategory == 'All'
                                      ? '${allPlaylists.length} Playlists'
                                      : '${displayedMatches.where((m) => _matchesCategory(m.playlist, _selectedCategory)).length} Playlists',
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
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _libraryCategories.length,
                              itemBuilder: (context, index) {
                                final cat = _libraryCategories[index];
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    selectedColor: accent.withOpacity(0.18),
                                    backgroundColor: AppColors.surfaceElevated,
                                    side: BorderSide(
                                      color: isSelected ? accent : AppColors.border,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    labelStyle: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? accent
                                          : AppColors.textSecondary,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedCategory = cat);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filtered Category Playlists
                  ...displayedMatches
                      .where((m) {
                        if (_selectedCategory == 'All') {
                          return displayedMatches.indexOf(m) >= 8 &&
                              displayedMatches.indexOf(m) < 16;
                        }
                        return _matchesCategory(m.playlist, _selectedCategory);
                      })
                      .map((match) => _buildPlaylistSliver(
                            match: match,
                            accent: accent,
                            isPremium: isPremium,
                            audioProvider: audioProvider,
                            appProvider: appProvider,
                            screenWidth: screenWidth,
                            query: '',
                          )),
                ],

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

  Widget _buildPlaylistSliver({
    required PlaylistMatch match,
    required Color accent,
    required bool isPremium,
    required AudioProvider audioProvider,
    required AppProvider appProvider,
    required double screenWidth,
    required String query,
  }) {
    final playlist = match.playlist;
    final affirmations = query.isEmpty
        ? playlist.affirmations
        : playlist.affirmations
            .where((a) => _matchesAffirmation(a, query))
            .toList();

    if (affirmations.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    playlist.title,
                    style: AppTextStyles.sectionHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Match Badge
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accent.withOpacity(0.28)),
                  ),
                  child: Text(
                    match.matchPercent,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (playlist.isPremium) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.goldAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock_rounded,
                            size: 10, color: AppColors.goldAccent),
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (playlist.isPremium && !isPremium) {
                      PaywallModal.show(context);
                    } else {
                      audioProvider.openPlaylist(
                        appProvider.adaptPlaylistForUser(playlist),
                        context,
                      );
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
                        title: aff.displayTitle,
                        quote: aff.quote,
                        playlistName: playlist.title,
                        imagePath: playlist.imagePath,
                        durationMinutes: _getAffirmationDuration(playlist),
                        isFavorite:
                            appProvider.favoriteAffirmations.contains(aff.id),
                        accentColor: accent,
                        onTap: () {
                          if (playlist.isPremium && !isPremium) {
                            PaywallModal.show(context);
                          } else {
                            audioProvider.openPlaylist(playlist, context, index);
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
  }
}
