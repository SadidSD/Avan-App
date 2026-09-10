import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ambient_audio_synthesizer.dart';
import 'tts_service.dart';

enum AmbientSound {
  none,
  solfeggio528,
  solfeggio432,
  solfeggio639,
  solfeggio852,
  binauralTheta,
  rain,
  ocean,
  forest,
  fireplace,
  windChimes,
  nightCrickets,
  whiteNoise,
}

class AudioEngineService {
  final TtsService _ttsService = TtsService();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isPlaying = false;
  double _voiceVolume = 1.0;
  double _voiceSpeed = 1.0;

  double _ambientVolume = 0.25;
  AmbientSound _currentSound = AmbientSound.none; // Default to pure crystal-clear voice

  AudioEngineService() {
    _initEngine();
  }

  void _initEngine() async {
    await _ttsService.init();
    try {
      _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint("Ambient player setup warning: $e");
    }
  }

  bool _isDucked = false;
  Timer? _duckingTimer;

  bool get isPlaying => _isPlaying;
  double get voiceVolume => _voiceVolume;
  double get voiceSpeed => _voiceSpeed;
  double get ambientVolume => _ambientVolume;
  AmbientSound get currentSound => _currentSound;

  void _duckAmbient(bool duck) {
    if (_currentSound == AmbientSound.none) return;
    _duckingTimer?.cancel();
    _isDucked = duck;
    final double targetVol = duck ? (_ambientVolume * 0.3) : _ambientVolume;

    // Smooth fade over 200ms
    const steps = 5;
    final double startVol = duck ? _ambientVolume : (_ambientVolume * 0.3);
    final double delta = (targetVol - startVol) / steps;
    int currentStep = 0;

    _duckingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      currentStep++;
      final v = (startVol + delta * currentStep).clamp(0.0, 1.0);
      try {
        _ambientPlayer.setVolume(v);
      } catch (_) {}
      if (currentStep >= steps) {
        timer.cancel();
        try {
          _ambientPlayer.setVolume(targetVol);
        } catch (_) {}
      }
    });
  }

  /// Speaks the affirmation quote aloud and manages ambient soundscape with ducking
  Future<void> speakAffirmation(String text) async {
    _isPlaying = true;

    // 1. Play background ambient if active and duck volume so speech is clear
    if (_currentSound != AmbientSound.none) {
      _playAmbientInternal();
      _duckAmbient(true);
    }

    // 2. Synthesize speech
    try {
      await _ttsService.speak(text, volume: _voiceVolume, speed: _voiceSpeed);
    } catch (e) {
      debugPrint("AudioEngine speak error: $e");
    }
  }

  void _playAmbientInternal() async {
    if (_currentSound != AmbientSound.none) {
      try {
        final wavBytes = AmbientAudioSynthesizer.getWavBytesForSound(_currentSound);
        final effectiveVol = _isDucked ? (_ambientVolume * 0.3) : _ambientVolume;
        await _ambientPlayer.setVolume(effectiveVol);
        await _ambientPlayer.play(BytesSource(wavBytes));
      } catch (e) {
        debugPrint("Ambient playback error: $e");
      }
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    _duckingTimer?.cancel();
    try {
      await _ttsService.pause();
      await _ambientPlayer.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    _isPlaying = true;
    try {
      await _ttsService.resume();
      if (_currentSound != AmbientSound.none) {
        await _ambientPlayer.resume();
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _isPlaying = false;
    _duckingTimer?.cancel();
    _isDucked = false;
    try {
      await _ttsService.stop();
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  void setVoiceVolume(double vol) {
    _voiceVolume = vol.clamp(0.0, 1.0);
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed.clamp(0.75, 1.5);
  }

  void setAmbientSound(AmbientSound sound) async {
    _currentSound = sound;
    if (_currentSound == AmbientSound.none) {
      await _ambientPlayer.stop();
    } else {
      try {
        final wavBytes = AmbientAudioSynthesizer.getWavBytesForSound(sound);
        final effectiveVol = _isDucked ? (_ambientVolume * 0.3) : _ambientVolume;
        await _ambientPlayer.setVolume(effectiveVol);
        await _ambientPlayer.play(BytesSource(wavBytes));
      } catch (e) {
        debugPrint("Ambient switch error: $e");
      }
    }
  }

  void setAmbientVolume(double vol) {
    _ambientVolume = vol.clamp(0.0, 1.0);
    final effectiveVol = _isDucked ? (_ambientVolume * 0.3) : _ambientVolume;
    _ambientPlayer.setVolume(effectiveVol);
  }

  void setAffirmationCompletionHandler(VoidCallback callback) {
    _ttsService.setCompletionHandler(() {
      _duckAmbient(false); // Restore background music during the reflection gap!
      callback();
    });
  }

  void dispose() {
    stop();
    _ttsService.dispose();
    _ambientPlayer.dispose();
  }
}
