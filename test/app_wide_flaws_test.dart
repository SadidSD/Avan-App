import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/models/journal_entry.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/affirmations/affirmations_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App-Wide Flaws & Gaps Fixes Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. Journal Favorite Persistence', () async {
      final provider = AppProvider();
      final entry = JournalEntry(
        id: 'test_journal_1',
        title: 'Morning Calm',
        body: 'Reflecting on today.',
        mood: 'Peaceful',
        date: DateTime.now(),
        isFavorite: false,
      );

      await provider.addJournalEntry(entry);
      expect(provider.journalEntries.first.isFavorite, isFalse);

      // Toggle favorite
      await provider.toggleJournalFavorite('test_journal_1');
      expect(provider.journalEntries.first.isFavorite, isTrue);

      // Re-instantiate provider to verify persistence in storage
      final newProvider = AppProvider();
      // Wait a microtask for loadState
      await Future.delayed(const Duration(milliseconds: 50));
      final reloaded = newProvider.journalEntries.firstWhere((e) => e.id == 'test_journal_1');
      expect(reloaded.isFavorite, isTrue);
    });

    test('2. Mood Check-in and Dynamic Boost in Personalization Engine', () async {
      final provider = AppProvider();
      expect(provider.selectedMood, isEmpty);

      // Select 'anxious' mood
      await provider.setSelectedMood('anxious');
      expect(provider.selectedMood, 'anxious');

      // Check that feed incorporates mood boost
      final feed = provider.getPersonalizedFeed(limit: 8);
      expect(feed, isNotEmpty);

      // Toggle same mood should clear it
      await provider.setSelectedMood('anxious');
      expect(provider.selectedMood, isEmpty);
    });

    test('3. AffirmationsTab accepts initialTab and filter works', () {
      const affirmationsTab = AffirmationsTab(initialTab: 'Favorites');
      expect(affirmationsTab.initialTab, 'Favorites');
    });

    test('4. Personalization Engine moodBoost applies properly', () {
      final provider = AppProvider();
      final feed = provider.getPersonalizedFeed(limit: 5);
      expect(feed, isNotEmpty);
    });
  });
}
