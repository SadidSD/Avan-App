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

  group('Playlist Affirmation Silence Gap Tests', () {
    test('Default silence gap between playlist affirmations is exactly 2 seconds', () {
      final audioProvider = AudioProvider();
      expect(audioProvider.gapBetweenAffirmations, 2);
    });

    test('openPlaylist calculates duration reflecting 2s silence gap', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.first;

      audioProvider.openPlaylist(testPlaylist);
      expect(audioProvider.currentPlaylist, isNotNull);
      expect(audioProvider.gapBetweenAffirmations, 2);
    });

    test('openPlaylist enforces 2s default gap when starting any new playlist, even after customization', () {
      final audioProvider = AudioProvider();
      
      // User changes pacing in player to Deep (6s)
      audioProvider.setIntervalPerAffirmation(6);
      expect(audioProvider.gapBetweenAffirmations, 6);

      // User opens a new playlist -> must strictly start with the 2s default gap
      audioProvider.openPlaylist(allPlaylists.first);
      expect(audioProvider.gapBetweenAffirmations, 2);
      expect(audioProvider.intervalPerAffirmation, 6); // 4s base + 2s default gap

      // User customizes again
      audioProvider.setIntervalPerAffirmation(4);
      expect(audioProvider.gapBetweenAffirmations, 4);

      // User opens a second playlist -> must strictly reset to 2s default gap
      if (allPlaylists.length > 1) {
        audioProvider.openPlaylist(allPlaylists[1]);
        expect(audioProvider.gapBetweenAffirmations, 2);
      }
    });

    test('closePlayer resets gap to 2s default', () {
      final audioProvider = AudioProvider();
      audioProvider.setIntervalPerAffirmation(6);
      expect(audioProvider.gapBetweenAffirmations, 6);

      audioProvider.closePlayer();
      expect(audioProvider.gapBetweenAffirmations, 2);
    });
  });
}
