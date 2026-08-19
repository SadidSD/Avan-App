import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

enum AmbientSound {
  none,
  rain,
  ocean,
  forest,
  whiteNoise,
  solfeggio528,
}

class AudioEngineService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isPlaying = false;
  double _voiceVolume = 1.0;
  double _voiceSpeed = 1.0;

  double _ambientVolume = 0.3;
  AmbientSound _currentSound = AmbientSound.none;

  int _positionSeconds = 0;
  int _durationSeconds = 8;

  bool _isLoopEnabled = false;

  Timer? _progressTimer;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0; // seconds

  void Function()? onComplete;
  void Function(int position)? onProgress;
  void Function(int remainingSeconds)? onSleepTimerTick;
  void Function()? onSleepTimerComplete;

  // Seamless looping ambient soundscapes
  final Map<AmbientSound, String> _soundUrls = {
    AmbientSound.rain: 'https://cdn.freesound.org/previews/362/362428_6542721-lq.mp3',
    AmbientSound.ocean: 'https://cdn.freesound.org/previews/400/400632_5121236-lq.mp3',
    AmbientSound.forest: 'https://cdn.freesound.org/previews/524/524312_11564757-lq.mp3',
    AmbientSound.whiteNoise: 'https://cdn.freesound.org/previews/274/274438_4006883-lq.mp3',
    AmbientSound.solfeggio528: 'https://cdn.freesound.org/previews/587/587251_11861866-lq.mp3',
  };

  AudioEngineService() {
    _initTts();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.42); // Calm, meditative speaking pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint("TTS Init Warning: $e");
    }

    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS finished speaking affirmation.");
      // Allow a 2-3 second reflection pause before completing
      _positionSeconds = _durationSeconds;
      if (onProgress != null) onProgress!(_positionSeconds);
      _stopProgressTimer();
      _isPlaying = false;
      if (onComplete != null) onComplete!();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      _stopProgressTimer();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      _isPlaying = false;
      _stopProgressTimer();
    });

    _flutterTts.setPauseHandler(() {
      _isPlaying = false;
      _stopProgressTimer();
    });

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      _startProgressTimer();
    });
  }

  Future<void> _ensureTtsVoice() async {
    try {
      await _flutterTts.setLanguage('en-US');
      final dynamic voices = await _flutterTts.getVoices;
      if (voices != null && voices is List && voices.isNotEmpty) {
        for (var voice in voices) {
          if (voice is Map) {
            final String locale = voice['locale']?.toString() ?? '';
            final String name = voice['name']?.toString() ?? '';
            if (locale.contains('en') || name.toLowerCase().contains('english') || name.toLowerCase().contains('google') || name.toLowerCase().contains('samantha')) {
              await _flutterTts.setVoice({"name": name, "locale": locale});
              debugPrint("Selected Voice: $name ($locale)");
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Voice resolution note: $e");
    }
  }

  bool get isPlaying => _isPlaying;
  double get voiceVolume => _voiceVolume;
  double get voiceSpeed => _voiceSpeed;
  double get ambientVolume => _ambientVolume;
  AmbientSound get currentSound => _currentSound;
  int get positionSeconds => _positionSeconds;
  int get durationSeconds => _durationSeconds;
  bool get isLoopEnabled => _isLoopEnabled;
  int get sleepTimerRemaining => _sleepTimerRemaining;

  Future<void> play(String text) async {
    try {
      await stop();
    } catch (_) {}

    // Pacing calculation: Average reading speed is ~3.5 words/sec at 1.0x, plus 3s meditative reflection pause
    final wordCount = text.split(RegExp(r'\s+')).length;
    final speechDuration = (wordCount / (2.6 * _voiceSpeed)).ceil();
    _durationSeconds = max(7, speechDuration + 3); // minimum 7s for full statement & absorption
    _positionSeconds = 0;
    _isPlaying = true;
    _startProgressTimer();

    // 1. Play Ambient Soundscape if enabled (and not none)
    if (_currentSound != AmbientSound.none && _soundUrls.containsKey(_currentSound)) {
      final ambientUrl = _soundUrls[_currentSound]!;
      try {
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.play(UrlSource(ambientUrl));
      } catch (e) {
        debugPrint("Ambient Player error: $e");
      }
    }

    // 2. Natural TTS Speech Synthesis of the Affirmation Text
    try {
      await _ensureTtsVoice();
      await _flutterTts.setVolume(_voiceVolume);
      double targetRate = (_voiceSpeed * 0.42).clamp(0.15, 0.9);
      await _flutterTts.setSpeechRate(targetRate);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak note: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      await _ambientPlayer.pause();
    } catch (_) {}
    _isPlaying = false;
    _stopProgressTimer();
  }

  Future<void> resume() async {
    _isPlaying = true;
    _startProgressTimer();
    try {
      if (_currentSound != AmbientSound.none) {
        await _ambientPlayer.resume();
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      await _ambientPlayer.stop();
    } catch (_) {}
    _isPlaying = false;
    _stopProgressTimer();
    _positionSeconds = 0;
  }

  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_positionSeconds < _durationSeconds) {
        _positionSeconds++;
        if (onProgress != null) onProgress!(_positionSeconds);
      } else {
        _isPlaying = false;
        _stopProgressTimer();
        if (onComplete != null) {
          onComplete!();
        }
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void setVoiceVolume(double vol) {
    _voiceVolume = vol.clamp(0.0, 1.0);
    _flutterTts.setVolume(_voiceVolume);
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed.clamp(0.75, 1.5);
    _flutterTts.setSpeechRate((_voiceSpeed * 0.42).clamp(0.15, 0.9));
  }

  void setAmbientSound(AmbientSound sound) async {
    _currentSound = sound;
    if (_currentSound == AmbientSound.none) {
      await _ambientPlayer.stop();
    } else if (_isPlaying && _soundUrls.containsKey(sound)) {
      try {
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.play(UrlSource(_soundUrls[sound]!));
      } catch (e) {
        debugPrint("Ambient switch error: $e");
      }
    }
  }

  void setAmbientVolume(double vol) {
    _ambientVolume = vol.clamp(0.0, 1.0);
    _ambientPlayer.setVolume(_ambientVolume);
  }

  void toggleLoopMode() {
    _isLoopEnabled = !_isLoopEnabled;
  }

  void toggleLoop() {
    toggleLoopMode();
  }

  void startSleepTimer(int minutes) {
    setSleepTimer(minutes);
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = minutes * 60;

    if (minutes > 0) {
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_sleepTimerRemaining > 0) {
          _sleepTimerRemaining--;
          if (onSleepTimerTick != null) onSleepTimerTick!(_sleepTimerRemaining);
        } else {
          _sleepTimer?.cancel();
          _sleepTimer = null;
          stop();
          if (onSleepTimerComplete != null) onSleepTimerComplete!();
        }
      });
    }
  }

  void dispose() {
    stop();
    _ambientPlayer.dispose();
    _sleepTimer?.cancel();
  }
}
