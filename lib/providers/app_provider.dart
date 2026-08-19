import 'package:flutter/foundation.dart';
import '../models/affirmation.dart';
import '../models/journal_entry.dart';
import '../models/playlist.dart';
import '../models/streak.dart';
import '../models/user_archetype.dart';
import '../models/user_profile_vector.dart';
import '../models/user_recording.dart';
import '../services/storage_service.dart';
import '../services/personalization_engine.dart';
import '../data/playlists_data.dart';

enum AppMode { growth, healing, auto }

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isPremium = false;
  bool _isOnboardingCompleted = false;
  int _currentNavIndex = 0;

  AppMode _appModeSetting = AppMode.growth;
  String _selectedMood = '';

  String _selectedGoal = 'Boost Confidence';
  String _selectedChallenge = 'Overthinking & Self-Doubt';
  String _selectedVision = 'Calm & Confident Mind';
  String _selectedCommitment = '10 Min/Day';

  UserProfileVector _userProfileVector = UserProfileVector();

  StreakData _streakData = StreakData();
  List<JournalEntry> _journalEntries = [];
  List<String> _favoriteAffirmations = [];
  List<UserRecording> _userRecordings = [];

  bool get isPremium => _isPremium;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  int get currentNavIndex => _currentNavIndex;

  AppMode get appModeSetting => _appModeSetting;
  String get selectedMood => _selectedMood;
  UserProfileVector get userProfileVector => _userProfileVector;

  /// Resolves active mode (handles 'auto' mode based on current time of day)
  AppMode get activeAppMode {
    if (_appModeSetting == AppMode.auto) {
      final hour = DateTime.now().hour;
      return (hour >= 6 && hour < 18) ? AppMode.growth : AppMode.healing;
    }
    return _appModeSetting;
  }

  bool get isGrowthMode => activeAppMode == AppMode.growth;

  String get selectedGoal => _selectedGoal;
  String get selectedChallenge => _selectedChallenge;
  String get selectedVision => _selectedVision;
  String get selectedCommitment => _selectedCommitment;

  StreakData get streakData => _streakData;
  List<JournalEntry> get journalEntries => _journalEntries;
  List<String> get favoriteAffirmations => _favoriteAffirmations;
  List<UserRecording> get userRecordings => _userRecordings;

  AppProvider() {
    loadState();
  }

  Future<void> loadState() async {
    await _storageService.init();

    _isOnboardingCompleted = _storageService.getOnboardingStatus();
    _isPremium = _storageService.getPremiumStatus();
    
    final modeStr = _storageService.getAppMode();
    if (modeStr == 'healing') {
      _appModeSetting = AppMode.healing;
    } else if (modeStr == 'auto') {
      _appModeSetting = AppMode.auto;
    } else {
      _appModeSetting = AppMode.growth;
    }

    _selectedMood = _storageService.getSelectedMood();

    final survey = _storageService.getSurveyAnswers();
    _selectedGoal = survey['goal']!;
    _selectedChallenge = survey['challenge']!;
    _selectedVision = survey['vision']!;
    _selectedCommitment = survey['commitment']!;

    _userProfileVector = _storageService.getUserProfileVector();

    // If profile vector is empty (first launch / upgrade), initialize it
    if (_userProfileVector.vector.every((v) => v == 0.0)) {
      _initializeVectorFromSurvey();
    }

    _streakData = _storageService.getStreakData();
    _journalEntries = _storageService.getJournalEntries();
    _favoriteAffirmations = _storageService.getFavoriteAffirmations();
    _userRecordings = _storageService.getUserRecordings();

    notifyListeners();
  }

  void _initializeVectorFromSurvey() {
    List<UserArchetype> primary = [UserArchetype.careerProfessional];
    if (_selectedGoal.contains('Confidence')) primary = [UserArchetype.careerProfessional];
    if (_selectedGoal.contains('Stress') || _selectedGoal.contains('Anxiety')) primary = [UserArchetype.anxiousOverthinker];
    if (_selectedGoal.contains('Focus') || _selectedGoal.contains('Productivity')) primary = [UserArchetype.selfImprovement];
    if (_selectedGoal.contains('Relationships')) primary = [UserArchetype.heartbreakSurvivor];
    if (_selectedGoal.contains('Wealth')) primary = [UserArchetype.spiritualSeeker];

    final initialVec = PersonalizationEngine.buildArchetypeBaseVector(
      primary: primary,
      secondary: [],
      subLevels: [],
      tone: AffirmationTone.empowering,
    );

    _userProfileVector = UserProfileVector(
      primaryArchetypes: primary,
      vector: initialVec,
    );
    _storageService.saveUserProfileVector(_userProfileVector);
  }

  // ===========================================================================
  // PERSONALIZATION GETTERS & METHODS
  // ===========================================================================

  /// Returns dynamically ranked personalized affirmations for the active user
  List<Affirmation> getPersonalizedFeed({int limit = 10}) {
    final pool = getAllGlobalAffirmations();
    return PersonalizationEngine.getPersonalizedFeed(
      profile: _userProfileVector,
      pool: pool,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
      limit: limit,
    );
  }

  /// Returns the top hero affirmation for today
  Affirmation getHeroAffirmation() {
    final pool = getAllGlobalAffirmations();
    return PersonalizationEngine.getHeroAffirmation(
      profile: _userProfileVector,
      pool: pool,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
    );
  }

  /// Returns a situational dynamic playlist tailored to the user's primary archetype & state
  Playlist getSituationalPlaylist() {
    final pool = getAllGlobalAffirmations();
    return PersonalizationEngine.generateSituationalPlaylist(
      profile: _userProfileVector,
      pool: pool,
      isGrowthMode: isGrowthMode,
    );
  }

  /// Updates the user's multi-archetype profile and synthesizes a new base vector
  Future<void> setUserArchetypeProfile({
    required List<UserArchetype> primary,
    List<UserArchetype> secondary = const [],
    List<String> subLevels = const [],
    AffirmationTone tone = AffirmationTone.empowering,
    double believability = 0.8,
  }) async {
    final newVector = PersonalizationEngine.buildArchetypeBaseVector(
      primary: primary,
      secondary: secondary,
      subLevels: subLevels,
      tone: tone,
    );

    _userProfileVector = UserProfileVector(
      primaryArchetypes: primary,
      secondaryArchetypes: secondary,
      selectedSubLevels: subLevels,
      preferredTone: tone,
      vector: newVector,
      believabilityPreference: believability,
      lastUpdated: DateTime.now(),
      interactionCount: _userProfileVector.interactionCount,
    );

    await _storageService.saveUserProfileVector(_userProfileVector);
    notifyListeners();
  }

  Future<void> setAppMode(AppMode mode) async {
    _appModeSetting = mode;
    String modeStr = 'growth';
    if (mode == AppMode.healing) modeStr = 'healing';
    if (mode == AppMode.auto) modeStr = 'auto';
    await _storageService.setAppMode(modeStr);
    notifyListeners();
  }

  Future<void> setSelectedMood(String mood) async {
    if (_selectedMood == mood) {
      _selectedMood = ''; // toggle off if tapped again
    } else {
      _selectedMood = mood;
    }
    await _storageService.setSelectedMood(_selectedMood);
    notifyListeners();
  }

  Future<void> togglePremium() async {
    _isPremium = !_isPremium;
    await _storageService.setPremiumStatus(_isPremium);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    await _storageService.setOnboardingStatus(true);
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> setSurveyAnswers({
    required String goal,
    required String challenge,
    required String vision,
    required String commitment,
  }) async {
    _selectedGoal = goal;
    _selectedChallenge = challenge;
    _selectedVision = vision;
    _selectedCommitment = commitment;
    await _storageService.setSurveyAnswers(goal, challenge, vision, commitment);
    notifyListeners();
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    _journalEntries.insert(0, entry);
    await _storageService.saveJournalEntries(_journalEntries);
    notifyListeners();
  }

  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);
    await _storageService.saveJournalEntries(_journalEntries);
    notifyListeners();
  }

  Future<void> incrementStreak() async {
    _streakData.incrementStreak(DateTime.now());
    await _storageService.saveStreakData(_streakData);
    notifyListeners();
  }

  /// Toggles favorite and adapts user profile vector via online learning (EMA)
  Future<void> toggleFavorite(String affirmationId) async {
    final pool = getAllGlobalAffirmations();
    final matchingAff = pool.firstWhere(
      (a) => a.id == affirmationId,
      orElse: () => pool.first,
    );

    if (_favoriteAffirmations.contains(affirmationId)) {
      _favoriteAffirmations.remove(affirmationId);
    } else {
      _favoriteAffirmations.add(affirmationId);

      // Online Learning: shift user profile vector slightly toward favorited affirmation
      if (matchingAff.embeddingVector.isNotEmpty) {
        final updatedVec = PersonalizationEngine.updateVectorWithInteraction(
          currentVector: _userProfileVector.vector,
          affirmationVector: matchingAff.embeddingVector,
          learningRate: 0.12,
        );
        _userProfileVector = _userProfileVector.copyWith(
          vector: updatedVec,
          interactionCount: _userProfileVector.interactionCount + 1,
          lastUpdated: DateTime.now(),
        );
        await _storageService.saveUserProfileVector(_userProfileVector);
      }
    }
    await _storageService.setFavoriteAffirmations(_favoriteAffirmations);
    notifyListeners();
  }

  Future<void> addUserRecording(UserRecording rec) async {
    _userRecordings.insert(0, rec);
    await _storageService.saveUserRecordings(_userRecordings);
    notifyListeners();
  }

  Future<void> deleteUserRecording(String id) async {
    _userRecordings.removeWhere((e) => e.id == id);
    await _storageService.saveUserRecordings(_userRecordings);
    notifyListeners();
  }

  Future<void> toggleFavoriteRecording(String id) async {
    final index = _userRecordings.indexWhere((e) => e.id == id);
    if (index != -1) {
      _userRecordings[index] = _userRecordings[index].copyWith(
        isFavorite: !_userRecordings[index].isFavorite,
      );
      await _storageService.saveUserRecordings(_userRecordings);
      notifyListeners();
    }
  }

  Future<void> renameUserRecording(String id, String newTitle) async {
    final index = _userRecordings.indexWhere((e) => e.id == id);
    if (index != -1) {
      _userRecordings[index] = _userRecordings[index].copyWith(
        title: newTitle,
      );
      await _storageService.saveUserRecordings(_userRecordings);
      notifyListeners();
    }
  }

  Future<void> resetAppData() async {
    await _storageService.clearAll();
    _isOnboardingCompleted = false;
    _isPremium = false;
    _favoriteAffirmations = [];
    _journalEntries = [];
    _userRecordings = [];
    _streakData = StreakData();
    _userProfileVector = UserProfileVector();
    _currentNavIndex = 0;
    notifyListeners();
  }
}
