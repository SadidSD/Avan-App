import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlatformTts {
  final FlutterTts _flutterTts = FlutterTts();
  VoidCallback? onComplete;
  bool _isSpeaking = false;
  int _currentSpeechId = 0;
  bool _isCurrentSpeechCompleted = false;

  Future<void> init() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      _flutterTts.setStartHandler(() {
        debugPrint("Native TTS started speaking utterance #$_currentSpeechId");
      });
      _flutterTts.setCompletionHandler(() {
        _notifyCompletion(_currentSpeechId, source: "completionHandler");
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint("Native TTS Platform Error: $msg");
        _notifyCompletion(_currentSpeechId, source: "errorHandler");
      });
      _flutterTts.setCancelHandler(() {
        debugPrint("Native TTS Platform Cancelled");
      });
    } catch (e) {
      debugPrint("Native TTS Init Error: $e");
    }
  }

  void _notifyCompletion(int speechId, {required String source}) {
    if (speechId != 0 && speechId == _currentSpeechId && !_isCurrentSpeechCompleted) {
      _isCurrentSpeechCompleted = true;
      _isSpeaking = false;
      debugPrint("Native TTS: Completed utterance #$speechId via $source");
      onComplete?.call();
    }
  }

  Future<void> speak(String text, {double volume = 1.0, double speed = 1.0}) async {
    try {
      if (_isSpeaking) {
        _isSpeaking = false;
        try {
          await _flutterTts.stop();
        } catch (_) {}
      }

      final speechId = ++_currentSpeechId;
      _isCurrentSpeechCompleted = false;
      _isSpeaking = true;

      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      await _flutterTts.setSpeechRate((speed * 0.48).clamp(0.2, 0.9));

      // Dual completion safeguard:
      // awaitSpeakCompletion(true) ensures speak returns when speech finishes natively.
      // Whichever notifies first (setCompletionHandler or await speak()) triggers completion reliably.
      await _flutterTts.speak(text);
      _notifyCompletion(speechId, source: "awaitSpeakCompletion");
    } catch (e) {
      debugPrint("Native TTS Speak Error: $e");
      _notifyCompletion(_currentSpeechId, source: "speakException");
    }
  }

  Future<void> pause() async {
    _currentSpeechId = 0;
    _isSpeaking = false;
    _isCurrentSpeechCompleted = true;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  Future<void> resume() async {
    // Mobile FlutterTts does not support direct resume without speak on some OS
  }

  Future<void> stop() async {
    _currentSpeechId = 0;
    _isSpeaking = false;
    _isCurrentSpeechCompleted = true;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  void dispose() {
    stop();
  }
}
