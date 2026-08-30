import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/audio_engine_service.dart';
import '../../theme/app_colors.dart';
import '../../models/user_archetype.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final playlist = audioProvider.currentPlaylist;
    final currentAffirmation = audioProvider.currentAffirmation;
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);
    final glow = AppColors.glowForMode(isGrowth);

    final isFavorite = currentAffirmation != null &&
        appProvider.favoriteAffirmations.contains(currentAffirmation.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientForMode(isGrowth),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 32, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          playlist?.title.toUpperCase() ?? 'AVAN AFFIRMATIONS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (playlist?.category != null)
                          Text(
                            playlist!.category,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: accent,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? Colors.redAccent : AppColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: () {
                            if (currentAffirmation != null) {
                              appProvider.toggleFavorite(currentAffirmation.id);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded,
                              color: AppColors.textPrimary, size: 22),
                          onPressed: () =>
                              _showMixerSheet(context, audioProvider, appProvider),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Animated Breathing Artwork Visualizer
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          final scale = audioProvider.isPlaying
                              ? _breathingAnimation.value
                              : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: glow.withOpacity(audioProvider.isPlaying ? 0.35 : 0.1),
                                    blurRadius: audioProvider.isPlaying ? 36 : 20,
                                    spreadRadius: audioProvider.isPlaying ? 6 : 0,
                                  ),
                                  const BoxShadow(
                                    color: Color(0x1A3D2C1E),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Ring
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accent.withOpacity(0.3),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  // Artwork
                                  ClipOval(
                                    child: SizedBox(
                                      width: 190,
                                      height: 190,
                                      child: Image.asset(
                                        playlist?.imagePath ?? 'assets/images/featured_meditation.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.surfaceSolid,
                                          child: Center(
                                            child: Icon(Icons.spa_rounded, size: 64, color: accent),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const Spacer(flex: 1),

                      // Progress / Archetype Pill
                      if (playlist != null && playlist.affirmations.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x083D2C1E),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Affirmation ${audioProvider.currentAffirmationIndex + 1} of ${playlist.affirmations.length}${currentAffirmation?.modality != null ? " • ${_modalityName(currentAffirmation!.modality)}" : ""}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Live Quote Typography Card
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 110),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            currentAffirmation?.quote ?? 'I am present, grounded, and aligned.',
                            key: ValueKey<String>(currentAffirmation?.quote ?? ''),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 23,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Seek Bar
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: accent,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: accent,
                        ),
                        child: Slider(
                          value: audioProvider.positionSeconds.toDouble().clamp(
                              0.0,
                              (audioProvider.durationSeconds > 0
                                      ? audioProvider.durationSeconds
                                      : 1)
                                  .toDouble()),
                          min: 0,
                          max: (audioProvider.durationSeconds > 0
                                  ? audioProvider.durationSeconds
                                  : 1)
                              .toDouble(),
                          onChanged: (val) {
                            audioProvider.seekTo(val.toInt());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(audioProvider.positionSeconds),
                              style: GoogleFonts.inter(
                                  fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            if (audioProvider.sleepTimerRemaining > 0)
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 12, color: accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(audioProvider.sleepTimerRemaining),
                                    style: GoogleFonts.inter(
                                        fontSize: 11.5, color: accent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            Text(
                              _formatDuration(audioProvider.durationSeconds),
                              style: GoogleFonts.inter(
                                  fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Controls Row (Speed, Previous, Play/Pause, Next, Loop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Speed Quick Switcher
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final speeds = [0.85, 1.0, 1.2];
                              int idx = speeds.indexOf(audioProvider.voiceSpeed);
                              int nextIdx = (idx + 1) % speeds.length;
                              audioProvider.setVoiceSpeed(speeds[nextIdx]);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${audioProvider.voiceSpeed.toStringAsFixed(1)}x',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          // Previous Button
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: AppColors.textPrimary, size: 34),
                            onPressed: () => audioProvider.previousAffirmation(),
                          ),

                          // Main Play / Pause Button
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.buttonDark,
                                  const Color(0xFF261910),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x353D2C1E),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                audioProvider.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              onPressed: () => audioProvider.togglePlayPause(),
                            ),
                          ),

                          // Next Button
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: AppColors.textPrimary, size: 34),
                            onPressed: () => audioProvider.nextAffirmation(),
                          ),

                          // Loop Toggle Button
                          IconButton(
                            icon: Icon(
                              Icons.repeat_rounded,
                              color: audioProvider.isLoopEnabled ? accent : AppColors.textSecondary,
                              size: 24,
                            ),
                            onPressed: () => audioProvider.toggleLoop(),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _modalityName(TherapeuticModality modality) {
    switch (modality) {
      case TherapeuticModality.cbtReframe:
        return 'CBT Reframe';
      case TherapeuticModality.actValues:
        return 'ACT Values';
      case TherapeuticModality.selfCompassion:
        return 'Self-Compassion';
      case TherapeuticModality.growthMindset:
        return 'Growth Mindset';
      case TherapeuticModality.traumaInformed:
        return 'Trauma-Informed';
      case TherapeuticModality.sportsPsychology:
        return 'Peak State';
      case TherapeuticModality.spiritualAlignment:
        return 'Alignment';
      case TherapeuticModality.accessibleDirect:
        return 'Accessible';
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showMixerSheet(
      BuildContext context, AudioProvider audioProvider, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isGrowth = appProvider.isGrowthMode;
            final accent = AppColors.accentForMode(isGrowth);

            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x203D2C1E),
                    blurRadius: 28,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Audio & Ambient Mixer',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Voice Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Voice Volume',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('${(audioProvider.voiceVolume * 100).toInt()}%',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  Slider(
                    value: audioProvider.voiceVolume,
                    onChanged: (val) {
                      setSheetState(() => audioProvider.setVoiceVolume(val));
                    },
                    activeColor: accent,
                    inactiveColor: AppColors.border,
                  ),

                  // Ambient Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ambient Soundscape Volume',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('${(audioProvider.ambientVolume * 100).toInt()}%',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  Slider(
                    value: audioProvider.ambientVolume,
                    onChanged: (val) {
                      setSheetState(() => audioProvider.setAmbientVolume(val));
                    },
                    activeColor: accent,
                    inactiveColor: AppColors.border,
                  ),

                  const SizedBox(height: 14),
                  Text('Ambient Soundscape Stream',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _soundChip('✨ 528Hz Miracle', AmbientSound.solfeggio528, audioProvider, accent, setSheetState),
                        _soundChip('🔮 432Hz Calm', AmbientSound.solfeggio432, audioProvider, accent, setSheetState),
                        _soundChip('💚 639Hz Heart', AmbientSound.solfeggio639, audioProvider, accent, setSheetState),
                        _soundChip('🌌 852Hz Intuition', AmbientSound.solfeggio852, audioProvider, accent, setSheetState),
                        _soundChip('🧠 Theta Focus', AmbientSound.binauralTheta, audioProvider, accent, setSheetState),
                        _soundChip('🌧️ Rain', AmbientSound.rain, audioProvider, accent, setSheetState),
                        _soundChip('🌊 Ocean Waves', AmbientSound.ocean, audioProvider, accent, setSheetState),
                        _soundChip('🌲 Forest Breeze', AmbientSound.forest, audioProvider, accent, setSheetState),
                        _soundChip('🔥 Cozy Hearth', AmbientSound.fireplace, audioProvider, accent, setSheetState),
                        _soundChip('🎐 Wind Chimes', AmbientSound.windChimes, audioProvider, accent, setSheetState),
                        _soundChip('🦗 Night Crickets', AmbientSound.nightCrickets, audioProvider, accent, setSheetState),
                        _soundChip('⚪ Gentle Air', AmbientSound.whiteNoise, audioProvider, accent, setSheetState),
                        _soundChip('🔇 Off', AmbientSound.none, audioProvider, accent, setSheetState),
                      ],
                    ),

                  const SizedBox(height: 18),
                  Text('Affirmation Gap Pacing',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _pacingChip('Quick (2s Gap)', 2, audioProvider, accent, setSheetState),
                      _pacingChip('Natural (3.5s Gap)', 3, audioProvider, accent, setSheetState),
                      _pacingChip('Deep (6s Gap)', 6, audioProvider, accent, setSheetState),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text('Sleep Timer',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _timerChip('Off', 0, audioProvider, accent, setSheetState),
                      _timerChip('15 min', 15, audioProvider, accent, setSheetState),
                      _timerChip('30 min', 30, audioProvider, accent, setSheetState),
                      _timerChip('45 min', 45, audioProvider, accent, setSheetState),
                      _timerChip('60 min', 60, audioProvider, accent, setSheetState),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pacingChip(
      String label,
      int seconds,
      AudioProvider audioProvider,
      Color accent,
      StateSetter setSheetState) {
    final isSelected = audioProvider.gapBetweenAffirmations == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.buttonDark,
      backgroundColor: AppColors.surfaceSolid,
      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() => audioProvider.setIntervalPerAffirmation(seconds));
        }
      },
    );
  }

  Widget _soundChip(
      String label,
      AmbientSound sound,
      AudioProvider audioProvider,
      Color accent,
      StateSetter setSheetState) {
    final isSelected = audioProvider.currentSound == sound;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.buttonDark,
      backgroundColor: AppColors.surfaceSolid,
      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() => audioProvider.setAmbientSound(sound));
        }
      },
    );
  }

  Widget _timerChip(
      String label,
      int minutes,
      AudioProvider audioProvider,
      Color accent,
      StateSetter setSheetState) {
    final isSelected = (minutes == 0 && audioProvider.sleepTimerRemaining == 0) ||
        (minutes > 0 &&
            audioProvider.sleepTimerRemaining > (minutes - 1) * 60 &&
            audioProvider.sleepTimerRemaining <= minutes * 60);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.buttonDark,
      backgroundColor: AppColors.surfaceSolid,
      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() => audioProvider.setSleepTimer(minutes));
        }
      },
    );
  }
}
