import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../models/streak.dart';
import '../models/user_recording.dart';
import '../models/user_profile_vector.dart';
import '../models/vision_board.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Onboarding
  bool getOnboardingStatus() => _prefs?.getBool('onboardingStatus') ?? false;
  Future<void> setOnboardingStatus(bool value) async {
    await init();
    await _prefs?.setBool('onboardingStatus', value);
  }

  // Survey
  Map<String, String> getSurveyAnswers() {
    return {
      'goal': _prefs?.getString('survey_goal') ?? 'Boost Confidence',
      'challenge': _prefs?.getString('survey_challenge') ?? 'Overthinking & Self-Doubt',
      'vision': _prefs?.getString('survey_vision') ?? 'Calm & Confident Mind',
      'commitment': _prefs?.getString('survey_commitment') ?? '10 Min/Day',
    };
  }
  Future<void> setSurveyAnswers(String goal, String challenge, String vision, String commitment) async {
    await init();
    await _prefs?.setString('survey_goal', goal);
    await _prefs?.setString('survey_challenge', challenge);
    await _prefs?.setString('survey_vision', vision);
    await _prefs?.setString('survey_commitment', commitment);
  }

  // Premium
  bool getPremiumStatus() => _prefs?.getBool('premiumStatus') ?? false;
  Future<void> setPremiumStatus(bool value) async {
    await init();
    await _prefs?.setBool('premiumStatus', value);
  }

  // Favorites
  List<String> getFavoriteAffirmations() => _prefs?.getStringList('favoriteAffirmations') ?? [];
  Future<void> setFavoriteAffirmations(List<String> ids) async {
    await init();
    await _prefs?.setStringList('favoriteAffirmations', ids);
  }

  // Journal Entries
  List<JournalEntry> getJournalEntries() {
    final List<String>? entriesStr = _prefs?.getStringList('journalEntries');
    if (entriesStr == null) return [];
    return entriesStr.map((e) => JournalEntry.fromJson(jsonDecode(e))).toList();
  }
  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    await init();
    final List<String> entriesStr = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList('journalEntries', entriesStr);
  }

  // Streak Data
  StreakData getStreakData() {
    final String? streakStr = _prefs?.getString('streakData');
    if (streakStr == null) return StreakData();
    return StreakData.fromJson(jsonDecode(streakStr));
  }
  Future<void> saveStreakData(StreakData data) async {
    await init();
    await _prefs?.setString('streakData', jsonEncode(data.toJson()));
  }

  // Playlists
  List<String> getRecentPlaylists() => _prefs?.getStringList('recentPlaylists') ?? [];
  Future<void> setRecentPlaylists(List<String> ids) async {
    await init();
    await _prefs?.setStringList('recentPlaylists', ids);
  }

  // User Recordings
  List<UserRecording> getUserRecordings() {
    final List<String>? recsStr = _prefs?.getStringList('userRecordings');
    if (recsStr == null) return [];
    return recsStr.map((e) => UserRecording.fromJson(jsonDecode(e))).toList();
  }
  Future<void> saveUserRecordings(List<UserRecording> recordings) async {
    await init();
    final List<String> recsStr = recordings.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList('userRecordings', recsStr);
  }

  // Vision Boards Persistence
  List<VisionBoard> getSavedVisionBoards() {
    final List<String>? boardsStr = _prefs?.getStringList('savedVisionBoards');
    if (boardsStr == null) return [];
    return boardsStr.map((e) => VisionBoard.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveVisionBoards(List<VisionBoard> boards) async {
    await init();
    final List<String> boardsStr = boards.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList('savedVisionBoards', boardsStr);
  }

  VisionBoard getActiveVisionBoard() {
    final String? boardStr = _prefs?.getString('activeVisionBoard');
    if (boardStr == null) {
      return VisionBoard(
        id: 'active_default',
        title: 'My Vision Board 2026',
        template: '4 Blocks',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        blocks: [
          GoalBlock(
            id: 'gb_1',
            title: 'Inner Peace & Wealth',
            category: 'Mindset',
            bgImageUrl: 'assets/images/onboarding_archway_sun.jpg',
            tintValue: 0xFF8A85A0,
            quote: 'I am a magnet for extraordinary abundance and peace.',
            targetDate: '2026',
          ),
          GoalBlock(
            id: 'gb_2',
            title: 'Peak Energy & Vitality',
            category: 'Health',
            bgImageUrl: 'assets/images/featured_meditation.jpg',
            tintValue: 0xFF2A2A3E,
            quote: 'My mind and body vibrate with vibrant health.',
            targetDate: 'Daily Habit',
          ),
          GoalBlock(
            id: 'gb_3',
            title: 'Financial Freedom',
            category: 'Wealth',
            bgImageUrl: 'assets/images/onboarding_girl_profile.jpg',
            tintValue: 0xFFFFD700,
            quote: 'I attract wealth and build multiple streams of prosperity.',
            targetDate: 'Dec 2026',
          ),
          GoalBlock(
            id: 'gb_4',
            title: 'Deep Rest & Sleep',
            category: 'Mindset',
            bgImageUrl: 'assets/images/sleep_story_night.jpg',
            tintValue: 0xFF060D2E,
            quote: 'I surrender to tranquil peace and restore my mind.',
            targetDate: 'Nightly',
          ),
        ],
      );
    }
    try {
      return VisionBoard.fromJson(jsonDecode(boardStr));
    } catch (_) {
      return VisionBoard(
        id: 'active_default',
        title: 'My Vision Board',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
    }
  }

  Future<void> saveActiveVisionBoard(VisionBoard board) async {
    await init();
    await _prefs?.setString('activeVisionBoard', jsonEncode(board.toJson()));
  }

  // Mode & Mood
  String getAppMode() => _prefs?.getString('appMode') ?? 'growth';
  Future<void> setAppMode(String mode) async {
    await init();
    await _prefs?.setString('appMode', mode);
  }

  String getSelectedMood() => _prefs?.getString('selectedMood') ?? '';
  Future<void> setSelectedMood(String mood) async {
    await init();
    await _prefs?.setString('selectedMood', mood);
  }

  // User Profile Vector (Personalization Engine)
  UserProfileVector getUserProfileVector() {
    final String? vecStr = _prefs?.getString('userProfileVector');
    if (vecStr == null) return UserProfileVector();
    try {
      return UserProfileVector.fromJson(jsonDecode(vecStr));
    } catch (_) {
      return UserProfileVector();
    }
  }

  Future<void> saveUserProfileVector(UserProfileVector profile) async {
    await init();
    await _prefs?.setString('userProfileVector', jsonEncode(profile.toJson()));
  }

  // Primitive Helpers
  bool getBool(String key, {bool defaultValue = false}) => _prefs?.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs?.setBool(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) => _prefs?.getInt(key) ?? defaultValue;
  Future<void> setInt(String key, int value) async {
    await init();
    await _prefs?.setInt(key, value);
  }

  String getString(String key, {String defaultValue = ''}) => _prefs?.getString(key) ?? defaultValue;
  Future<void> setString(String key, String value) async {
    await init();
    await _prefs?.setString(key, value);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
