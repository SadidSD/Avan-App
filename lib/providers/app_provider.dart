import 'package:flutter/foundation.dart';
import '../models/affirmation.dart';
import '../models/journal_entry.dart';
import '../models/playlist.dart';
import '../models/streak.dart';
import '../models/user_archetype.dart';
import '../models/user_profile_vector.dart';
import '../models/user_recording.dart';
import '../models/vision_board.dart';
import '../services/storage_service.dart';
import '../services/personalization_engine.dart';
import '../data/playlists_data.dart' as playlists_data;

enum AppMode { growth, healing, auto }

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isPremium = true;
  bool _isOnboardingCompleted = false;
  int _currentNavIndex = 0;

  String _userName = 'Alex';
  String _userEmail = 'alex@email.com';
  bool _isCloudSyncEnabled = false;

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

  VisionBoard _activeVisionBoard = VisionBoard(
    id: 'active_default',
    title: 'My Vision Board 2026',
    createdAt: DateTime.now(),
    lastModified: DateTime.now(),
  );
  List<VisionBoard> _savedBoards = [];

  bool get isPremium => true;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  int get currentNavIndex => _currentNavIndex;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isCloudSyncEnabled => _isCloudSyncEnabled;

  AppMode get appModeSetting => _appModeSetting;
  String get selectedMood => _selectedMood;

  VisionBoard get activeVisionBoard => _activeVisionBoard;
  List<VisionBoard> get savedVisionBoards => _savedBoards;
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
    
    _userName = _storageService.getString('user_name', defaultValue: 'Alex');
    _userEmail = _storageService.getString('user_email', defaultValue: 'alex@email.com');
    _isCloudSyncEnabled = _storageService.getBool('cloud_sync_enabled', defaultValue: false);

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
    _activeVisionBoard = _storageService.getActiveVisionBoard();
    _savedBoards = _storageService.getSavedVisionBoards();

    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String email}) async {
    _userName = name.trim().isNotEmpty ? name.trim() : 'Alex';
    _userEmail = email.trim().isNotEmpty ? email.trim() : 'alex@email.com';
    await _storageService.setString('user_name', _userName);
    await _storageService.setString('user_email', _userEmail);
    notifyListeners();
  }

  Future<void> setCloudSync(bool enabled) async {
    _isCloudSyncEnabled = enabled;
    await _storageService.setBool('cloud_sync_enabled', enabled);
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

  /// Returns the ranked list of personalized playlists for the current user vector and mode
  List<PlaylistMatch> getPersonalizedPlaylists() {
    return PersonalizationEngine.rankPlaylists(
      profile: _userProfileVector,
      playlists: playlists_data.allPlaylists,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
    );
  }

  Future<void> setUserArchetypeProfile({
    required List<UserArchetype> primary,
    required List<UserArchetype> secondary,
    required List<String> subLevels,
    required AffirmationTone tone,
  }) async {
    final baseVector = PersonalizationEngine.buildArchetypeBaseVector(
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
      vector: baseVector,
      lastUpdated: DateTime.now(),
    );
    await _storageService.saveUserProfileVector(_userProfileVector);
    notifyListeners();
  }

  /// Returns all available affirmations across playlists and scientific library
  List<Affirmation> getAllGlobalAffirmations() {
    return playlists_data.getAllGlobalAffirmations();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> setAppMode(AppMode mode) async {
    _appModeSetting = mode;
    final modeStr = mode == AppMode.healing ? 'healing' : (mode == AppMode.auto ? 'auto' : 'growth');
    await _storageService.setAppMode(modeStr);
    notifyListeners();
  }

  Future<void> setSelectedMood(String mood) async {
    if (_selectedMood == mood) {
      _selectedMood = '';
    } else {
      _selectedMood = mood;
    }
    await _storageService.setSelectedMood(_selectedMood);
    notifyListeners();
  }

  Future<void> setPremium(bool val) async {
    _isPremium = val;
    await _storageService.setPremiumStatus(_isPremium);
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

  Future<void> saveSurveyAnswers({
    required String goal,
    required String challenge,
    required String vision,
    required String commitment,
    UserProfileVector? vector,
  }) async {
    _selectedGoal = goal;
    _selectedChallenge = challenge;
    _selectedVision = vision;
    _selectedCommitment = commitment;
    if (vector != null) {
      _userProfileVector = vector;
      await _storageService.saveUserProfileVector(vector);
    }
    await _storageService.setSurveyAnswers(goal, challenge, vision, commitment);
    notifyListeners();
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    _journalEntries.insert(0, entry);
    await _storageService.saveJournalEntries(_journalEntries);
    await incrementStreak();
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

  // ===========================================================================
  // VISION BOARD OPERATIONS
  // ===========================================================================
  Future<void> updateActiveVisionBoard(VisionBoard board) async {
    _activeVisionBoard = board.copyWith(lastModified: DateTime.now());
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> setActiveTemplate(String template) async {
    _activeVisionBoard = _activeVisionBoard.copyWith(
      template: template,
      lastModified: DateTime.now(),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> addGoalBlock(GoalBlock block) async {
    final updatedBlocks = List<GoalBlock>.from(_activeVisionBoard.blocks)..add(block);
    _activeVisionBoard = _activeVisionBoard.copyWith(
      blocks: updatedBlocks,
      lastModified: DateTime.now(),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> updateGoalBlock(String id, GoalBlock updated) async {
    final index = _activeVisionBoard.blocks.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updatedBlocks = List<GoalBlock>.from(_activeVisionBoard.blocks);
      updatedBlocks[index] = updated;
      _activeVisionBoard = _activeVisionBoard.copyWith(
        blocks: updatedBlocks,
        lastModified: DateTime.now(),
      );
      await _storageService.saveActiveVisionBoard(_activeVisionBoard);
      notifyListeners();
    }
  }

  Future<void> deleteGoalBlock(String id) async {
    final updatedBlocks = List<GoalBlock>.from(_activeVisionBoard.blocks)
      ..removeWhere((b) => b.id == id);
    _activeVisionBoard = _activeVisionBoard.copyWith(
      blocks: updatedBlocks,
      lastModified: DateTime.now(),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> clearActiveBoard() async {
    _activeVisionBoard = _activeVisionBoard.copyWith(
      blocks: [],
      lastModified: DateTime.now(),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> saveActiveBoardAsNew(String title) async {
    final newBoard = VisionBoard(
      id: 'board_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty ? title.trim() : 'Vision Board ${DateTime.now().year}',
      template: _activeVisionBoard.template,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      blocks: List<GoalBlock>.from(_activeVisionBoard.blocks),
    );
    _savedBoards.insert(0, newBoard);
    await _storageService.saveVisionBoards(_savedBoards);
    notifyListeners();
  }

  Future<void> loadSavedBoard(String id) async {
    final board = _savedBoards.firstWhere((b) => b.id == id, orElse: () => _activeVisionBoard);
    _activeVisionBoard = VisionBoard(
      id: 'active_${DateTime.now().millisecondsSinceEpoch}',
      title: board.title,
      template: board.template,
      createdAt: board.createdAt,
      lastModified: DateTime.now(),
      blocks: List<GoalBlock>.from(board.blocks),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> deleteSavedBoard(String id) async {
    _savedBoards.removeWhere((b) => b.id == id);
    await _storageService.saveVisionBoards(_savedBoards);
    notifyListeners();
  }

  Future<void> renameSavedBoard(String id, String newTitle) async {
    final index = _savedBoards.indexWhere((b) => b.id == id);
    if (index != -1) {
      _savedBoards[index] = _savedBoards[index].copyWith(
        title: newTitle.trim(),
        lastModified: DateTime.now(),
      );
      await _storageService.saveVisionBoards(_savedBoards);
      notifyListeners();
    }
  }

  Future<void> resetAppData() async {
    await _storageService.clearAll();
    _isOnboardingCompleted = false;
    _isPremium = false;
    _userName = 'Alex';
    _userEmail = 'alex@email.com';
    _isCloudSyncEnabled = false;
    _favoriteAffirmations = [];
    _journalEntries = [];
    _userRecordings = [];
    _streakData = StreakData();
    _userProfileVector = UserProfileVector();
    _currentNavIndex = 0;
    notifyListeners();
  }
}
