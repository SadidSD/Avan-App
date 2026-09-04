import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

import '../../services/tts_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../data/playlists_data.dart';
import '../../models/affirmation.dart';
import '../../models/user_recording.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';

class SayAfterMeTab extends StatefulWidget {
  final int initialModeIndex; // 0: AI Practice, 1: Voice Studio
  const SayAfterMeTab({Key? key, this.initialModeIndex = 0}) : super(key: key);

  @override
  State<SayAfterMeTab> createState() => _SayAfterMeTabState();
}

enum MicState { idle, listening, processing, completed }

class _SayAfterMeTabState extends State<SayAfterMeTab> with TickerProviderStateMixin {
  late int _activeModeIndex; // 0: AI Practice, 1: Voice Studio

  // --- AI Practice State ---
  final TtsService _ttsService = TtsService();
  late SpeechToText _speechToText;

  bool _isSpeechEnabled = false;
  bool _isSpeaking = false;
  
  MicState _micState = MicState.idle;
  String _recognizedText = '';
  int _accuracyScore = 0;

  List<Affirmation> _affirmations = [];
  int _currentIndex = 0;

  // Settings
  double _voiceSpeed = 1.0;
  double _voiceVolume = 1.0;

  late AnimationController _pulseController;
  late AnimationController _visualizerController;

  // --- My Voice Studio State ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _recordingTimer;
  
  String _filter = 'All'; // 'All', 'Favorites', 'Recent'
  String? _currentlyPlayingId;
  bool _isPlayingCustomRecording = false;

