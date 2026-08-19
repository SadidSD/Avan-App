import 'tts_service_stub.dart'
    if (dart.library.html) 'tts_service_web.dart';

class TtsService {
  final PlatformTts _platformTts = PlatformTts();

  Future<void> init() => _platformTts.init();

  Future<void> speak(String text, {double volume = 1.0, double speed = 1.0}) =>
      _platformTts.speak(text, volume: volume, speed: speed);

  Future<void> pause() => _platformTts.pause();

  Future<void> resume() => _platformTts.resume();

  Future<void> stop() => _platformTts.stop();

  void dispose() => _platformTts.dispose();
}
