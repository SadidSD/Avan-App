import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/paywall_modal.dart';
import '../../data/playlists_data.dart';
import '../../models/playlist.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    final isGrowth = appProvider.isGrowthMode;
    final hour = DateTime.now().hour;

    // Theme tokens based on mode
    final primaryColor = isGrowth ? AppColors.growthPrimary : AppColors.healingPrimary;
    final secondaryColor = isGrowth ? AppColors.growthSecondary : AppColors.healingSecondary;
    final accentColor = isGrowth ? AppColors.growthAccent : AppColors.healingAccent;
    final backgroundColor = isGrowth ? AppColors.growthBackground : AppColors.healingBackground;
    final cardBgColor = isGrowth ? AppColors.growthCardBackground : AppColors.healingCardBackground;
    final textPrimary = isGrowth ? AppColors.growthTextPrimary : AppColors.healingTextPrimary;
    final textSecondary = isGrowth ? AppColors.growthTextSecondary : AppColors.healingTextSecondary;

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final userName = 'Alex';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeController,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. HEADER SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isGrowth ? '🌅' : '🌙'} $greeting, $userName!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    isGrowth ? '🔥' : '💚',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isGrowth
                                        ? '${appProvider.streakData.currentStreak}-Day Streak'
                                        : '${appProvider.streakData.currentStreak}-Day Healing Streak',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '⏱️ 12 min today',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.notifications_outlined, color: textPrimary, size: 24),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.settings_outlined, color: textPrimary, size: 24),
                              onPressed: () => appProvider.setNavIndex(4), // Go to Profile
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Mode Switcher Banner ---
                    _buildModeToggleBar(appProvider, primaryColor, textPrimary, textSecondary),
                    const SizedBox(height: 24),

                    // --- 2. MOOD CHECK-IN ---
                    Text(
                      'HOW ARE YOU FEELING TODAY?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMoodCheckinRow(appProvider, primaryColor, cardBgColor, textSecondary),
                    const SizedBox(height: 28),

                    // --- 3. YOUR PERSONALIZED PLAYLIST ---
                    Text(
                      'YOUR PERSONALIZED PLAYLIST',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPersonalizedPlaylistCard(
                      context,
                      isGrowth,
                      primaryColor,
                      secondaryColor,
                      cardBgColor,
                      textPrimary,
                      textSecondary,
                      audioProvider,
                    ),
                    const SizedBox(height: 28),

                    // --- 4. SEARCH / SITUATION DISCOVERY ---
                    Text(
                      '🔍 WHAT\'S YOUR SITUATION?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSituationSearchSection(context, isGrowth, cardBgColor, textPrimary, textSecondary, audioProvider),
                    const SizedBox(height: 28),

                    // --- 6. RECOMMENDED FOR YOU ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECOMMENDED FOR YOU',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRecommendedList(context, isGrowth, cardBgColor, textPrimary, textSecondary, audioProvider, appProvider),
                    const SizedBox(height: 28),

                    // --- 7. TODAY'S AFFIRMATION ---
                    Text(
                      'TODAY\'S AFFIRMATION',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTodaysAffirmationCard(
                      context,
                      isGrowth,
                      primaryColor,
                      secondaryColor,
                      cardBgColor,
                      textPrimary,
                      textSecondary,
                      appProvider,
                      audioProvider,
                    ),
                    const SizedBox(height: 100), // Spacing for player bar & bottom nav
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widget 1: Mode Switcher Bar ---
  Widget _buildModeToggleBar(AppProvider appProvider, Color primaryColor, Color textPrimary, Color textSecondary) {
    final mode = appProvider.appModeSetting;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.borderSoft.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              label: '🚀 Growth',
              isSelected: mode == AppMode.growth,
              onTap: () {
                appProvider.setAppMode(AppMode.growth);
                _fadeController.forward(from: 0);
              },
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: '💔 Healing',
              isSelected: mode == AppMode.healing,
              onTap: () {
                appProvider.setAppMode(AppMode.healing);
                _fadeController.forward(from: 0);
              },
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: '🔄 Auto',
              isSelected: mode == AppMode.auto,
              onTap: () {
                appProvider.setAppMode(AppMode.auto);
                _fadeController.forward(from: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.buttonDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- Widget 2: Mood Check-in Row ---
  Widget _buildMoodCheckinRow(AppProvider appProvider, Color primaryColor, Color cardBgColor, Color textSecondary) {
    final selectedMood = appProvider.selectedMood;
    final moods = [
      {'emoji': '😊', 'label': 'Happy'},
      {'emoji': '😐', 'label': 'Neutral'},
      {'emoji': '😔', 'label': 'Sad'},
      {'emoji': '😨', 'label': 'Anxious'},
      {'emoji': '😌', 'label': 'Calm'},
      {'emoji': '🤔', 'label': 'Thoughtful'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        final emoji = mood['emoji']!;
        final label = mood['label']!;
        final isSelected = selectedMood == emoji;

        return GestureDetector(
          onTap: () => appProvider.setSelectedMood(emoji),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.18) : cardBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryColor : AppColors.borderSoft.withOpacity(0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: isSelected ? 26 : 22),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                  color: isSelected ? primaryColor : textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Widget 3: Personalized Playlist Card ---
  Widget _buildPersonalizedPlaylistCard(
    BuildContext context,
    bool isGrowth,
    Color primaryColor,
    Color secondaryColor,
    Color cardBgColor,
    Color textPrimary,
    Color textSecondary,
    AudioProvider audioProvider,
  ) {
    final playlistTitle = isGrowth ? 'Unshakeable Confidence' : 'Healing Your Heart';
    final playlistDesc = isGrowth
        ? 'Based on your goal: Build Confidence'
        : 'Based on your situation: Healing from breakup';
    final durationStr = isGrowth ? '7 min' : '10 min';
    final iconEmoji = isGrowth ? '🎯' : '💔';

    final targetPlaylist = freePlaylists.firstWhere(
      (p) => isGrowth ? p.id.contains('confidence') || p.id.contains('energy') : p.id.contains('sleep') || p.id.contains('calm'),
      orElse: () => freePlaylists.first,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlistTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  playlistDesc,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(durationStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.mic_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('12 affirmations', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => audioProvider.openPlaylist(targetPlaylist, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('▶ Play', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // --- Widget 4: Situation Search Section ---
  Widget _buildSituationSearchSection(
    BuildContext context,
    bool isGrowth,
    Color cardBgColor,
    Color textPrimary,
    Color textSecondary,
    AudioProvider audioProvider,
  ) {
    final growthSituations = [
      {'icon': '💼', 'text': 'I Have A Job Interview'},
      {'icon': '📚', 'text': 'I Have An Exam Tomorrow'},
      {'icon': '🚀', 'text': 'I Need To Build Confidence'},
    ];

    final healingSituations = [
      {'icon': '💔', 'text': 'I\'m Going Through A Breakup'},
      {'icon': '🕊️', 'text': 'I\'m Grieving A Loss'},
      {'icon': '😰', 'text': 'I Can\'t Fall Asleep'},
    ];

    final list = isGrowth ? growthSituations : healingSituations;

    return Column(
      children: [
        // Search Input Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search playlists by situation...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Popular List Items
        Column(
          children: list.map((sit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {
                  final target = freePlaylists.first;
                  audioProvider.openPlaylist(target, context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Text(sit['icon']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(
                        sit['text']!,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Widget 6: Recommended List ---
  Widget _buildRecommendedList(
    BuildContext context,
    bool isGrowth,
    Color cardBgColor,
    Color textPrimary,
    Color textSecondary,
    AudioProvider audioProvider,
    AppProvider appProvider,
  ) {
    final items = isGrowth ? freePlaylists : premiumPlaylists.take(4).toList();

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final playlist = items[index];
          final isLocked = playlist.isPremium && !appProvider.isPremium;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: CustomCard(
              padding: const EdgeInsets.all(12),
              onTap: () {
                if (isLocked) {
                  PaywallModal.show(context);
                } else {
                  audioProvider.openPlaylist(playlist, context);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          playlist.title,
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLocked)
                        const Icon(Icons.lock_rounded, size: 14, color: AppColors.tanAccent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.duration} • ${playlist.category}',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget 7: Today's Affirmation Card ---
  Widget _buildTodaysAffirmationCard(
    BuildContext context,
    bool isGrowth,
    Color primaryColor,
    Color secondaryColor,
    Color cardBgColor,
    Color textPrimary,
    Color textSecondary,
    AppProvider appProvider,
    AudioProvider audioProvider,
  ) {
    final quoteText = isGrowth
        ? 'I am capable of handling whatever comes my way today.'
        : 'This pain is real, and I honor it. I am worthy of healing.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.08),
            secondaryColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"$quoteText"',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    fontStyle: isGrowth ? FontStyle.normal : FontStyle.italic,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Favorites! ❤️')),
                  );
                },
                icon: const Icon(Icons.favorite_outline_rounded, size: 16),
                label: const Text('Save', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: textSecondary),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Affirmation shared! 📤')),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Share', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: textSecondary),
              ),
              TextButton.icon(
                onPressed: () {
                  if (freePlaylists.isNotEmpty) {
                    audioProvider.openPlaylist(freePlaylists.first, context);
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Listen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
