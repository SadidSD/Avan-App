import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlatformTts {
  final FlutterTts _flutterTts = FlutterTts();
  VoidCallback? onComplete;
  bool _isSpeaking = false;

  Future<void> init() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      _flutterTts.setCompletionHandler(() {
        if (_isSpeaking) {
          _isSpeaking = false;
          onComplete?.call();
        }
      });
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
      });
      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });
    } catch (e) {
      debugPrint("Native TTS Init Error: $e");
    }
  }

  Future<void> speak(String text, {double volume = 1.0, double speed = 1.0}) async {
    try {
      _isSpeaking = false;
      await _flutterTts.stop();
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      await _flutterTts.setSpeechRate((speed * 0.48).clamp(0.2, 0.9));
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint("Native TTS Speak Error: $e");
    }
  }

  Future<void> pause() async {
    _isSpeaking = false;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  Future<void> resume() async {
    // Mobile FlutterTts does not support direct resume without speak on some OS
  }

  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  void dispose() {
    stop();
  }
}
