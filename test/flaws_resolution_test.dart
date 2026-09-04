import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/models/playlist.dart';
import 'package:avan_app/models/journal_entry.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:intl/intl.dart';

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

  group('Flaw Resolutions & Edge Cases Test Suite', () {
    test('AudioProvider.openCustomAudio with speakTts: false sets up custom playlist without speech', () {
      final audioProvider = AudioProvider();

      audioProvider.openCustomAudio(
        title: 'My Custom Voice',
        quote: 'Personal Voice Studio Recording • 15s',
        duration: '15s',
        speakTts: false,
      );

      expect(audioProvider.currentPlaylist, isNotNull);
      expect(audioProvider.currentPlaylist!.title, 'My Custom Voice');
      expect(audioProvider.isPlayerOpen, isTrue);
      // Because speakTts: false, TTS is not triggered and isPlaying remains false
      expect(audioProvider.isPlaying, isFalse);
    });

    test('AudioProvider pause() and stop() function cleanly', () {
      final audioProvider = AudioProvider();
      expect(() => audioProvider.pause(), returnsNormally);
      expect(() => audioProvider.stop(), returnsNormally);
    });

    test('Playlist.resolveValidAssetPath maps non-existent playlist paths to valid assets', () {
      const validAssets = {
        'assets/images/featured_meditation.jpg',
        'assets/images/onboarding_archway_sun.jpg',
        'assets/images/onboarding_girl_profile.jpg',
        'assets/images/onboarding_moon_clouds.jpg',
        'assets/images/sleep_story_night.jpg',
      };

      // 1. Sleep category
      final sleepPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/midnight_awakening.jpg',
        category: 'Sleep & Rest',
        tags: ['sleep', 'rest'],
        title: 'Midnight Awakening',
      );
      expect(sleepPath, 'assets/images/sleep_story_night.jpg');
      expect(validAssets.contains(sleepPath), isTrue);

      // 2. Anxiety / Panic category
      final panicPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/panic_release.jpg',
        category: 'Anxiety & Panic',
        tags: ['panic', 'somatic'],
        title: 'Panic & Physical Tension Release',
      );
      expect(panicPath, 'assets/images/onboarding_moon_clouds.jpg');
      expect(validAssets.contains(panicPath), isTrue);

      // 3. Career / High Agency category
      final careerPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/founder.jpg',
        category: 'Career & Wealth',
        tags: ['founder', 'career'],
        title: 'Founder Resilience',
      );
      expect(careerPath, 'assets/images/onboarding_archway_sun.jpg');
      expect(validAssets.contains(careerPath), isTrue);

      // 4. Identity / Self-Compassion category
      final identityPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/imposter.jpg',
        category: 'Identity & Self-Compassion',
        tags: ['identity', 'compassion'],
        title: 'Imposter Syndrome',
      );
      expect(identityPath, 'assets/images/onboarding_girl_profile.jpg');
      expect(validAssets.contains(identityPath), isTrue);
    });

    test('EVERY single playlist in allPlaylists now resolves to a verified asset on disk', () {
      const validAssets = {
        'assets/images/featured_meditation.jpg',
        'assets/images/onboarding_archway_sun.jpg',
        'assets/images/onboarding_girl_profile.jpg',
        'assets/images/onboarding_moon_clouds.jpg',
        'assets/images/sleep_story_night.jpg',
      };

      expect(allPlaylists.length, greaterThan(60));

      for (final pl in allPlaylists) {
        expect(
          validAssets.contains(pl.imagePath),
          isTrue,
          reason: 'Playlist "${pl.title}" (id: ${pl.id}) has unmapped imagePath: "${pl.imagePath}"',
        );
      }
    });

    test('JournalEntry date formatting produces user-friendly string', () {
      final entry = JournalEntry(
        id: 'test_1',
        title: 'Morning Reflections',
        body: 'Feeling grounded and ready for deep focus.',
        mood: 'Peaceful',
        date: DateTime(2026, 9, 5, 8, 30),
      );

      final formatted = DateFormat('MMM d, yyyy • h:mm a').format(entry.date);
      expect(formatted, 'Sep 5, 2026 • 8:30 AM');
    });
  });
}
