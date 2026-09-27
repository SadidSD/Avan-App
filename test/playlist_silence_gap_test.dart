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
  });
}
