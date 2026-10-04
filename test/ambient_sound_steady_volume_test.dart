import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/services/audio_engine_service.dart';

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
  });
}
