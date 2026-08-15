import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_cosmic_background.dart';
import '../../widgets/hero_quote_card.dart';
import '../../widgets/mode_toggle_pill.dart';
import '../../widgets/paywall_modal.dart';
import '../../data/playlists_data.dart';
import '../../models/playlist.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryAnimation;
  final TextEditingController _searchController = TextEditingController();

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
    _entryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);
    final accentSoft = AppColors.accentSoftForMode(isGrowth);
    final streakColor = AppColors.streakColorForMode(isGrowth);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final greetingEmoji = isGrowth ? '🌅' : '🌙';

    // Mode-specific content
    final heroQuote = isGrowth
        ? 'You are built for this. Every challenge is shaping you.'
        : 'You are held. You are safe. Healing takes time, and that is okay.';
    final moodPrompt = isGrowth ? 'How is your energy today?' : 'How is your heart today?';
    final streakLabel = isGrowth ? '🔥 Day Streak' : '💚 Healing Streak';

    // Playlists for current mode
    final recommendedPlaylists = isGrowth
        ? freePlaylists.take(4).toList()
        : (premiumPlaylists.take(4).toList());

    return AnimatedCosmicBackground(
      isGrowth: isGrowth,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- HEADER ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(
                      appProvider, accent, streakColor, greeting, greetingEmoji, streakLabel,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // --- MODE TOGGLE PILL ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ModeTogglePill(
                      currentMode: appProvider.appModeSetting,
                      onModeChanged: (mode) {
                        appProvider.setAppMode(mode);
                        _entryController.forward(from: 0.4);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- TODAY'S AFFIRMATION HERO CARD ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGrowth ? 'TODAY\'S AFFIRMATION' : 'TODAY\'S HEALING WORD',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: 12),
                        HeroQuoteCard(
                          quote: heroQuote,
                          isGrowth: isGrowth,
                          onListen: () {
                            if (freePlaylists.isNotEmpty) {
                              audioProvider.openPlaylist(freePlaylists.first, context);
                            }
                          },
                          onFavorite: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Saved to Favorites ✨',
                                    style: GoogleFonts.inter(color: AppColors.textPrimary)),
                                backgroundColor: AppColors.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Affirmation shared! 📤',
                                    style: GoogleFonts.inter(color: AppColors.textPrimary)),
                                backgroundColor: AppColors.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- MOOD CHECK-IN ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(moodPrompt.toUpperCase(), style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 14),
                        _buildMoodRow(appProvider, accent),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- PERSONALIZED PLAYLIST ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR PERSONALIZED PLAYLIST', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 14),
                        _buildPersonalizedCard(appProvider, audioProvider, accent, accentSoft, isGrowth),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- SITUATION SEARCH ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WHAT\'S YOUR SITUATION?', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 14),
                        _buildSituationSection(isGrowth, accent, audioProvider),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- RECOMMENDED PLAYLISTS ---
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('RECOMMENDED FOR YOU', style: AppTextStyles.sectionTitle),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'See All',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: recommendedPlaylists.length,
                          itemBuilder: (context, i) {
                            final playlist = recommendedPlaylists[i];
                            final isLocked = playlist.isPremium && !appProvider.isPremium;
                            return _buildPlaylistCard(
                              playlist, isLocked, accent, accentSoft, appProvider, audioProvider, context,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- STREAK & PROGRESS ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStreakCard(appProvider, accent, streakColor, isGrowth),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // --- QUICK ACTIONS ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPLORE', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 14),
                        _buildQuickActions(appProvider, accent, accentSoft, isGrowth),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(AppProvider appProvider, Color accent, Color streakColor, String greeting, String greetingEmoji, String streakLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greetingEmoji $greeting',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    streakLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: streakColor,
                    ),
                  ),
                  Text(
                    '  •  ${appProvider.streakData.currentStreak} days',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary, size: 24),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded,
              color: AppColors.textSecondary, size: 24),
          onPressed: () => appProvider.setNavIndex(4),
        ),
      ],
    );
  }

  // --- MOOD ROW ---
  Widget _buildMoodRow(AppProvider appProvider, Color accent) {
    final moods = [
      {'emoji': '🔥', 'label': 'Fired up'},
      {'emoji': '😌', 'label': 'Calm'},
      {'emoji': '😔', 'label': 'Low'},
      {'emoji': '😨', 'label': 'Anxious'},
      {'emoji': '💪', 'label': 'Strong'},
      {'emoji': '🕊️', 'label': 'At peace'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((m) {
        final isSelected = appProvider.selectedMood == m['emoji'];
        return GestureDetector(
          onTap: () => appProvider.setSelectedMood(m['emoji']!),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? accent.withOpacity(0.15) : AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accent.withOpacity(0.5) : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 10)]
                      : null,
                ),
                child: Text(m['emoji']!, style: TextStyle(fontSize: isSelected ? 22 : 18)),
              ),
              const SizedBox(height: 5),
              Text(
                m['label']!,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? accent : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- PERSONALIZED PLAYLIST CARD ---
  Widget _buildPersonalizedCard(AppProvider appProvider, AudioProvider audioProvider,
      Color accent, Color accentSoft, bool isGrowth) {
    final title = isGrowth ? 'Unshakeable Confidence' : 'Healing Your Heart';
    final desc = isGrowth
        ? 'Curated for focus & achievement'
        : 'Gentle affirmations for your healing journey';
    final emoji = isGrowth ? '🎯' : '💔';
    final targetPlaylist = isGrowth
        ? freePlaylists.firstWhere((p) => p.id.contains('energy'), orElse: () => freePlaylists.first)
        : freePlaylists.firstWhere((p) => p.id.contains('calm'), orElse: () => freePlaylists.first);

    return GlassCard(
      accentColor: accent,
      glowIntensity: 0.6,
      gradient: AppColors.cardGradientForMode(isGrowth),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 3),
                Text(desc,
                    style: AppTextStyles.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.headphones_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${targetPlaylist.affirmations.length} affirmations',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(targetPlaylist.duration, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => audioProvider.openPlaylist(targetPlaylist, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 12)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 18, color: accent),
                  const SizedBox(width: 4),
                  Text('Play', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SITUATION SECTION ---
  Widget _buildSituationSection(bool isGrowth, Color accent, AudioProvider audioProvider) {
    final situations = isGrowth
        ? [
            {'icon': '💼', 'text': 'I Have A Job Interview'},
            {'icon': '📚', 'text': 'I Have An Exam Tomorrow'},
            {'icon': '🚀', 'text': 'I Need To Build Confidence'},
          ]
        : [
            {'icon': '💔', 'text': 'I\'m Going Through A Breakup'},
            {'icon': '🕊️', 'text': 'I\'m Grieving A Loss'},
            {'icon': '😰', 'text': 'I\'m Feeling Overwhelmed'},
          ];

    return GlassCard(
      accentColor: accent,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe your situation...',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          // Situation items
          ...situations.map((s) {
            return InkWell(
              onTap: () {
                final p = freePlaylists.first;
                audioProvider.openPlaylist(p, context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Text(s['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s['text']!,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- PLAYLIST CARD ---
  Widget _buildPlaylistCard(Playlist playlist, bool isLocked, Color accent, Color accentSoft,
      AppProvider appProvider, AudioProvider audioProvider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          PaywallModal.show(context);
        } else {
          audioProvider.openPlaylist(playlist, context);
        }
      },
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.self_improvement_rounded, size: 18, color: accent),
                ),
                if (isLocked)
                  Icon(Icons.lock_rounded, size: 14, color: AppColors.textMuted)
                else
                  Icon(Icons.play_circle_rounded, size: 20, color: accent),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${playlist.duration} · ${playlist.affirmations.length} tracks',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STREAK CARD ---
  Widget _buildStreakCard(AppProvider appProvider, Color accent, Color streakColor, bool isGrowth) {
    final streak = appProvider.streakData;
    return GlassCard(
      accentColor: accent,
      glowIntensity: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('YOUR PROGRESS', style: AppTextStyles.sectionTitle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: streakColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: streakColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${streak.currentStreak} days',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: streakColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('${streak.currentStreak}', isGrowth ? '🔥 Streak' : '💚 Streak', accent),
              _divider(),
              _statItem('${streak.longestStreak}', 'Best', accent),
              _divider(),
              _statItem('${streak.totalListeningDays}', 'Total Days', accent),
            ],
          ),
          const SizedBox(height: 16),
          // Weekly dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              // weeklyProgress is 0.0–1.0 representing fraction of week completed
              final daysThisWeek = (streak.weeklyProgress * 7).round();
              final isActive = i < daysThisWeek;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? accent.withOpacity(0.15) : AppColors.surface,
                      border: Border.all(
                        color: isActive ? accent.withOpacity(0.5) : AppColors.border,
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? Icon(Icons.check_rounded, size: 14, color: accent)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isActive ? accent : AppColors.textMuted,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color accent) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: AppColors.border);
  }

  // --- QUICK ACTIONS ---
  Widget _buildQuickActions(AppProvider appProvider, Color accent, Color accentSoft, bool isGrowth) {
    final actions = [
      {
        'icon': Icons.menu_book_rounded,
        'label': isGrowth ? 'Journal' : 'Reflection',
        'desc': isGrowth ? 'Track your wins' : 'Write your feelings',
        'navIndex': 2,
      },
      {
        'icon': Icons.mic_rounded,
        'label': 'Say After Me',
        'desc': isGrowth ? 'Speak it into existence' : 'Affirm your healing',
        'navIndex': 1,
      },
      {
        'icon': Icons.dashboard_rounded,
        'label': 'Vision Board',
        'desc': isGrowth ? 'Visualize your goals' : 'Visualize recovery',
        'navIndex': 3,
      },
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () => appProvider.setNavIndex(a['navIndex'] as int),
            child: Container(
              margin: EdgeInsets.only(right: a['navIndex'] == 3 ? 0 : 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData, color: accent, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a['desc'] as String,
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
