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

  double _ambientVolume = 0.35;
  AmbientSound _currentSound = AmbientSound.solfeggio528; // Default active ambient background

  AudioEngineService() {
    _initTts();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.42); // Calm, soothing meditative cadence
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint("TTS Init Warning: $e");
    }

    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS completed speaking active quote.");
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
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

  /// Speaks the given affirmation quote and starts background ambient if not already running
  Future<void> speakAffirmation(String text) async {
    _isPlaying = true;

    // 1. Ensure ambient sound is playing
    _playAmbientInternal();

    // 2. TTS Speech synthesis
    try {
      await _flutterTts.stop();
      await _ensureTtsVoice();
      await _flutterTts.setVolume(_voiceVolume);
      double targetRate = (_voiceSpeed * 0.42).clamp(0.15, 0.9);
      await _flutterTts.setSpeechRate(targetRate);
      await _flutterTts.speak(text);
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
      await _flutterTts.pause();
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
    _flutterTts.setSpeechRate((_voiceSpeed * 0.42).clamp(0.15, 0.9));
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
