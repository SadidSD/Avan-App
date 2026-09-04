import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../data/playlists_data.dart';
import '../../models/affirmation.dart';

class AffirmationsTab extends StatefulWidget {
  final String initialTab;
  const AffirmationsTab({Key? key, this.initialTab = 'Today'}) : super(key: key);

  @override
  State<AffirmationsTab> createState() => _AffirmationsTabState();
}

class _AffirmationsTabState extends State<AffirmationsTab> {
  late String _selectedTab;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  List<Affirmation> _getFilteredAffirmations(AppProvider appProvider) {
    if (_selectedTab == 'Favorites') {
      final favIds = appProvider.favoriteAffirmations;
      final List<Affirmation> result = [];
      for (var pl in allPlaylists) {
        for (var aff in pl.affirmations) {
          if (favIds.contains(aff.id)) {
            result.add(aff);
          }
        }
      }
      return result;
    }

    if (_selectedTab == 'All') {
      final List<Affirmation> result = [];
      for (var pl in allPlaylists) {
        result.addAll(pl.affirmations);
      }
      return result;
    }

    // Default: Today's Playlist affirmations (Morning Energy + Calm Mind)
    final List<Affirmation> result = [];
    result.addAll(freePlaylists.first.affirmations);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final affirmations = _getFilteredAffirmations(appProvider);
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);
    final canPop = Navigator.canPop(context);

    if (_currentIndex >= affirmations.length && affirmations.isNotEmpty) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canPop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const Icon(Icons.notes_rounded, color: AppColors.textPrimary, size: 24),
                  Text(
                    _selectedTab == 'Favorites' ? 'Saved Favorites ❤️' : 'Daily Affirmations 🌿',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.goldAccent, size: 24),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Tabs: Today, Favorites, All
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Today', 'Favorites', 'All'].map((tab) {
                  final isSelected = tab == _selectedTab;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      selectedColor: accent,
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? accent : AppColors.border),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTab = tab;
                            _currentIndex = 0;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Main Canvas
              Expanded(
                child: affirmations.isEmpty
                    ? CustomCard(
                        backgroundColor: AppColors.surfaceElevated,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.tanAccent),
                              SizedBox(height: 12),
                              Text(
                                'No Favorites Saved Yet',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tap the heart icon on any affirmation to save it here.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final currentAff = affirmations[_currentIndex];
                          final isFav = appProvider.favoriteAffirmations.contains(currentAff.id);

                          return CustomCard(
                            backgroundColor: AppColors.surfaceElevated,
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: [
                                // Top Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceSolid,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        currentAff.category.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                          color: AppColors.tanAccent,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFav ? Colors.redAccent : AppColors.textPrimary,
                                          ),
                                          onPressed: () {
                                            appProvider.toggleFavorite(currentAff.id);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: currentAff.quote));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Affirmation copied to clipboard! ✨'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Quote Display
                                const Icon(Icons.format_quote_rounded, color: AppColors.tanAccent, size: 36),
                                const SizedBox(height: 12),
                                Text(
                                  '"${currentAff.quote}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),

                                // Dots Indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    affirmations.length > 8 ? 8 : affirmations.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                      width: _currentIndex % 8 == index ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentIndex % 8 == index ? AppColors.textPrimary : AppColors.tanAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Controls: Listen TTS, Refresh, Next
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Previous Affirmation
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                                        tooltip: 'Previous Affirmation',
                                        onPressed: () {
                                          setState(() {
                                            _currentIndex = (_currentIndex - 1 + affirmations.length) % affirmations.length;
                                          });
                                        },
                                      ),
                                    ),

                                    // Listen AI Voice Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.buttonDark,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      ),
                                      onPressed: () {
                                        audioProvider.playSingleQuote(currentAff.quote);
                                      },
                                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                                      label: const Text(
                                        'Listen',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),

                                    // Next Affirmation
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
                                        tooltip: 'Next Affirmation',
                                        onPressed: () {
                                          setState(() {
                                            _currentIndex = (_currentIndex + 1) % affirmations.length;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
