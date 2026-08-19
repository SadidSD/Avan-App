// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class PlatformTts {
  html.SpeechSynthesisUtterance? _currentUtterance;
  Timer? _resumeKeepAliveTimer;
  List<html.SpeechSynthesisVoice>? _voices;

  Future<void> init() async {
    try {
      if (html.window.speechSynthesis != null) {
        _voices = html.window.speechSynthesis!.getVoices();
        html.window.speechSynthesis!.on['voiceschanged'].listen((_) {
          _voices = html.window.speechSynthesis!.getVoices();
          debugPrint("Web TTS voices loaded: ${_voices?.length ?? 0}");
        });
      }
    } catch (e) {
      debugPrint("Web TTS Init Note: $e");
    }
  }

  Future<void> speak(String text, {double volume = 1.0, double speed = 1.0}) async {
    try {
      final synth = html.window.speechSynthesis;
      if (synth == null) {
        debugPrint("Web SpeechSynthesis not supported in this browser environment.");
        return;
      }

      // 1. Chrome Unstick Fix: Always cancel any hung speech and force resume
      synth.cancel();
      synth.resume();

      // 2. Create SpeechSynthesisUtterance
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'en-US';
      utterance.volume = volume.clamp(0.0, 1.0);
      utterance.rate = (speed * 0.88).clamp(0.5, 1.5);
      utterance.pitch = 1.0;

      // 3. Find natural English voice if available
      final voices = _voices ?? synth.getVoices();
      if (voices.isNotEmpty) {
        html.SpeechSynthesisVoice? selectedVoice;
        for (var voice in voices) {
          final name = (voice.name ?? '').toLowerCase();
          final lang = (voice.lang ?? '').toLowerCase();
          if (lang.contains('en-us') || lang.contains('en_us') || lang.contains('en')) {
            if (name.contains('natural') || name.contains('google') || name.contains('samantha') || name.contains('jenny') || name.contains('zira') || name.contains('premium')) {
              selectedVoice = voice;
              break;
            }
            selectedVoice ??= voice;
          }
        }
        if (selectedVoice != null) {
          utterance.voice = selectedVoice;
        }
      }

      _currentUtterance = utterance;

      utterance.onStart.listen((_) {
        debugPrint("Web TTS started speaking: '$text'");
        _startKeepAlive();
      });

      utterance.onEnd.listen((_) {
        debugPrint("Web TTS finished speaking: '$text'");
        _stopKeepAlive();
      });

      utterance.onError.listen((e) {
        debugPrint("Web TTS Error event: $e");
        _stopKeepAlive();
      });

      synth.speak(utterance);
      synth.resume();
    } catch (e) {
      debugPrint("Web TTS Speak Exception: $e");
    }
  }

  void _startKeepAlive() {
    _resumeKeepAliveTimer?.cancel();
    // Chrome stops speaking after ~14 seconds unless resume() is called
    _resumeKeepAliveTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final synth = html.window.speechSynthesis;
      if (synth != null && (synth.speaking == true)) {
        synth.pause();
        synth.resume();
      } else {
        _stopKeepAlive();
      }
    });
  }

  void _stopKeepAlive() {
    _resumeKeepAliveTimer?.cancel();
    _resumeKeepAliveTimer = null;
  }

  Future<void> pause() async {
    try {
      html.window.speechSynthesis?.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      html.window.speechSynthesis?.resume();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      _stopKeepAlive();
      html.window.speechSynthesis?.cancel();
    } catch (_) {}
  }

  void dispose() {
    stop();
  }
}
