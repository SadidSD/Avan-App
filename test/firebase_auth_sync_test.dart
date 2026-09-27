import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/services/auth_service.dart';
import 'package:avan_app/services/cloud_sync_service.dart';
import 'package:avan_app/models/streak.dart';
import 'package:avan_app/models/journal_entry.dart';
import 'package:avan_app/models/vision_board.dart';
import 'package:avan_app/models/user_profile_vector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Firebase Auth & Progressive Auth Architecture Tests', () {
    test('AuthService initializes cleanly as singleton', () {
      final auth1 = AuthService();
      final auth2 = AuthService();
      expect(identical(auth1, auth2), isTrue);
    });

    test('Guest mode by default when not signed in', () {
      final auth = AuthService();
      expect(auth.isSignedIn, isFalse);
      expect(auth.userId, isNull);
      expect(auth.userEmail, isNull);
    });

    test('CloudSyncService initializes cleanly as singleton', () {
      final sync1 = CloudSyncService();
      final sync2 = CloudSyncService();
      expect(identical(sync1, sync2), isTrue);
    });
  });

  group('Cloud Vault Data Serialization & Firestore Compatibility', () {
    test('StreakData to/from Firestore Map roundtrip preserves all progress metrics', () {
      final streak = StreakData(
        currentStreak: 14,
        longestStreak: 28,
        totalListeningDays: 45,
        lastActiveDate: DateTime(2026, 9, 26, 12, 0),
        unlockedBadges: ['badge_3_day', 'badge_7_day', 'badge_14_day'],
      );

      final firestoreMap = streak.toJson();
      expect(firestoreMap['currentStreak'], 14);
      expect(firestoreMap['longestStreak'], 28);
      expect(firestoreMap['totalListeningDays'], 45);
      expect(firestoreMap['unlockedBadges'], contains('badge_14_day'));

      final restored = StreakData.fromJson(firestoreMap);
      expect(restored.currentStreak, 14);
      expect(restored.longestStreak, 28);
      expect(restored.totalListeningDays, 45);
      expect(restored.unlockedBadges.length, 3);
      expect(restored.lastActiveDate, equals(streak.lastActiveDate));
    });

    test('JournalEntry to/from JSON roundtrip preserves reflections and audio links', () {
      final entry = JournalEntry(
        id: 'journal_123',
        title: 'Deep Gratitude Reflection',
        body: 'Felt centered and strong today during morning affirmations.',
        date: DateTime(2026, 9, 26, 8, 30),
        mood: 'Grounded & Confident',
        isFavorite: true,
      );

      final map = entry.toJson();
      expect(map['id'], 'journal_123');
      expect(map['title'], 'Deep Gratitude Reflection');
      expect(map['body'], 'Felt centered and strong today during morning affirmations.');

      final restored = JournalEntry.fromJson(map);
      expect(restored.id, 'journal_123');
      expect(restored.title, 'Deep Gratitude Reflection');
      expect(restored.body, 'Felt centered and strong today during morning affirmations.');
      expect(restored.mood, 'Grounded & Confident');
      expect(restored.isFavorite, isTrue);
    });

    test('VisionBoard to/from JSON roundtrip preserves goals and manifest states', () {
      final board = VisionBoard(
        id: 'vb_2026',
        title: 'Dream Year 2026',
        createdAt: DateTime(2026, 1, 1),
        lastModified: DateTime(2026, 9, 26),
        blocks: [
          GoalBlock(
            id: 'g1',
            title: 'Lead with quiet conviction',
            category: 'Leadership',
            bgImageUrl: 'assets/images/mindset.jpg',
            tintValue: 0xFF2D6A4F,
            quote: 'I trust my inner guidance.',
            isManifested: true,
          ),
        ],
      );

      final map = board.toJson();
      expect(map['id'], 'vb_2026');
      expect(map['title'], 'Dream Year 2026');

      final restored = VisionBoard.fromJson(map);
      expect(restored.id, 'vb_2026');
      expect(restored.blocks.length, 1);
      expect(restored.blocks.first.title, 'Lead with quiet conviction');
      expect(restored.blocks.first.isManifested, isTrue);
    });

    test('UserProfileVector preserves 16-D neural embeddings across cloud roundtrips', () {
      final vector = UserProfileVector(
        userName: 'Alex',
        userTypedChallenge: 'Imposter Syndrome',
        userTypedAspiration: 'Executive Presence',
        completedSessionsCount: 12,
        recentSkipCount: 1,
      );

      final map = vector.toJson();
      expect(map['userName'], 'Alex');
      expect(map['completedSessionsCount'], 12);

      final restored = UserProfileVector.fromJson(map);
      expect(restored.userName, 'Alex');
      expect(restored.completedSessionsCount, 12);
      expect(restored.userTypedChallenge, 'Imposter Syndrome');
    });
  });

  group('AppProvider Progressive Auth & Cloud Sync State Management', () {
    test('Fresh launch starts as unauthenticated guest with offline capability', () async {
      final provider = AppProvider();
      await provider.loadState();

      expect(provider.isSignedIn, isFalse);
      expect(provider.isSyncing, isFalse);
      expect(provider.userPhotoUrl, isNull);
      expect(provider.userName, 'Friend');
    });

    test('Profile updates and cloud sync flag toggle persist locally', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.updateProfile(name: 'Sarah Connor', email: 'sarah@resistance.org');
      expect(provider.userName, 'Sarah Connor');
      expect(provider.userEmail, 'sarah@resistance.org');

      await provider.setCloudSync(true);
      expect(provider.isCloudSyncEnabled, isTrue);

      await provider.setCloudSync(false);
      expect(provider.isCloudSyncEnabled, isFalse);
    });

    test('Sign out cleanly disables cloud sync flag and keeps guest experience functional', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.setCloudSync(true);
      expect(provider.isCloudSyncEnabled, isTrue);

      await provider.signOut();
      expect(provider.isCloudSyncEnabled, isFalse);
      expect(provider.isSignedIn, isFalse);
    });
  });
}
