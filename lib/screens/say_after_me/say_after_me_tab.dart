import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../data/playlists_data.dart';
import '../../models/affirmation.dart';
import '../../providers/audio_provider.dart';

class SayAfterMeTab extends StatefulWidget {
  const SayAfterMeTab({Key? key}) : super(key: key);

  @override
  State<SayAfterMeTab> createState() => _SayAfterMeTabState();
}

enum MicState { idle, listening, processing, completed }

class _SayAfterMeTabState extends State<SayAfterMeTab> with TickerProviderStateMixin {
  late FlutterTts _flutterTts;
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
  String _bgm = 'None';
  double _micSensitivity = 0.5;

  late AnimationController _pulseController;
  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
    
    // Load some affirmations from playlists
    _affirmations = allPlaylists.expand((p) => p.affirmations).toList();
    _affirmations.shuffle(Random(42)); // pseudo-random for consistency
    _affirmations = _affirmations.take(8).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_voiceSpeed);
    await _flutterTts.setVolume(_voiceVolume);
    
    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
          _visualizerController.repeat(reverse: true);
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _visualizerController.stop();
          _visualizerController.value = 0.0;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _visualizerController.stop();
          _visualizerController.value = 0.0;
        });
      }
    });
  }

  void _initSpeech() async {
    _speechToText = SpeechToText();
    _isSpeechEnabled = await _speechToText.initialize(
      onError: (error) {
        if (mounted && _micState == MicState.listening) {
           _processSpeech();
        }
      },
      onStatus: (status) {
        if (status == 'done' && _micState == MicState.listening) {
          _processSpeech();
        }
      }
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    _pulseController.dispose();
    _visualizerController.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_affirmations.isEmpty) return;
    final currentQuote = _affirmations[_currentIndex].quote;
    final audioProvider = context.read<AudioProvider>();
    audioProvider.openCustomAudio(
      title: 'Say After Me • AI Trainer',
      quote: currentQuote,
    );
  }

  void _startListening() async {
    if (!_isSpeechEnabled) {
      // Simulate speech if denied or unsupported
      _simulateSpeech();
      return;
    }

    setState(() {
      _micState = MicState.listening;
      _recognizedText = '';
      _accuracyScore = 0;
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    _processSpeech();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _recognizedText = result.recognizedWords;
      });
    }
  }
  
  void _simulateSpeech() async {
    setState(() {
      _micState = MicState.listening;
      _recognizedText = '';
      _accuracyScore = 0;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    setState(() {
      _recognizedText = _affirmations[_currentIndex].quote.toLowerCase();
    });
    
    _processSpeech();
  }

  void _processSpeech() async {
    setState(() {
      _micState = MicState.processing;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate processing

    if (mounted) {
      setState(() {
        _micState = MicState.completed;
        _calculateAccuracy();
      });
    }
  }

  void _calculateAccuracy() {
    if (_recognizedText.isEmpty) {
      _accuracyScore = 0;
      return;
    }
    
    // Simple mock accuracy based on string similarity (length based for mock)
    String target = _affirmations[_currentIndex].quote.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String recognized = _recognizedText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    
    List<String> targetWords = target.split(' ');
    List<String> recognizedWords = recognized.split(' ');
    
    int matches = 0;
    for (String w in recognizedWords) {
      if (targetWords.contains(w)) matches++;
    }
    
    double score = (matches / targetWords.length) * 100;
    if (score > 100) score = 100;
    if (recognized.contains(target) || target.contains(recognized)) {
       score = max(score, 90.0 + Random().nextInt(10));
    }
    _accuracyScore = score.toInt();
  }

  void _nextAffirmation() {
    if (_currentIndex < _affirmations.length - 1) {
      setState(() {
        _currentIndex++;
        _resetState();
      });
      _speak();
    }
  }

  void _prevAffirmation() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetState();
      });
      _speak();
    }
  }

  void _resetState() {
    _flutterTts.stop();
    _speechToText.stop();
    _isSpeaking = false;
    _micState = MicState.idle;
    _recognizedText = '';
    _accuracyScore = 0;
    _visualizerController.stop();
    _visualizerController.value = 0.0;
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voice Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans', color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  _buildSlider('Voice Speed', _voiceSpeed, 0.75, 1.5, (val) {
                    setModalState(() => _voiceSpeed = val);
                    setState(() => _voiceSpeed = val);
                  }),
                  _buildSlider('Voice Volume', _voiceVolume, 0.0, 1.0, (val) {
                    setModalState(() => _voiceVolume = val);
                    setState(() => _voiceVolume = val);
                  }),
                  _buildSlider('Mic Sensitivity', _micSensitivity, 0.0, 1.0, (val) {
                    setModalState(() => _micSensitivity = val);
                    setState(() => _micSensitivity = val);
                  }),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Background Music', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      DropdownButton<String>(
                        value: _bgm,
                        dropdownColor: AppColors.cardSurface,
                        underline: const SizedBox(),
                        style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                        items: ['None', 'Rain', 'Forest', 'Ocean'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _bgm = val);
                            setState(() => _bgm = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.goldAccent,
          inactiveColor: AppColors.nudeAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAffirmation = _affirmations.isNotEmpty ? _affirmations[_currentIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Say After Me',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.iconColor),
            onPressed: _showSettings,
          )
        ],
      ),
      body: SafeArea(
        child: currentAffirmation == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Affirmation ${_currentIndex + 1} of ${_affirmations.length}',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 24),
                  
                  // AI Speaker Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: CustomCard(
                      backgroundColor: AppColors.softBeige,
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.graphic_eq_rounded, size: 24, color: AppColors.tanAccent),
                              const SizedBox(width: 8),
                              Text(
                                'AI Speaks',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.8), letterSpacing: 1.0, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '"${currentAffirmation.quote}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 24,
                              height: 1.3,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Visualizer
                          SizedBox(
                            height: 40,
                            child: AnimatedBuilder(
                              animation: _visualizerController,
                              builder: (context, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 4,
                                      height: _isSpeaking ? 10 + (30 * _visualizerController.value * (index % 2 == 0 ? 1 : 0.5)) : 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.goldAccent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // User Feedback Text
                  if (_micState == MicState.completed) ...[
                     Text(
                        '$_accuracyScore% Match • ${_accuracyScore > 80 ? 'Clear Pronunciation! ✨' : 'Keep practicing!'}',
                        style: TextStyle(
                          color: _accuracyScore > 80 ? AppColors.greenAccent : AppColors.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                     ),
                     const SizedBox(height: 8),
                  ],
                  if (_recognizedText.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        _recognizedText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Big Mic Button
                  GestureDetector(
                    onTap: () {
                      if (_micState == MicState.listening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _micState == MicState.listening ? Colors.redAccent.withOpacity(0.8) : AppColors.buttonDark,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_micState == MicState.listening)
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.4),
                                  blurRadius: 30 * _pulseController.value,
                                  spreadRadius: 10 * _pulseController.value,
                                ),
                              const BoxShadow(color: Color(0x1A5A4B44), blurRadius: 20, offset: Offset(0, 6)),
                            ],
                          ),
                          child: Icon(
                            _micState == MicState.listening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 48
                          ),
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMicStateText(),
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  
                  const Spacer(),

                  // Bottom Controls
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 32),
                          color: _currentIndex > 0 ? AppColors.iconColor : AppColors.borderSoft,
                          onPressed: _prevAffirmation,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.softBeige,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(_isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded, size: 32),
                            color: AppColors.iconColor,
                            onPressed: _speak,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 28),
                          color: AppColors.iconColor,
                          onPressed: _resetState,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 32),
                          color: _currentIndex < _affirmations.length - 1 ? AppColors.iconColor : AppColors.borderSoft,
                          onPressed: _nextAffirmation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getMicStateText() {
    switch (_micState) {
      case MicState.idle:
        return 'Tap Mic & Repeat Affirmation';
      case MicState.listening:
        return 'Listening to your voice...';
      case MicState.processing:
        return 'Analyzing pronunciation...';
      case MicState.completed:
        return 'Tap Mic to try again';
    }
  }
}
