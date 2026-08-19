import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ambient_audio_synthesizer.dart';

enum AmbientSound {
  none,
  rain,
  ocean,
  forest,
  whiteNoise,
  solfeggio528,
  solfeggio432,
}

class AudioEngineService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isPlaying = false;
  double _voiceVolume = 1.0;
  double _voiceSpeed = 1.0;

  double _ambientVolume = 0.25;
  AmbientSound _currentSound = AmbientSound.none; // Default to pure crystal-clear voice

  AudioEngineService() {
    _initTts();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      if (kIsWeb) {
        // In Web Speech API, 1.0 is standard speed; 0.88 is calm and meditative
        await _flutterTts.setSpeechRate(0.88);
      } else {
        await _flutterTts.setSpeechRate(0.48);
        await _flutterTts.awaitSpeakCompletion(false);
      }
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("TTS Init Warning: $e");
    }

    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS completed speaking affirmation.");
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });
  }

  bool get isPlaying => _isPlaying;
  double get voiceVolume => _voiceVolume;
  double get voiceSpeed => _voiceSpeed;
  double get ambientVolume => _ambientVolume;
  AmbientSound get currentSound => _currentSound;

  /// Speaks the given affirmation quote clearly and manages ambient sound
  Future<void> speakAffirmation(String text) async {
    _isPlaying = true;

    // 1. Start ambient sound if enabled
    if (_currentSound != AmbientSound.none) {
      _playAmbientInternal();
    }

    // 2. TTS Voice synthesis
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setVolume(_voiceVolume);

      final double rate = kIsWeb
          ? (_voiceSpeed * 0.88).clamp(0.5, 1.5)
          : (_voiceSpeed * 0.48).clamp(0.2, 0.9);
      await _flutterTts.setSpeechRate(rate);

      final result = await _flutterTts.speak(text);
      debugPrint("TTS speak called for '$text' -> result: $result");
    } catch (e) {
      debugPrint("TTS Speak error: $e");
    }
  }

  void _playAmbientInternal() async {
    if (_currentSound != AmbientSound.none) {
      try {
        final wavBytes = AmbientAudioSynthesizer.getWavBytesForSound(_currentSound);
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.play(BytesSource(wavBytes));
      } catch (e) {
        debugPrint("Ambient playback error: $e");
      }
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    try {
      await _flutterTts.stop();
      await _ambientPlayer.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    _isPlaying = true;
    try {
      if (_currentSound != AmbientSound.none) {
        await _ambientPlayer.resume();
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _isPlaying = false;
    try {
      await _flutterTts.stop();
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  void setVoiceVolume(double vol) {
    _voiceVolume = vol.clamp(0.0, 1.0);
    _flutterTts.setVolume(_voiceVolume);
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed.clamp(0.75, 1.5);
    final double rate = kIsWeb
        ? (_voiceSpeed * 0.88).clamp(0.5, 1.5)
        : (_voiceSpeed * 0.48).clamp(0.2, 0.9);
    _flutterTts.setSpeechRate(rate);
  }

  void setAmbientSound(AmbientSound sound) async {
    _currentSound = sound;
    if (_currentSound == AmbientSound.none) {
      await _ambientPlayer.stop();
    } else {
      try {
        final wavBytes = AmbientAudioSynthesizer.getWavBytesForSound(sound);
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.play(BytesSource(wavBytes));
      } catch (e) {
        debugPrint("Ambient switch error: $e");
      }
    }
  }

  void setAmbientVolume(double vol) {
    _ambientVolume = vol.clamp(0.0, 1.0);
    _ambientPlayer.setVolume(_ambientVolume);
  }

  void dispose() {
    stop();
    _ambientPlayer.dispose();
  }
}