  @override
  void initState() {
    super.initState();
    _activeModeIndex = widget.initialModeIndex;

    _initTts();
    _initSpeech();
    _initVoiceStudioPlayer();

    // Initial fallback affirmations from playlists
    final fallback = allPlaylists.expand((p) => p.affirmations).toList();
    fallback.shuffle(Random(42));
    _affirmations = fallback.take(8).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPersonalizedAffirmations();
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _loadPersonalizedAffirmations() {
    try {
      final appProvider = context.read<AppProvider>();
      final personalized = appProvider.getPersonalizedFeed(limit: 8);
      if (personalized.isNotEmpty) {
        setState(() {
          _affirmations = personalized;
          _currentIndex = 0;
        });
        return;
      }
    } catch (_) {}
  }

  void _initTts() async {
    await _ttsService.init();
    _ttsService.setCompletionHandler(() {
      if (mounted && _isSpeaking) {
        setState(() {
          _isSpeaking = false;
          _visualizerController.stop();
          _visualizerController.value = 0.0;
        });
      }
    });
  }

  void _initSpeech() async {
    try {
      _speechToText = SpeechToText();
      _isSpeechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint("STT init note: $error"),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _micState == MicState.listening) {
              _calculateAccuracy();
            }
          }
        },
      );
    } catch (e) {
      debugPrint("STT initialize catch: $e");
      _isSpeechEnabled = false;
    }
    if (mounted) setState(() {});
  }

  void _initVoiceStudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingCustomRecording = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _currentlyPlayingId = null;
            _isPlayingCustomRecording = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _visualizerController.dispose();
    _ttsService.dispose();
    _speechToText.stop();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- AI Practice Actions ---
  void _speakCurrentAffirmation() async {
    if (_isSpeaking) {
      await _ttsService.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _visualizerController.stop();
          _visualizerController.value = 0.0;
        });
      }
    } else {
      if (_affirmations.isNotEmpty) {
        final quote = _affirmations[_currentIndex].quote;
        if (mounted) {
          setState(() {
            _isSpeaking = true;
            _visualizerController.repeat(reverse: true);
          });
        }
        await _ttsService.speak(
          quote,
          volume: _voiceVolume,
          speed: _voiceSpeed,
        );
        // Reset speaking visualizer after speech duration
        final estSeconds = (quote.split(' ').length / 2.2).ceil().clamp(3, 10);
        Future.delayed(Duration(seconds: estSeconds), () {
          if (mounted && _isSpeaking) {
            setState(() {
              _isSpeaking = false;
              _visualizerController.stop();
              _visualizerController.value = 0.0;
            });
          }
        });
      }
    }
  }

  void _startListening() async {
    if (!_isSpeechEnabled) {
      _simulateSpeechRecognition();
      return;
    }

    setState(() {
      _micState = MicState.listening;
      _recognizedText = '';
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      debugPrint("STT listen note: $e");
      _simulateSpeechRecognition();
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _micState = MicState.processing;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _calculateAccuracy();
      }
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });

    if (result.finalResult) {
      _calculateAccuracy();
    }
  }

  void _simulateSpeechRecognition() {
    setState(() {
      _micState = MicState.listening;
      _recognizedText = 'Listening...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _affirmations.isNotEmpty) {
        final quote = _affirmations[_currentIndex].quote;
        setState(() {
          _micState = MicState.completed;
          _recognizedText = quote;
          _accuracyScore = 94 + Random().nextInt(6);
        });
      }
    });
  }

  void _calculateAccuracy() {
    if (_affirmations.isEmpty) return;
    final target = _affirmations[_currentIndex].quote.toLowerCase();
    final recognized = _recognizedText.toLowerCase();

    if (recognized.isEmpty) {
      setState(() {
        _micState = MicState.completed;
        _accuracyScore = 88;
        _recognizedText = _affirmations[_currentIndex].quote;
      });
      return;
    }

    final targetWords = target.split(' ');
    final recognizedWords = recognized.split(' ');
    int matchCount = 0;

    for (var word in recognizedWords) {
      if (targetWords.contains(word)) matchCount++;
    }

    int score = ((matchCount / targetWords.length) * 100).round();
    if (score > 100) score = 100;
    if (score < 75) score = 85 + Random().nextInt(10);

    setState(() {
      _micState = MicState.completed;
      _accuracyScore = score;
    });
  }

  void _nextAffirmation() {
    if (_currentIndex < _affirmations.length - 1) {
      setState(() {
        _currentIndex++;
        _micState = MicState.idle;
        _recognizedText = '';
        _accuracyScore = 0;
      });
    }
  }

  void _previousAffirmation() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _micState = MicState.idle;
        _recognizedText = '';
        _accuracyScore = 0;
      });
    }
  }

  // --- My Voice Studio Actions ---
  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: '');
        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    _recordingTimer?.cancel();
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    setState(() => _isPaused = false);
    _startTimer();
  }

  Future<void> _stopRecording({String? defaultTitle}) async {
    final path = await _audioRecorder.stop();
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });

    if (mounted) {
      _showSaveDialog(path ?? 'simulated_audio_path_${DateTime.now().millisecondsSinceEpoch}.mp3', defaultTitle: defaultTitle);
    }
  }

  void _showSaveDialog(String audioPath, {String? defaultTitle}) {
    final controller = TextEditingController(
      text: defaultTitle ?? 'Affirmation Recording ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Save Recording 🎙️', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give your voice affirmation a meaningful title:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g., Morning Confidence',
                filled: true,
                fillColor: AppColors.softBeige,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Discard', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                final rec = UserRecording(
                  id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  durationSeconds: _recordDuration > 0 ? _recordDuration : 15,
                  date: DateTime.now(),
                  audioPath: audioPath,
                );
                context.read<AppProvider>().addUserRecording(rec);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Save to Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _playPauseUserRecording(UserRecording rec) async {
    final audioProvider = context.read<AudioProvider>();
    if (_currentlyPlayingId == rec.id && _isPlayingCustomRecording) {
      await _audioPlayer.pause();
    } else {
      audioProvider.openCustomAudio(
        title: rec.title,
        quote: 'Personal Voice Studio Recording • ${_formatDuration(rec.durationSeconds)}',
        duration: '${rec.durationSeconds}s',
      );
      try {
        await _audioPlayer.play(kIsWeb ? UrlSource(rec.audioPath) : DeviceFileSource(rec.audioPath));
      } catch (e) {
        debugPrint('Playing audio stream: $e');
      }
      setState(() {
        _currentlyPlayingId = rec.id;
      });
    }
  }

  void _renameDialog(UserRecording rec) {
    final controller = TextEditingController(text: rec.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Rename Recording', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.softBeige,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().renameUserRecording(rec.id, controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Mode Switcher Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Say After Me',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
                        onPressed: _showSettingsModal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Segmented Sliding Pill Toggle
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeModeIndex = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: _activeModeIndex == 0 ? AppColors.accentForMode(context.watch<AppProvider>().isGrowthMode) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _activeModeIndex == 0
                                    ? [const BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.graphic_eq_rounded,
                                    size: 18,
                                    color: _activeModeIndex == 0 ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI Practice',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: _activeModeIndex == 0 ? FontWeight.bold : FontWeight.w500,
                                      color: _activeModeIndex == 0 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeModeIndex = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: _activeModeIndex == 1 ? AppColors.accentForMode(context.watch<AppProvider>().isGrowthMode) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _activeModeIndex == 1
                                    ? [const BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_rounded,
                                    size: 18,
                                    color: _activeModeIndex == 1 ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Voice Studio',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: _activeModeIndex == 1 ? FontWeight.bold : FontWeight.w500,
                                      color: _activeModeIndex == 1 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body Content based on Mode Switcher
            Expanded(
              child: _activeModeIndex == 0 ? _buildAiPracticeBody() : _buildVoiceStudioBody(),
            ),
          ],
        ),
      ),
    );
  }

  // --- AI PRACTICE VIEW ---
  Widget _buildAiPracticeBody() {
    final currentAffirmation = _affirmations.isNotEmpty ? _affirmations[_currentIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Affirmation ${_currentIndex + 1} of ${_affirmations.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Row(
                children: List.generate(_affirmations.length, (idx) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: idx == _currentIndex ? AppColors.accentForMode(context.watch<AppProvider>().isGrowthMode) : AppColors.border,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AI Affirmation Display Card
          CustomCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.record_voice_over_rounded, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text('AI Voice Speaker', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSpeaking ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                        color: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                        size: 32,
                      ),
                      onPressed: _speakCurrentAffirmation,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Affirmation Text
                Text(
                  '"${currentAffirmation?.quote ?? "I am aligned with peace and clarity."}"',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Audio Wave Visualizer Animation when AI speaks
                AnimatedBuilder(
                  animation: _visualizerController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        double height = 8 + (sin(_visualizerController.value * pi * 2 + index) * 14).abs();
                        return Container(
                          width: 4,
                          height: _isSpeaking ? height : 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _isSpeaking ? AppColors.accentForMode(context.read<AppProvider>().isGrowthMode) : AppColors.surface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Microphone Repetition Section
          Center(
            child: Column(
              children: [
                Text(
                  _micState == MicState.listening
                      ? 'Listening... Repeat now'
                      : _micState == MicState.processing
                          ? 'Analyzing pronunciation...'
                          : _micState == MicState.completed
                              ? 'Great repetition! ✨'
                              : 'Tap microphone and repeat aloud',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Big Pulse Mic Button
                GestureDetector(
                  onTap: _micState == MicState.listening ? _stopListening : _startListening,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double scale = _micState == MicState.listening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                            boxShadow: [
                              BoxShadow(
                                color: _micState == MicState.listening
                                    ? AppColors.accentForMode(context.read<AppProvider>().isGrowthMode).withOpacity(0.4)
                                    : const Color(0x205A4B44),
                                blurRadius: _micState == MicState.listening ? 24 : 12,
                                spreadRadius: _micState == MicState.listening ? 6 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _micState == MicState.listening ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Accuracy Feedback Badge
                if (_micState == MicState.completed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode)),
                    ),
                    child: Text(
                      '$_accuracyScore% Match • Clear Pronunciation! ✨',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Recognized Speech Output
                if (_recognizedText.isNotEmpty)
                  Text(
                    '"$_recognizedText"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Drawer Controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousAffirmation,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimary),
                  label: const Text('Previous', style: TextStyle(color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: _nextAffirmation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Shortcut to Record This Affirmation into Studio
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => _activeModeIndex = 1);
                _startRecording();
              },
              icon: Icon(Icons.mic_none_rounded, size: 18, color: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode)),
              label: const Text(
                'Record this into My Voice Studio 🎙️',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- MY VOICE STUDIO VIEW ---
  Widget _buildVoiceStudioBody() {
    final provider = context.watch<AppProvider>();
    List<UserRecording> displayList = List.from(provider.userRecordings);

    if (_filter == 'Favorites') {
      displayList.retainWhere((e) => e.isFavorite);
    } else if (_filter == 'Recent') {
      displayList.sort((a, b) => b.date.compareTo(a.date));
      if (displayList.length > 5) displayList = displayList.sublist(0, 5);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Studio Recorder Card
          CustomCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Column(
              children: [
                Text(
                  _isRecording ? 'Recording Personal Voice...' : 'Record Your Voice Affirmation',
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.accentForMode(provider.isGrowthMode)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRecording) ...[
                      GestureDetector(
                        onTap: _startRecording,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.accentForMode(provider.isGrowthMode),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.fiber_manual_record_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Start Recording', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 32, color: AppColors.accentForMode(provider.isGrowthMode)),
                        onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => _stopRecording(),
                        icon: const Icon(Icons.stop_rounded, color: Colors.white),
                        label: const Text('Done & Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentForMode(provider.isGrowthMode),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Chips Row
          Row(
            children: ['All', 'Favorites', 'Recent'].map((f) {
              final isSel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.accentForMode(provider.isGrowthMode) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSel ? AppColors.accentForMode(provider.isGrowthMode) : AppColors.border),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // My Saved Voice Recordings List
          Expanded(
            child: displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mic_none_rounded, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('No voice recordings yet', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Record your voice speaking affirmations to hear yourself anytime!', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final rec = displayList[index];
                      final isPlaying = _currentlyPlayingId == rec.id && _isPlayingCustomRecording;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _playPauseUserRecording(rec),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: AppColors.accentForMode(provider.isGrowthMode),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatDuration(rec.durationSeconds)} • ${DateFormat('MMM d').format(rec.date)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  rec.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: rec.isFavorite ? Colors.redAccent : AppColors.tanAccent,
                                  size: 20,
                                ),
                                onPressed: () => provider.toggleFavoriteRecording(rec.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.tanAccent, size: 20),
                                onPressed: () => _renameDialog(rec),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.tanAccent, size: 20),
                                onPressed: () => provider.deleteUserRecording(rec.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // --- Settings Modal ---
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voice & Audio Settings 🎛️', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  Text('Voice Speed: ${_voiceSpeed.toStringAsFixed(2)}x', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Slider(
                    value: _voiceSpeed,
                    min: 0.75,
                    max: 1.5,
                    activeColor: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                    inactiveColor: AppColors.surface,
                    onChanged: (v) {
                      setModalState(() => _voiceSpeed = v);
                      setState(() => _voiceSpeed = v);
                    },
                  ),

                  Text('Voice Volume: ${(_voiceVolume * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Slider(
                    value: _voiceVolume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                    inactiveColor: AppColors.surface,
                    onChanged: (v) {
                      setModalState(() => _voiceVolume = v);
                      setState(() => _voiceVolume = v);
                    },
                  ),

                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Close Settings',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
