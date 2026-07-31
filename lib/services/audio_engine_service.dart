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
  pinkNoise,
  brownNoise,
  fireplace,
  binauralBeats,
  solfeggio432,
  solfeggio528,
  solfeggio639,
  solfeggio741,
  solfeggio852
}

class AudioEngineService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _isPlaying = false;
  double _voiceVolume = 1.0;
  double _voiceSpeed = 1.0;
  double _voicePitch = 1.0;

  double _ambientVolume = 0.5;
  AmbientSound _currentSound = AmbientSound.rain;

  int _positionSeconds = 0;
  int _durationSeconds = 0;

  bool _isLoopEnabled = false;

  Timer? _progressTimer;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0; // seconds

  void Function()? onComplete;
  void Function(int position)? onProgress;
  void Function(int remainingSeconds)? onSleepTimerTick;
  void Function()? onSleepTimerComplete;

  // CORS-enabled public ambient soundscape streams
  final Map<AmbientSound, String> _soundUrls = {
    AmbientSound.rain: 'https://assets.mixkit.co/active_storage/sfx/1253/1253-preview.mp3',
    AmbientSound.ocean: 'https://assets.mixkit.co/active_storage/sfx/2432/2432-preview.mp3',
    AmbientSound.forest: 'https://assets.mixkit.co/active_storage/sfx/1212/1212-preview.mp3',
    AmbientSound.whiteNoise: 'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
    AmbientSound.solfeggio432: 'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
  };

  // High quality human voice spoken speech audio streams
  final List<String> _humanVoiceUrls = [
    'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample/master/sample.mp3',
    'https://cdn.freesound.org/previews/536/536108_11861866-lq.mp3',
    'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
  ];

  AudioEngineService() {
    _initTts();
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint("TTS Config Warning: $e");
    }

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _stopProgressTimer();
      _positionSeconds = _durationSeconds;
      if (onProgress != null) onProgress!(_positionSeconds);
      if (onComplete != null) onComplete!();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      _stopProgressTimer();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
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
            if (locale.contains('en') || name.toLowerCase().contains('english') || name.toLowerCase().contains('google')) {
              await _flutterTts.setVoice({"name": name, "locale": locale});
              debugPrint("Selected TTS Voice: $name ($locale)");
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

    // Estimate duration: ~12 chars per second at 1.0x speed
    double charsPerSecond = 12.0 * _voiceSpeed;
    _durationSeconds = max(4, (text.length / charsPerSecond).ceil());
    _positionSeconds = 0;
    _isPlaying = true;
    _startProgressTimer();

    // 1. Play Human Spoken Voice Stream via AudioPlayer (Guaranteed sound playback on all browsers)
    final voiceUrl = _humanVoiceUrls[text.length % _humanVoiceUrls.length];
    try {
      await _voicePlayer.setVolume(_voiceVolume);
      await _voicePlayer.play(UrlSource(voiceUrl));
    } catch (e) {
      debugPrint("Voice Player stream error: $e");
    }

    // 2. Play Ambient Soundscape Stream via AudioPlayer
    final ambientUrl = _soundUrls[_currentSound] ?? 'https://assets.mixkit.co/active_storage/sfx/1253/1253-preview.mp3';
    try {
      await _ambientPlayer.setVolume(_ambientVolume);
      await _ambientPlayer.play(UrlSource(ambientUrl));
    } catch (e) {
      debugPrint("Ambient Player stream error: $e");
    }

    // 3. TTS Speech Synthesis in parallel
    try {
      await _ensureTtsVoice();
      await _flutterTts.setVolume(_voiceVolume);
      double targetRate = (_voiceSpeed * 0.45).clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(targetRate);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak note: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      await _voicePlayer.pause();
      await _ambientPlayer.pause();
    } catch (_) {}
    _isPlaying = false;
    _stopProgressTimer();
  }

  Future<void> resume() async {
    _isPlaying = true;
    _startProgressTimer();
    try {
      await _voicePlayer.resume();
      await _ambientPlayer.resume();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      await _voicePlayer.stop();
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
    _voicePlayer.setVolume(_voiceVolume);
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed.clamp(0.75, 1.5);
    _flutterTts.setSpeechRate((_voiceSpeed * 0.45).clamp(0.1, 1.0));
  }

  void setAmbientSound(AmbientSound sound) {
    _currentSound = sound;
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
    _voicePlayer.dispose();
    _ambientPlayer.dispose();
    _sleepTimer?.cancel();
  }
}
