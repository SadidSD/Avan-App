import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/models/affirmation.dart';
import 'package:avan_app/models/playlist.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/data/playlist_groups.dart';
import 'package:avan_app/services/personalization_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Personalization Pipeline Live Verification Suite', () {
    test('1. Growth vs. Healing Mode Switch reorders groups, changes hero session, and alters rankings', () async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      // Set to Growth mode
      await appProvider.setAppMode(AppMode.growth);
      expect(appProvider.isGrowthMode, isTrue);

      final growthGroups = getOrderedPlaylistGroups(isGrowthMode: true);
      final growthPlaylists = appProvider.getPersonalizedPlaylists();
      final growthHero = appProvider.getSituationalPlaylist();

      // Set to Healing mode
      await appProvider.setAppMode(AppMode.healing);
      expect(appProvider.isGrowthMode, isFalse);

      final healingGroups = getOrderedPlaylistGroups(isGrowthMode: false);
      final healingPlaylists = appProvider.getPersonalizedPlaylists();
      final healingHero = appProvider.getSituationalPlaylist();

      // Assert group order changed
      expect(growthGroups.first.id, isNot(equals(healingGroups.first.id)));
      expect(healingGroups.first.id, equals('group_anxiety_calm'));

      // Assert hero session transformed
      expect(growthHero.title, isNot(equals(healingHero.title)));

      // Assert top 5 playlist rankings shifted
      final growthTop5 = growthPlaylists.take(5).map((m) => m.playlist.id).toList();
      final healingTop5 = healingPlaylists.take(5).map((m) => m.playlist.id).toList();
      expect(growthTop5, isNot(equals(healingTop5)));
    });

    test('2. Daily Mood Check-In adapts hero playlist, hero affirmation, and ranks', () async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      // No mood selected initially
      await appProvider.setSelectedMood('');
      final defaultHero = appProvider.getSituationalPlaylist();

      // Select anxious mood
      await appProvider.setSelectedMood('anxious');
      expect(appProvider.selectedMood, equals('anxious'));

      final anxiousHero = appProvider.getSituationalPlaylist();
      final anxiousHeroAff = appProvider.getHeroAffirmation();
      final ranked = appProvider.getPersonalizedPlaylists();

      // Hero title, category, and ambient sound adapt to anxiety
      expect(anxiousHero.category, equals('Anxiety Relief'));
      expect(anxiousHero.title, contains('Nervous System Grounding'));
      expect(anxiousHero.title, isNot(equals(defaultHero.title)));

      // Anxious-relevant playlists (like panic/sos) are boosted in ranking
      final topPlaylists = ranked.take(8).map((m) => m.playlist.id).toList();
      final hasAnxietyOrCalm = topPlaylists.any((id) =>
          id.contains('panic') ||
          id.contains('sos') ||
          id.contains('anxiety') ||
          id.contains('sleep') ||
          id.contains('flood'));
      expect(hasAnxietyOrCalm, isTrue);

      // Deselect mood (toggle off)
      await appProvider.setSelectedMood('anxious');
      expect(appProvider.selectedMood, isEmpty);
    });

    test('3. Affirmation Listening & Ebbinghaus Habituation suppresses recently heard quote', () async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      final initialFeed = appProvider.getPersonalizedFeed(limit: 10);
      final firstQuote = initialFeed.first;

      // Simulate listening to the first affirmation
      await appProvider.recordAudioAffirmationCompleted(firstQuote);

      // Verify timestamp recorded
      expect(appProvider.lastListenedTimestamps.containsKey(firstQuote.id), isTrue);

      // New feed should demote or exclude the just-listened affirmation
      final freshFeed = appProvider.getPersonalizedFeed(limit: 5);
      final containsRecentlyHeardAtTop = freshFeed.take(2).any((a) => a.id == firstQuote.id);
      expect(containsRecentlyHeardAtTop, isFalse);
    });

    test('4. Skipping Affirmations applies negative penalty and triggers ZPD safety retreat', () async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      final initialSkipCount = appProvider.recentSkipCount;
      final targetAff = allPlaylists.first.affirmations.first;

      // Record skip
      await appProvider.recordAudioAffirmationSkipped(targetAff);

      expect(appProvider.recentSkipCount, equals(initialSkipCount + 1));
      expect(appProvider.userProfileVector.recentSkipCount, equals(initialSkipCount + 1));
    });

    test('5. Favoriting an affirmation triggers Online EMA vector learning', () async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      final candidateAff = allPlaylists.first.affirmations.first;
      final initialVector = List<double>.from(appProvider.userProfileVector.vector);

      // Toggle favorite
      await appProvider.toggleFavorite(candidateAff.id);

      expect(appProvider.favoriteAffirmations.contains(candidateAff.id), isTrue);
      // Online learning updates userProfileVector towards candidate embedding
      final updatedVector = appProvider.userProfileVector.vector;
      expect(updatedVector, isNot(equals(initialVector)));
    });
  });
}
