import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Syncs all user profile data, streak stats, favorites, journals, and vision boards to Supabase (and Firestore).
  Future<bool> uploadLocalToCloud({
    required String userId,
    required AppProvider appProvider,
  }) async {
    bool syncedAny = false;
    final surveyAnswers = appProvider.storageService.getSurveyAnswers();
    final streak = appProvider.streakData;

    // 1. Primary: Sync to Supabase user_vaults table
    try {
      await Supabase.instance.client.from('user_vaults').upsert({
        'user_id': userId,
        'profile': {
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
        },
        'streak': streak.toJson(),
        'favorites': appProvider.favoriteAffirmations,
        'journals': appProvider.journalEntries.map((e) => e.toJson()).toList(),
        'vision_boards': {
          'boards': appProvider.savedVisionBoards.map((b) => b.toJson()).toList(),
          'activeBoard': appProvider.activeVisionBoard.toJson(),
        },
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('[CloudSyncService] Local data successfully synced to Supabase for user: $userId');
      syncedAny = true;
    } catch (se) {
      debugPrint('[CloudSyncService] Supabase sync note (handled): $se');
    }

    // 2. Secondary / Legacy: Sync to Firestore
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final batch = _firestore.batch();

      final profileRef = userDoc.collection('vault').doc('profile');
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

      final streakRef = userDoc.collection('vault').doc('streak');
      batch.set(streakRef, {
        ...streak.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final favoritesRef = userDoc.collection('vault').doc('favorites');
      batch.set(favoritesRef, {
        'affirmationIds': appProvider.favoriteAffirmations,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final journalRef = userDoc.collection('vault').doc('journals');
      batch.set(journalRef, {
        'entries': appProvider.journalEntries.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final visionRef = userDoc.collection('vault').doc('vision_boards');
      batch.set(visionRef, {
        'boards': appProvider.savedVisionBoards.map((b) => b.toJson()).toList(),
        'activeBoard': appProvider.activeVisionBoard.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      debugPrint('[CloudSyncService] Local data successfully synced to Cloud Firestore for user: $userId');
      syncedAny = true;
    } catch (fe) {
      debugPrint('[CloudSyncService] Firestore sync note (handled): $fe');
    }

    return syncedAny;
  }

  /// Restores user data from Supabase (or Cloud Firestore) onto the local device.
  Future<bool> restoreCloudToLocal({
    required String userId,
    required AppProvider appProvider,
  }) async {
    // 1. Primary: Try restoring from Supabase user_vaults
    try {
      final res = await Supabase.instance.client
          .from('user_vaults')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        // Profile
        if (res['profile'] != null) {
          final data = Map<String, dynamic>.from(res['profile'] as Map);
          if (data['userName'] != null && (data['userName'] as String).isNotEmpty) {
            await appProvider.updateProfile(
              name: data['userName'] as String,
              email: (data['userEmail'] as String?) ?? appProvider.userEmail,
            );
          }
          if (data['appMode'] != null) {
            await appProvider.storageService.setAppMode(data['appMode'] as String);
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

        // Streak
        if (res['streak'] != null) {
          final restoredStreak = StreakData.fromJson(Map<String, dynamic>.from(res['streak'] as Map));
          await appProvider.storageService.saveStreakData(restoredStreak);
        }

        // Favorites
        if (res['favorites'] != null) {
          final favs = (res['favorites'] as List<dynamic>)
              .map((id) => id.toString())
              .toList();
          await appProvider.storageService.setFavoriteAffirmations(favs);
        }

        // Journals
        if (res['journals'] != null) {
          final rawEntries = res['journals'] as List<dynamic>;
          final entries = rawEntries
              .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          await appProvider.storageService.saveJournalEntries(entries);
        }

        // Vision Boards
        if (res['vision_boards'] != null) {
          final vbData = Map<String, dynamic>.from(res['vision_boards'] as Map);
          final rawBoards = (vbData['boards'] as List<dynamic>?) ?? [];
          final boards = rawBoards
              .map((b) => VisionBoard.fromJson(Map<String, dynamic>.from(b as Map)))
              .toList();
          await appProvider.storageService.saveVisionBoards(boards);

          if (vbData['activeBoard'] != null) {
            final active = VisionBoard.fromJson(Map<String, dynamic>.from(vbData['activeBoard'] as Map));
            await appProvider.storageService.saveActiveVisionBoard(active);
          }
        }

        await appProvider.loadState(forceReload: true);
        debugPrint('[CloudSyncService] Supabase data successfully restored for user: $userId');
        return true;
      }
    } catch (se) {
      debugPrint('[CloudSyncService] Supabase restore note: $se');
    }

    // 2. Secondary / Fallback: Try restoring from Firestore
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
    bool anyDeleted = false;

    // 1. Delete from Supabase
    try {
      await Supabase.instance.client.from('user_vaults').delete().eq('user_id', userId);
      debugPrint('[CloudSyncService] Supabase vault wiped for user: $userId');
      anyDeleted = true;
    } catch (se) {
      debugPrint('[CloudSyncService] Supabase delete note: $se');
    }

    // 2. Delete from Firestore
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final vaultDocs = await userDoc.collection('vault').get();
      final batch = _firestore.batch();
      for (final doc in vaultDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('[CloudSyncService] Cloud firestore vault deleted for user: $userId');
      anyDeleted = true;
    } catch (fe) {
      debugPrint('[CloudSyncService] Firestore delete note: $fe');
    }

    return anyDeleted;
  }
}
