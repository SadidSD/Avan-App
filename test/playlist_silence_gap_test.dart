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

    test('Re-opening the exact same playlist enforces 2s default gap', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.first;

      audioProvider.openPlaylist(testPlaylist);
      expect(audioProvider.gapBetweenAffirmations, 2);

      // User changes pacing in player screen
      audioProvider.setIntervalPerAffirmation(6);
      expect(audioProvider.gapBetweenAffirmations, 6);

      // Reopening the same playlist must reset back to 2s
      audioProvider.openPlaylist(testPlaylist);
      expect(audioProvider.gapBetweenAffirmations, 2);
    });

    test('All playlists in library strictly enforce 2s default pause when opened', () {
      final audioProvider = AudioProvider();
      expect(allPlaylists.isNotEmpty, isTrue);

      for (final pl in allPlaylists) {
        // Artificially change pacing
        audioProvider.setIntervalPerAffirmation(4);
        expect(audioProvider.gapBetweenAffirmations, 4);

        // Open playlist pl -> must strictly be 2s
        audioProvider.openPlaylist(pl);
        expect(audioProvider.gapBetweenAffirmations, 2,
            reason: 'Playlist ${pl.id} ("${pl.title}") must default to 2s gap');
      }
    });

    test('setGapBetweenAffirmations clamps to minimum 2 seconds', () {
      final audioProvider = AudioProvider();
      audioProvider.setGapBetweenAffirmations(0);
      expect(audioProvider.gapBetweenAffirmations, 2);

      audioProvider.setGapBetweenAffirmations(1);
      expect(audioProvider.gapBetweenAffirmations, 2);

      audioProvider.setGapBetweenAffirmations(4);
      expect(audioProvider.gapBetweenAffirmations, 4);
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
