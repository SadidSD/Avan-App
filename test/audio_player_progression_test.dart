import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/data/playlists_data.dart';

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

  group('Audio Player Progression & Monotonic Timeline Tests', () {
    test('openPlaylist calculates realistic timeline based on quote lengths', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_stress_sos');

      audioProvider.openPlaylist(testPlaylist);

      expect(audioProvider.currentPlaylist, isNotNull);
      expect(audioProvider.currentAffirmationIndex, 0);
      expect(audioProvider.positionSeconds, 0);
      // Ensure duration reflects actual speech + reflection gaps (~10s per affirmation)
      expect(audioProvider.durationSeconds, greaterThan(60));
    });

    test('Advancing affirmations never causes player position to jump backwards', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_stress_sos');

      audioProvider.openPlaylist(testPlaylist);

      int previousPosition = audioProvider.positionSeconds;

      // Simulate player advancing through affirmations
      for (int i = 0; i < testPlaylist.affirmations.length - 1; i++) {
        // Simulate speech and ticker having advanced 10 seconds into the track
        audioProvider.seekTo(previousPosition + 10);
        final positionBeforeAdvance = audioProvider.positionSeconds;

        audioProvider.nextAffirmation();

        final positionAfterAdvance = audioProvider.positionSeconds;

        expect(
          positionAfterAdvance,
          greaterThanOrEqualTo(positionBeforeAdvance),
          reason: 'Advancing from track $i to ${i + 1} must NEVER jump backward! '
              'Was $positionBeforeAdvance, became $positionAfterAdvance',
        );

        previousPosition = positionAfterAdvance;
      }
    });

    test('seekTo maps accurately to the corresponding affirmation index', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_stress_sos');

      audioProvider.openPlaylist(testPlaylist);

      // Seek to beginning
      audioProvider.seekTo(0);
      expect(audioProvider.currentAffirmationIndex, 0);

      // Seek to mid session
      audioProvider.seekTo(35);
      expect(audioProvider.currentAffirmationIndex, greaterThan(0));
      expect(audioProvider.positionSeconds, 35);
    });

    test('previousAffirmation correctly navigates backward cleanly', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_stress_sos');

      audioProvider.openPlaylist(testPlaylist);

      // Advance to track 2
      audioProvider.nextAffirmation();
      audioProvider.nextAffirmation();
      expect(audioProvider.currentAffirmationIndex, 2);

      // Go back to track 1
      audioProvider.previousAffirmation();
      expect(audioProvider.currentAffirmationIndex, 1);

      // Go back to track 0
      audioProvider.previousAffirmation();
      expect(audioProvider.currentAffirmationIndex, 0);
      expect(audioProvider.positionSeconds, 0);
    });
  });
}
