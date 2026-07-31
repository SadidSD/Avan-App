import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/audio_engine_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final playlist = audioProvider.currentPlaylist;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : AppColors.textPrimary,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary),
            onPressed: () => _showMixerSheet(context, audioProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              // Large Circular Artwork Container
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softBeige,
                  border: Border.all(color: AppColors.borderSoft, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x125A4B44),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    playlist?.imagePath ?? 'assets/images/featured_meditation.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.eco_outlined, size: 80, color: AppColors.tanAccent),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Title & Subtitle
              Text(
                playlist?.title ?? 'AVAN Affirmations',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                playlist?.duration ?? '10 min',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Seek Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.buttonDark,
                  inactiveTrackColor: AppColors.nudeAccent,
                  thumbColor: AppColors.buttonDark,
                ),
                child: Slider(
                  value: audioProvider.positionSeconds.toDouble(),
                  min: 0,
                  max: audioProvider.durationSeconds.toDouble(),
                  onChanged: (val) {
                    // TTS does not support seeking
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(audioProvider.positionSeconds),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      _formatDuration(audioProvider.durationSeconds),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Controls Row (Loop, Previous, Play/Pause, Next, Timer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded, color: AppColors.tanAccent, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 32),
                    onPressed: () => audioProvider.previousAffirmation(),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.buttonDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A5A4B44),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () => audioProvider.togglePlayPause(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 32),
                    onPressed: () => audioProvider.nextAffirmation(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.timer_outlined, color: AppColors.tanAccent, size: 22),
                    onPressed: () => _showMixerSheet(context, audioProvider),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showMixerSheet(BuildContext context, AudioProvider audioProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audio & Ambient Mixer',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Voice Volume', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Slider(
                    value: audioProvider.voiceVolume,
                    onChanged: (val) {
                      setSheetState(() => audioProvider.setVoiceVolume(val));
                    },
                    activeColor: AppColors.buttonDark,
                    inactiveColor: AppColors.nudeAccent,
                  ),
                  const Text('Ambient Sound Volume', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Slider(
                    value: audioProvider.ambientVolume,
                    onChanged: (val) {
                      setSheetState(() => audioProvider.setAmbientVolume(val));
                    },
                    activeColor: AppColors.buttonDark,
                    inactiveColor: AppColors.nudeAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text('Ambient Soundscape', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _soundChip('Rain', AmbientSound.rain, audioProvider, setSheetState),
                      _soundChip('Ocean', AmbientSound.ocean, audioProvider, setSheetState),
                      _soundChip('White Noise', AmbientSound.whiteNoise, audioProvider, setSheetState),
                      _soundChip('528Hz Binaural', AmbientSound.solfeggio528, audioProvider, setSheetState),
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

  Widget _soundChip(String label, AmbientSound sound, AudioProvider audioProvider, StateSetter setSheetState) {
    final isSelected = audioProvider.currentSound == sound;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.buttonDark,
      backgroundColor: AppColors.softBeige,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() => audioProvider.setAmbientSound(sound));
        }
      },
    );
  }
}
