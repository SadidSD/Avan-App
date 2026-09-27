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
import '../../widgets/playlist_card.dart';
import '../../widgets/playlist_tracklist_sheet.dart';
import '../../widgets/premium_cta_banner.dart';
import '../../widgets/paywall_modal.dart';
import '../paywall/paywall_screen.dart';
import '../../data/playlists_data.dart';
import '../../data/playlist_groups.dart';
import '../../models/playlist.dart';
import '../../models/affirmation.dart';
import '../../models/user_archetype.dart';
import '../../services/personalization_engine.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String _searchQuery = '';
  String _selectedGroupId = 'all';

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _entryController;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {}); // Re-evaluates circadian time of day and midnight day seed
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  bool _matchesAffirmation(Affirmation aff, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return aff.quote.toLowerCase().contains(q) ||
        aff.displayTitle.toLowerCase().contains(q) ||
        aff.category.toLowerCase().contains(q) ||
        aff.tags.any((t) => t.toLowerCase().contains(q)) ||
        aff.subLevels.any((s) => s.toLowerCase().contains(q));
  }

  bool _matchesPlaylist(Playlist p, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final matchesTitle = p.title.toLowerCase().contains(q);
    final matchesCategory = p.category.toLowerCase().contains(q);
    final matchesTags = p.tags != null && p.tags!.any((t) => t.toLowerCase().contains(q));
    final matchesSubLevels = p.targetSubLevels != null &&
        p.targetSubLevels!.any((s) => s.toLowerCase().contains(q));
    final matchesAffirmations =
        p.affirmations.any((a) => _matchesAffirmation(a, q));
    return matchesTitle ||
        matchesCategory ||
        matchesTags ||
        matchesSubLevels ||
        matchesAffirmations;
  }

  void _handlePlaylistTap({
    required BuildContext context,
    required Playlist playlist,
    required AppProvider appProvider,
    required AudioProvider audioProvider,
    required Color accent,
  }) {
    PlaylistTracklistSheet.show(
      context: context,
      playlist: playlist,
      accentColor: accent,
    );
  }

  void _handlePlayTap({
    required BuildContext context,
    required Playlist playlist,
    required AppProvider appProvider,
    required AudioProvider audioProvider,
  }) {
    if (playlist.isPremium && !appProvider.isPremium) {
      PaywallModal.show(context);
    } else {
      audioProvider.openPlaylist(
        appProvider.adaptPlaylistForUser(playlist),
        context,
      );
    }
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

    // Ranked matches using 16D vector engine
    final rankedMatches = appProvider.getPersonalizedPlaylists();
    final Map<String, PlaylistMatch> matchMap = {
      for (final m in rankedMatches) m.playlist.id: m,
    };
    final orderedGroups = getOrderedPlaylistGroups(isGrowthMode: isGrowth);

    // Hero daily tailored playlist & hero affirmation
    final tailoredPlaylist = appProvider.getSituationalPlaylist();
    final primaryArchetype = appProvider.userProfileVector.primaryArchetypes.isNotEmpty
        ? appProvider.userProfileVector.primaryArchetypes.first
        : UserArchetype.careerProfessional;
    final primaryMeta = ArchetypeRegistry.getMetadata(primaryArchetype);
    final userSubLevel = appProvider.userProfileVector.selectedSubLevels.isNotEmpty
        ? appProvider.userProfileVector.selectedSubLevels.first
        : primaryMeta.title;

    final heroAffirmation = tailoredPlaylist.affirmations.isNotEmpty
        ? tailoredPlaylist.affirmations.first
        : allPlaylists.first.affirmations.first;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridCardWidth = (screenWidth - 52) / 2;

    return AnimatedCosmicBackground(
      mode: appProvider.appModeSetting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryAnimation,
            child: RefreshIndicator(
              color: accent,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: () async {
                if (mounted) {
                  setState(() {});
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                cacheExtent: 500.0,
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
                          currentMode: appProvider.activeAppMode,
                          onModeChanged: (mode) {
                            setState(() => _selectedGroupId = 'all');
                            appProvider.setAppMode(mode);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Daily Mood Check-In
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: _buildMoodCheckIn(appProvider, accent),
                  ),
                ),

                // 3. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: LiquidGlassSearchBar(
                      onChanged: (q) {
                        setState(() => _searchQuery = q);
                      },
                      accentColor: accent,
                    ),
                  ),
                ),

                // Search View: Renders 2-column grid of matching PlaylistCards
                if (query.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Text(
                        'Search Results for "$query"',
                        style: AppTextStyles.sectionHeader,
                      ),
                    ),
                  ),
                  _buildSearchGridSliver(
                    query: query,
                    accent: accent,
                    gridCardWidth: gridCardWidth,
                    appProvider: appProvider,
                    audioProvider: audioProvider,
                    matchMap: matchMap,
                  ),
                ] else ...[
                  // 4. Daily Mindset Catalyst (Single Affirmation Card for daily quote reflection)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '✨ Daily Mindset Catalyst',
                                  style: AppTextStyles.sectionHeader,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    primaryMeta.icon,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 130),
                                    child: Text(
                                      userSubLevel,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RepaintBoundary(
                            child: AffirmationCard(
                              title: 'Calibrated for You',
                              quote: heroAffirmation.quote,
                              playlistName: tailoredPlaylist.title,
                              imagePath: tailoredPlaylist.imagePath,
                              durationMinutes: _getAffirmationDuration(tailoredPlaylist),
                              isFavorite: appProvider.favoriteAffirmations.contains(heroAffirmation.id),
                              accentColor: accent,
                              onTap: () {
                                audioProvider.openAffirmation(
                                  affirmation: heroAffirmation,
                                  parentPlaylist: tailoredPlaylist,
                                  context: context,
                                );
                              },
                              onFavoriteToggle: () {
                                appProvider.toggleFavorite(heroAffirmation.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Daily Tailored Session Hero Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '🎯 Daily Tailored Session',
                                  style: AppTextStyles.sectionHeader,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.goldAccent.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.goldAccent.withOpacity(0.35)),
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
                          RepaintBoundary(
                            child: GlassCard(
                              accentColor: accent,
                              glowIntensity: 0.35,
                              onTap: () {
                                _handlePlaylistTap(
                                  context: context,
                                  playlist: tailoredPlaylist,
                                  appProvider: appProvider,
                                  audioProvider: audioProvider,
                                  accent: accent,
                                );
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: SizedBox(
                                      width: 58,
                                      height: 58,
                                       child: Image.asset(
                                         tailoredPlaylist.imagePath,
                                         fit: BoxFit.cover,
                                         cacheWidth: 150,
                                         cacheHeight: 150,
                                         errorBuilder: (_, __, ___) => Container(
                                          color: accent.withOpacity(0.14),
                                          child: Center(
                                            child: Text(primaryMeta.icon, style: const TextStyle(fontSize: 24)),
                                          ),
                                        ),
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
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.headphones_rounded, size: 12, color: AppColors.textMuted),
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
                                  GestureDetector(
                                    onTap: () {
                                      _handlePlayTap(
                                        context: context,
                                        playlist: tailoredPlaylist,
                                        appProvider: appProvider,
                                        audioProvider: audioProvider,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: accent.withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_arrow_rounded, size: 16, color: accent),
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. Premium Banner
                  if (!isPremium)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 22),
                        child: PremiumCtaBanner(
                          onTap: () => PaywallScreen.open(context),
                        ),
                      ),
                    ),

                  // 7. Group Category Pills Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '📚 Playlist Library',
                                  style: AppTextStyles.sectionHeader,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isGrowth
                                      ? '${allPlaylists.length} Playlists · Growth'
                                      : '${allPlaylists.length} Playlists · Healing',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RepaintBoundary(
                            child: SizedBox(
                              height: 42,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildGroupChip(
                                    id: 'all',
                                    label: 'All Groups',
                                    emoji: '✨',
                                    accent: accent,
                                  ),
                                  ...orderedGroups.map((g) => _buildGroupChip(
                                        id: g.id,
                                        label: g.title,
                                        emoji: g.emoji,
                                        accent: accent,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 8. Content View: If specific group is selected, show 2-column grid. If 'all', show curated carousels.
                  if (_selectedGroupId != 'all') ...[
                    _buildSingleGroupSliver(
                      groupId: _selectedGroupId,
                      accent: accent,
                      gridCardWidth: gridCardWidth,
                      appProvider: appProvider,
                      audioProvider: audioProvider,
                      matchMap: matchMap,
                    ),
                  ] else ...[
                    // 8a. Top Recommendations Carousel (Vector Personalized Playlists)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    isGrowth ? '🌿 Recommended For Growth' : '🌊 Recommended For Healing',
                                    style: AppTextStyles.sectionHeader,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isGrowth ? 'Growth Engine' : 'Healing Engine',
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            RepaintBoundary(
                              child: SizedBox(
                                height: 232,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: rankedMatches.take(8).length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final match = rankedMatches[index];
                                    return PlaylistCard(
                                      playlist: match.playlist,
                                      accentColor: accent,
                                      matchPercent: match.matchPercent,
                                      width: 168,
                                      onTap: () {
                                        _handlePlaylistTap(
                                          context: context,
                                          playlist: match.playlist,
                                          appProvider: appProvider,
                                          audioProvider: audioProvider,
                                          accent: accent,
                                        );
                                      },
                                      onPlayTap: () {
                                        _handlePlayTap(
                                          context: context,
                                          playlist: match.playlist,
                                          appProvider: appProvider,
                                          audioProvider: audioProvider,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 8b. Thematic Group Carousels for each Group
                    ...orderedGroups.map((group) {
                      final playlists = group.getSortedPlaylists(matchMap);
                      if (playlists.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${group.emoji} ${group.title}',
                                      style: AppTextStyles.sectionHeader,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedGroupId = group.id);
                                    },
                                    child: Text(
                                      'See All (${playlists.length})',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                group.description,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              RepaintBoundary(
                                child: SizedBox(
                                  height: 232,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: playlists.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final p = playlists[index];
                                      final match = matchMap[p.id];
                                      return PlaylistCard(
                                        playlist: p,
                                        accentColor: accent,
                                        matchPercent: match?.matchPercent,
                                        width: 168,
                                        onTap: () {
                                          _handlePlaylistTap(
                                            context: context,
                                            playlist: p,
                                            appProvider: appProvider,
                                            audioProvider: audioProvider,
                                            accent: accent,
                                          );
                                        },
                                        onPlayTap: () {
                                          _handlePlayTap(
                                            context: context,
                                            playlist: p,
                                            appProvider: appProvider,
                                            audioProvider: audioProvider,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],

                // Bottom spacer for floating navigation bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 140),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildGroupChip({
    required String id,
    required String label,
    required String emoji,
    required Color accent,
  }) {
    final isSelected = _selectedGroupId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedGroupId = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.18) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accent : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleGroupSliver({
    required String groupId,
    required Color accent,
    required double gridCardWidth,
    required AppProvider appProvider,
    required AudioProvider audioProvider,
    required Map<String, PlaylistMatch> matchMap,
  }) {
    final group = masterPlaylistGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => masterPlaylistGroups.first,
    );
    final playlists = group.getSortedPlaylists(matchMap);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${group.emoji} ${group.title}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${playlists.length} playlists',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              group.description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 14,
              children: playlists.map((p) {
                final match = matchMap[p.id];
                return PlaylistCard(
                  playlist: p,
                  accentColor: accent,
                  matchPercent: match?.matchPercent,
                  width: gridCardWidth,
                  onTap: () {
                    _handlePlaylistTap(
                      context: context,
                      playlist: p,
                      appProvider: appProvider,
                      audioProvider: audioProvider,
                      accent: accent,
                    );
                  },
                  onPlayTap: () {
                    _handlePlayTap(
                      context: context,
                      playlist: p,
                      appProvider: appProvider,
                      audioProvider: audioProvider,
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchGridSliver({
    required String query,
    required Color accent,
    required double gridCardWidth,
    required AppProvider appProvider,
    required AudioProvider audioProvider,
    required Map<String, PlaylistMatch> matchMap,
  }) {
    final matchingPlaylists = allPlaylists.where((p) => _matchesPlaylist(p, query)).toList();

    if (matchingPlaylists.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'No playlists found for "$query"',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 12,
          runSpacing: 14,
          children: matchingPlaylists.map((p) {
            final match = matchMap[p.id];
            return PlaylistCard(
              playlist: p,
              accentColor: accent,
              matchPercent: match?.matchPercent,
              width: gridCardWidth,
              onTap: () {
                _handlePlaylistTap(
                  context: context,
                  playlist: p,
                  appProvider: appProvider,
                  audioProvider: audioProvider,
                  accent: accent,
                );
              },
              onPlayTap: () {
                _handlePlayTap(
                  context: context,
                  playlist: p,
                  appProvider: appProvider,
                  audioProvider: audioProvider,
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMoodCheckIn(AppProvider appProvider, Color accent) {
    final moods = [
      {'label': 'Energized', 'emoji': '⚡', 'query': 'motivated'},
      {'label': 'Calm', 'emoji': '😌', 'query': 'peaceful'},
      {'label': 'Anxious', 'emoji': '😰', 'query': 'anxious'},
      {'label': 'Sad', 'emoji': '😔', 'query': 'sad'},
      {'label': 'Tired', 'emoji': '🌙', 'query': 'tired'},
      {'label': 'Grounded', 'emoji': '🌿', 'query': 'grounding'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HOW IS YOUR HEART TODAY?',
              style: AppTextStyles.sectionTitle,
            ),
            if (appProvider.selectedMood.isNotEmpty)
              GestureDetector(
                onTap: () => appProvider.setSelectedMood(''),
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: moods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final m = moods[index];
              final isSelected =
                  appProvider.selectedMood.toLowerCase() == m['query']!.toLowerCase();
              return GestureDetector(
                onTap: () => appProvider.setSelectedMood(m['query']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? accent.withOpacity(0.18) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accent : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: accent.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m['emoji']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        m['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? accent : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
