import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../models/streak.dart';
import '../models/user_recording.dart';
import '../models/user_profile_vector.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool getOnboardingStatus() => _prefs.getBool('onboardingStatus') ?? false;
  Future<void> setOnboardingStatus(bool value) => _prefs.setBool('onboardingStatus', value);

  // Survey
  Map<String, String> getSurveyAnswers() {
    return {
      'goal': _prefs.getString('survey_goal') ?? 'Boost Confidence',
      'challenge': _prefs.getString('survey_challenge') ?? 'Overthinking & Self-Doubt',
      'vision': _prefs.getString('survey_vision') ?? 'Calm & Confident Mind',
      'commitment': _prefs.getString('survey_commitment') ?? '10 Min/Day',
    };
  }
  Future<void> setSurveyAnswers(String goal, String challenge, String vision, String commitment) async {
    await _prefs.setString('survey_goal', goal);
    await _prefs.setString('survey_challenge', challenge);
    await _prefs.setString('survey_vision', vision);
    await _prefs.setString('survey_commitment', commitment);
  }

  // Premium
  bool getPremiumStatus() => _prefs.getBool('premiumStatus') ?? false;
  Future<void> setPremiumStatus(bool value) => _prefs.setBool('premiumStatus', value);

  // Favorites
  List<String> getFavoriteAffirmations() => _prefs.getStringList('favoriteAffirmations') ?? [];
  Future<void> setFavoriteAffirmations(List<String> ids) => _prefs.setStringList('favoriteAffirmations', ids);

  // Journal Entries
  List<JournalEntry> getJournalEntries() {
    final List<String>? entriesStr = _prefs.getStringList('journalEntries');
    if (entriesStr == null) return [];
    return entriesStr.map((e) => JournalEntry.fromJson(jsonDecode(e))).toList();
  }
  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final List<String> entriesStr = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('journalEntries', entriesStr);
  }

  // Streak Data
  StreakData getStreakData() {
    final String? streakStr = _prefs.getString('streakData');
    if (streakStr == null) return StreakData();
    return StreakData.fromJson(jsonDecode(streakStr));
  }
  Future<void> saveStreakData(StreakData data) async {
    await _prefs.setString('streakData', jsonEncode(data.toJson()));
  }

  // Playlists
  List<String> getRecentPlaylists() => _prefs.getStringList('recentPlaylists') ?? [];
  Future<void> setRecentPlaylists(List<String> ids) => _prefs.setStringList('recentPlaylists', ids);

  // User Recordings
  List<UserRecording> getUserRecordings() {
    final List<String>? recsStr = _prefs.getStringList('userRecordings');
    if (recsStr == null) return [];
    return recsStr.map((e) => UserRecording.fromJson(jsonDecode(e))).toList();
  }
  Future<void> saveUserRecordings(List<UserRecording> recordings) async {
    final List<String> recsStr = recordings.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('userRecordings', recsStr);
  }

  // Mode & Mood
  String getAppMode() => _prefs.getString('appMode') ?? 'growth';
  Future<void> setAppMode(String mode) => _prefs.setString('appMode', mode);

  String getSelectedMood() => _prefs.getString('selectedMood') ?? '';
  Future<void> setSelectedMood(String mood) => _prefs.setString('selectedMood', mood);

  // User Profile Vector (Personalization Engine)
  UserProfileVector getUserProfileVector() {
    final String? vecStr = _prefs.getString('userProfileVector');
    if (vecStr == null) return UserProfileVector();
    try {
      return UserProfileVector.fromJson(jsonDecode(vecStr));
    } catch (_) {
      return UserProfileVector();
    }
  }

  Future<void> saveUserProfileVector(UserProfileVector profile) async {
    await _prefs.setString('userProfileVector', jsonEncode(profile.toJson()));
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
