import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_provider.dart';
import '../models/journal_entry.dart';
import '../models/vision_board.dart';
import '../models/streak.dart';
import '../models/user_profile_vector.dart';

/// Production-ready Cloud Sync Service for AVAN.
/// Syncs local state to Firebase Cloud Firestore for multi-device backup.
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  @visibleForTesting
  static FirebaseFirestore? customFirestoreInstance;

  FirebaseFirestore get _firestore {
    if (customFirestoreInstance != null) return customFirestoreInstance!;
    return FirebaseFirestore.instance;
  }

  /// Syncs all user profile data, streak stats, favorites, journals, and vision boards to Firestore.
  Future<bool> uploadLocalToCloud({
    required String userId,
    required AppProvider appProvider,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final batch = _firestore.batch();

      // 1. Profile & Preferences
      final profileRef = userDoc.collection('vault').doc('profile');
      final surveyAnswers = appProvider.storageService.getSurveyAnswers();
      batch.set(profileRef, {
        'userName': appProvider.userName,
        'userEmail': appProvider.userEmail,
        'appMode': appProvider.appModeSetting.name,
        'selectedMood': appProvider.selectedMood,
        'survey_goal': surveyAnswers['goal'],
        'survey_challenge': surveyAnswers['challenge'],
        'survey_vision': surveyAnswers['vision'],
        'survey_commitment': surveyAnswers['commitment'],
        'userTypedChallenge': appProvider.userTypedChallenge,
        'userTypedAspiration': appProvider.userTypedAspiration,
        'profileVector': appProvider.userProfileVector.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Streaks & Progress
      final streakRef = userDoc.collection('vault').doc('streak');
      final streak = appProvider.streakData;
      batch.set(streakRef, {
        ...streak.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Favorites
      final favoritesRef = userDoc.collection('vault').doc('favorites');
      batch.set(favoritesRef, {
        'affirmationIds': appProvider.favoriteAffirmations,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Journal Entries
      final journalRef = userDoc.collection('vault').doc('journals');
      batch.set(journalRef, {
        'entries': appProvider.journalEntries.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. Vision Boards
      final visionRef = userDoc.collection('vault').doc('vision_boards');
      batch.set(visionRef, {
        'boards': appProvider.savedVisionBoards.map((b) => b.toJson()).toList(),
        'activeBoard': appProvider.activeVisionBoard.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      debugPrint('[CloudSyncService] Local data successfully synced to Cloud Firestore for user: $userId');
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] uploadLocalToCloud error: $e');
      return false;
    }
  }

  /// Restores user data from Cloud Firestore onto the local device.
  Future<bool> restoreCloudToLocal({
    required String userId,
    required AppProvider appProvider,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // 1. Fetch Profile
      final profileSnap = await userDoc.collection('vault').doc('profile').get();
      if (profileSnap.exists && profileSnap.data() != null) {
        final data = profileSnap.data()!;
        if (data['userName'] != null && (data['userName'] as String).isNotEmpty) {
          await appProvider.updateProfile(
            name: data['userName'] as String,
            email: (data['userEmail'] as String?) ?? appProvider.userEmail,
          );
        }
        if (data['appMode'] != null) {
          final modeStr = data['appMode'] as String;
          await appProvider.storageService.setAppMode(modeStr);
        }
        if (data['selectedMood'] != null) {
          await appProvider.storageService.setSelectedMood(data['selectedMood'] as String);
        }
        if (data['survey_goal'] != null) {
          await appProvider.storageService.setSurveyAnswers(
            data['survey_goal'] as String? ?? 'Boost Confidence',
            data['survey_challenge'] as String? ?? 'Overthinking & Self-Doubt',
            data['survey_vision'] as String? ?? 'Calm & Confident Mind',
            data['survey_commitment'] as String? ?? '10 Min/Day',
          );
        }
        if (data['userTypedChallenge'] != null) {
          await appProvider.storageService.setUserTypedChallenge(data['userTypedChallenge'] as String);
        }
        if (data['userTypedAspiration'] != null) {
          await appProvider.storageService.setUserTypedAspiration(data['userTypedAspiration'] as String);
        }
        if (data['profileVector'] != null) {
          final vec = UserProfileVector.fromJson(Map<String, dynamic>.from(data['profileVector'] as Map));
          await appProvider.storageService.saveUserProfileVector(vec);
        }
      }

      // 2. Fetch Streaks
      final streakSnap = await userDoc.collection('vault').doc('streak').get();
      if (streakSnap.exists && streakSnap.data() != null) {
        final data = streakSnap.data()!;
        final restoredStreak = StreakData.fromJson(Map<String, dynamic>.from(data));
        await appProvider.storageService.saveStreakData(restoredStreak);
      }

      // 3. Fetch Favorites
      final favSnap = await userDoc.collection('vault').doc('favorites').get();
      if (favSnap.exists && favSnap.data() != null) {
        final favs = (favSnap.data()!['affirmationIds'] as List<dynamic>?)
            ?.map((id) => id.toString())
            .toList() ?? [];
        await appProvider.storageService.setFavoriteAffirmations(favs);
      }

      // 4. Fetch Journals
      final journalSnap = await userDoc.collection('vault').doc('journals').get();
      if (journalSnap.exists && journalSnap.data() != null) {
        final rawEntries = (journalSnap.data()!['entries'] as List<dynamic>?) ?? [];
        final entries = rawEntries
            .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await appProvider.storageService.saveJournalEntries(entries);
      }

      // 5. Fetch Vision Boards
      final visionSnap = await userDoc.collection('vault').doc('vision_boards').get();
      if (visionSnap.exists && visionSnap.data() != null) {
        final data = visionSnap.data()!;
        final rawBoards = (data['boards'] as List<dynamic>?) ?? [];
        final boards = rawBoards
            .map((b) => VisionBoard.fromJson(Map<String, dynamic>.from(b as Map)))
            .toList();
        await appProvider.storageService.saveVisionBoards(boards);

        if (data['activeBoard'] != null) {
          final active = VisionBoard.fromJson(Map<String, dynamic>.from(data['activeBoard'] as Map));
          await appProvider.storageService.saveActiveVisionBoard(active);
        }
      }

      // Reload state in appProvider
      await appProvider.loadState(forceReload: true);
      debugPrint('[CloudSyncService] Cloud data successfully restored for user: $userId');
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] restoreCloudToLocal error: $e');
      return false;
    }
  }

  /// Purges all cloud records for user upon account deletion.
  Future<bool> deleteCloudVault(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final vaultDocs = await userDoc.collection('vault').get();
      final batch = _firestore.batch();
      for (final doc in vaultDocs.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(userDoc);
      await batch.commit();
      debugPrint('[CloudSyncService] Cloud vault deleted for user: $userId');
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] deleteCloudVault error: $e');
      return false;
    }
  }
}
