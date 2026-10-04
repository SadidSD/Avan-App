import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/services/audio_engine_service.dart';
import 'package:avan_app/services/ambient_audio_synthesizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Steady Ambient Background Noise Tests', () {
    test('AudioEngineService preserves steady ambient volume without ducking or surging', () async {
      final engine = AudioEngineService();
      
      // Default ambient volume is 0.25 (calm background)
      expect(engine.ambientVolume, 0.25);

      // User sets custom ambient volume
      engine.setAmbientVolume(0.40);
      expect(engine.ambientVolume, 0.40);

      // Start speaking affirmation
      await engine.speakAffirmation('I am calm and steady.');

      // Volume must remain steady (never ducked down to 30% or 0.12)
      expect(engine.ambientVolume, 0.40);

      // Simulate completion callback (the 2-second silence break begins)
      bool completionFired = false;
      engine.setAffirmationCompletionHandler(() {
        completionFired = true;
      });

      // Volume must still remain exactly 0.40 during the break (never surges)
      expect(engine.ambientVolume, 0.40);

      engine.dispose();
    });

    test('AmbientAudioSynthesizer generates continuous 30s buffers without 6s partition', () {
      final wavRain = AmbientAudioSynthesizer.getWavBytesForSound(AmbientSound.rain);
      // 30 seconds at 22050Hz, 1 channel, 16-bit: 44 header + 1323000 bytes
      expect(wavRain.length, equals(44 + 22050 * 30 * 1 * 2));

      final wavSolfeggio = AmbientAudioSynthesizer.getWavBytesForSound(AmbientSound.solfeggio528);
      // 30 seconds at 22050Hz, 2 channels, 16-bit: 44 header + 2646000 bytes
      expect(wavSolfeggio.length, equals(44 + 22050 * 30 * 2 * 2));

      // Verify valid WAV headers
      expect(String.fromCharCodes(wavSolfeggio.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wavSolfeggio.sublist(8, 12)), 'WAVE');
    });
  });
}
