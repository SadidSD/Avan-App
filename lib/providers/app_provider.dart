import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../services/widget_service.dart';
import '../services/purchase_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/adapty_service.dart';
import '../data/playlists_data.dart' as playlists_data;

enum AppMode { growth, healing, auto }

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final CloudSyncService _cloudSyncService = CloudSyncService();

  StreamSubscription<User?>? _authSubscription;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool _isPremium = false;
  bool _isOnboardingCompleted = false;
  bool _isInitialized = false;
  int _currentNavIndex = 0;

  String _userName = 'Friend';
  String _userEmail = '';
  bool _isCloudSyncEnabled = false;

  String _userTypedChallenge = '';
  String _userTypedAspiration = '';

  AppMode _appModeSetting = AppMode.growth;
  String _selectedMood = '';

  String _selectedGoal = 'Boost Confidence';
  String _selectedChallenge = 'Overthinking & Self-Doubt';
  String _selectedVision = 'Calm & Confident Mind';
  String _selectedCommitment = '10 Min/Day';

  UserProfileVector _userProfileVector = UserProfileVector();
  Map<String, int> _lastListenedTimestamps = {};
  int _completedSessionsCount = 0;
  int _recentSkipCount = 0;

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

  // Performance optimization: Memoized personalization results
  List<PlaylistMatch>? _cachedPersonalizedPlaylists;
  String? _cachedPersonalizedPlaylistsKey;

  Playlist? _cachedSituationalPlaylist;
  String? _cachedSituationalPlaylistKey;

  Affirmation? _cachedHeroAffirmation;
  String? _cachedHeroAffirmationKey;

  void _invalidatePersonalizationCache() {
    _cachedPersonalizedPlaylists = null;
    _cachedPersonalizedPlaylistsKey = null;
    _cachedSituationalPlaylist = null;
    _cachedSituationalPlaylistKey = null;
    _cachedHeroAffirmation = null;
    _cachedHeroAffirmationKey = null;
  }

  bool get isPremium => _isPremium;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isInitialized => _isInitialized;
  int get currentNavIndex => _currentNavIndex;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isCloudSyncEnabled => _isCloudSyncEnabled;

  String get userTypedChallenge => _userTypedChallenge;
  String get userTypedAspiration => _userTypedAspiration;

  AppMode get appModeSetting => _appModeSetting;
  String get selectedMood => _selectedMood;

  VisionBoard get activeVisionBoard => _activeVisionBoard;
  List<VisionBoard> get savedVisionBoards => _savedBoards;
  UserProfileVector get userProfileVector => _userProfileVector;
  Map<String, int> get lastListenedTimestamps => _lastListenedTimestamps;
  int get completedSessionsCount => _completedSessionsCount;
  int get recentSkipCount => _recentSkipCount;

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
  List<String> get favorites => _favoriteAffirmations;
  List<UserRecording> get userRecordings => _userRecordings;

  StorageService get storageService => _storageService;
  AuthService get authService => _authService;
  CloudSyncService get cloudSyncService => _cloudSyncService;
  AdaptyService get adaptyService => AdaptyService();
  bool get isSignedIn => _authService.isSignedIn;
  String? get userPhotoUrl => _authService.photoUrl;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void>? _loadStateFuture;

  AppProvider() {
    loadState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadState({bool forceReload = false}) {
    if (forceReload) {
      _loadStateFuture = null;
    }
    _loadStateFuture ??= _loadStateInternal();
    return _loadStateFuture!;
  }

  Future<void> _loadStateInternal() async {
    await _storageService.init();

    _isOnboardingCompleted = _storageService.getOnboardingStatus();
    _isPremium = _storageService.getPremiumStatus();

    // Bind real-time store subscription updates
    PurchaseService().initialize((isPremium) {
      setPremium(isPremium);
    });

    // Bind real-time Adapty subscription entitlement updates
    AdaptyService().initialize((isPremium) {
      if (isPremium) {
        setPremium(true);
      }
    });
    
    _userName = _storageService.getString('user_name', defaultValue: 'Friend');
    _userEmail = _storageService.getString('user_email', defaultValue: '');
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

    _userTypedChallenge = _storageService.getUserTypedChallenge();
    _userTypedAspiration = _storageService.getUserTypedAspiration();

    _userProfileVector = _storageService.getUserProfileVector();

    // Load Ebbinghaus habituation timestamps and prune entries older than 14 days
    _lastListenedTimestamps = _storageService.getListeningTimestamps();
    final cutoffEpoch = DateTime.now().subtract(const Duration(days: 14)).millisecondsSinceEpoch;
    _lastListenedTimestamps.removeWhere((_, ts) => ts < cutoffEpoch);

    // Load ZPD session counts and skips
    _completedSessionsCount = _storageService.getCompletedSessionsCount();
    _recentSkipCount = _storageService.getRecentSkipCount();
    _userProfileVector = _userProfileVector.copyWith(
      completedSessionsCount: _completedSessionsCount,
      recentSkipCount: _recentSkipCount,
    );

    // If profile vector is empty (first launch / upgrade), initialize it
    if (_userProfileVector.vector.every((v) => v == 0.0)) {
      _initializeVectorFromSurvey();
    }

    _streakData = _storageService.getStreakData();
    _journalEntries = _storageService.getJournalEntries();
    _favoriteAffirmations = _storageService.getFavoriteAffirmations();
    _userRecordings = _storageService.getUserRecordings();
    _activeVisionBoard = _storageService.getActiveVisionBoard();
    final demoIds = {'gb_1', 'gb_2', 'gb_3', 'gb_4', 'gb_5', 'gb_6', 'gb_7', 'gb_8'};
    if (_activeVisionBoard.blocks.any((b) => demoIds.contains(b.id))) {
      _activeVisionBoard = _activeVisionBoard.copyWith(
        blocks: _activeVisionBoard.blocks.where((b) => !demoIds.contains(b.id)).toList(),
      );
      _storageService.saveActiveVisionBoard(_activeVisionBoard);
    }
    _savedBoards = _storageService.getSavedVisionBoards();

    final lastSyncStr = _storageService.getString('last_sync_time');
    if (lastSyncStr.isNotEmpty) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    _authSubscription ??= _authService.authStateChanges.listen((user) async {
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty && _userName == 'Friend') {
          _userName = user.displayName!;
          await _storageService.setString('user_name', _userName);
        }
        if (user.email != null && user.email!.isNotEmpty && _userEmail.isEmpty) {
          _userEmail = user.email!;
          await _storageService.setString('user_email', _userEmail);
        }
      }
      notifyListeners();
    });

    _isInitialized = true;
    _invalidatePersonalizationCache();
    syncNativeWidgets();
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String email}) async {
    _userName = name.trim().isNotEmpty ? name.trim() : 'Friend';
    _userEmail = email.trim();
    await _storageService.setString('user_name', _userName);
    await _storageService.setString('user_email', _userEmail);
    notifyListeners();
  }

  Future<void> setCloudSync(bool enabled) async {
    _isCloudSyncEnabled = enabled;
    await _storageService.setBool('cloud_sync_enabled', enabled);
    notifyListeners();
  }

  // ===========================================================================
  // GOOGLE AUTH & CLOUD VAULT SYNC
  // ===========================================================================

  /// Initiates Google Sign-In and auto-syncs local data into user's Cloud Vault.
  Future<bool> signInWithGoogle() async {
    try {
      final userCred = await _authService.signInWithGoogle();
      if (userCred == null || userCred.user == null) {
        return false;
      }
      final user = userCred.user!;
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _userName = user.displayName!;
        await _storageService.setString('user_name', _userName);
      }
      if (user.email != null && user.email!.isNotEmpty) {
        _userEmail = user.email!;
        await _storageService.setString('user_email', _userEmail);
      }

      _isCloudSyncEnabled = true;
      await _storageService.setBool('cloud_sync_enabled', true);

      // Identify user in Adapty with Firebase UID for cross-platform subscriber analytics
      await AdaptyService().identifyUser(user.uid);

      // Perform initial cloud backup
      await syncToCloud();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AppProvider] signInWithGoogle error: $e');
      return false;
    }
  }

  /// Signs out of Google and Firebase, returning to local guest mode.
  Future<void> signOut() async {
    await _authService.signOut();
    await AdaptyService().logoutUser();
    _isCloudSyncEnabled = false;
    await _storageService.setBool('cloud_sync_enabled', false);
    notifyListeners();
  }

  /// Permanently deletes user account from Firebase and wipes Cloud Vault (Google Play compliance).
  Future<bool> deleteAccount() async {
    try {
      final uid = _authService.userId;
      if (uid != null) {
        await _cloudSyncService.deleteCloudVault(uid);
      }
      final success = await _authService.deleteAccount();
      _isCloudSyncEnabled = false;
      await _storageService.setBool('cloud_sync_enabled', false);
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[AppProvider] deleteAccount error: $e');
      return false;
    }
  }

  /// Synchronizes local progress, journals, streaks, and vision boards to Cloud Firestore.
  Future<bool> syncToCloud() async {
    final uid = _authService.userId;
    if (uid == null) return false;

    _isSyncing = true;
    notifyListeners();

    try {
      final success = await _cloudSyncService.uploadLocalToCloud(
        userId: uid,
        appProvider: this,
      );

      if (success) {
        _lastSyncTime = DateTime.now();
        await _storageService.setString('last_sync_time', _lastSyncTime!.toIso8601String());
      }
      return success;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Restores progress from Cloud Firestore onto this local device.
  Future<bool> restoreFromCloud() async {
    final uid = _authService.userId;
    if (uid == null) return false;

    _isSyncing = true;
    notifyListeners();

    try {
      final success = await _cloudSyncService.restoreCloudToLocal(
        userId: uid,
        appProvider: this,
      );

      if (success) {
        _lastSyncTime = DateTime.now();
        await _storageService.setString('last_sync_time', _lastSyncTime!.toIso8601String());
      }
      return success;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _initializeVectorFromSurvey() {
    List<UserArchetype> primary = [UserArchetype.careerProfessional];
    List<UserArchetype> secondary = [];
    List<String> subLevels = [];
    AffirmationTone tone = AffirmationTone.empowering;

    // 1. Goal -> Primary Archetype
    if (_selectedGoal.contains('Confidence')) {
      primary = [UserArchetype.careerProfessional];
      subLevels.add('Founder / Solopreneur');
    } else if (_selectedGoal.contains('Stress') || _selectedGoal.contains('Anxiety')) {
      primary = [UserArchetype.anxiousOverthinker];
      subLevels.add('Panic Attacks & Acute Physical Tension');
    } else if (_selectedGoal.contains('Focus') || _selectedGoal.contains('Productivity')) {
      primary = [UserArchetype.selfImprovement];
      subLevels.add('Daily Habit & Consistency Builder');
    } else if (_selectedGoal.contains('Relationships') || _selectedGoal.contains('Love')) {
      primary = [UserArchetype.heartbreakSurvivor];
      subLevels.add('Fresh Breakup / Shock Phase (Day 0-30)');
    } else if (_selectedGoal.contains('Wealth') || _selectedGoal.contains('Abundance')) {
      primary = [UserArchetype.spiritualSeeker];
      subLevels.add('Law of Attraction & Manifestation Alignment');
    }

    // 2. Challenge -> Secondary Archetype (Fix for Gap 5 - Multi-Field Survey Synthesis)
    if (_selectedChallenge.contains('Overthinking') || _selectedChallenge.contains('Self-Doubt') || _selectedChallenge.contains('Anxiety')) {
      if (!primary.contains(UserArchetype.anxiousOverthinker)) {
        secondary.add(UserArchetype.anxiousOverthinker);
        subLevels.add('Bedtime & Late-Night Rumination');
      }
    } else if (_selectedChallenge.contains('Burnout') || _selectedChallenge.contains('Exhaustion')) {
      if (!primary.contains(UserArchetype.selfImprovement)) {
        secondary.add(UserArchetype.selfImprovement);
        subLevels.add('Deep Work & Focus Optimizer');
      }
    } else if (_selectedChallenge.contains('Heartbreak') || _selectedChallenge.contains('Grief')) {
      if (!primary.contains(UserArchetype.heartbreakSurvivor)) {
        secondary.add(UserArchetype.heartbreakSurvivor);
      }
    }

    // 3. Vision -> Tone (Fix for Gap 5)
    if (_selectedVision.contains('Calm') || _selectedVision.contains('Peace')) {
      tone = AffirmationTone.gentleAndGrounding;
    } else if (_selectedVision.contains('Wisdom') || _selectedVision.contains('Discipline')) {
      tone = AffirmationTone.philosophical;
    }

    // 4. Clinical Modalities from Archetypes (Fix for Gap 1)
    final Set<TherapeuticModality> modalities = {};
    for (var a in [...primary, ...secondary]) {
      final meta = ArchetypeRegistry.getMetadata(a);
      modalities.addAll(meta.primaryModalities);
    }

    final initialVec = PersonalizationEngine.buildArchetypeBaseVector(
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
      preferredModalities: modalities.toList(),
      vector: initialVec,
      baselineVector: initialVec,
      stateVector: initialVec,
      completedSessionsCount: _completedSessionsCount,
      recentSkipCount: _recentSkipCount,
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
      lastListenedTimestamps: _lastListenedTimestamps,
    );
  }

  /// Returns the top hero affirmation for today (memoized)
  Affirmation getHeroAffirmation() {
    final key = '${_userProfileVector.hashCode}_${isGrowthMode}_${_selectedMood}_${_lastListenedTimestamps.length}';
    if (_cachedHeroAffirmation != null && _cachedHeroAffirmationKey == key) {
      return _cachedHeroAffirmation!;
    }
    final pool = getAllGlobalAffirmations();
    _cachedHeroAffirmation = PersonalizationEngine.getHeroAffirmation(
      profile: _userProfileVector,
      pool: pool,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
      lastListenedTimestamps: _lastListenedTimestamps,
    );
    _cachedHeroAffirmationKey = key;
    return _cachedHeroAffirmation!;
  }

  /// Returns a situational dynamic playlist tailored to the user's primary archetype & state (memoized)
  Playlist getSituationalPlaylist() {
    final key = '${_userProfileVector.hashCode}_${isGrowthMode}_${_selectedMood}_${_lastListenedTimestamps.length}';
    if (_cachedSituationalPlaylist != null && _cachedSituationalPlaylistKey == key) {
      return _cachedSituationalPlaylist!;
    }
    final pool = getAllGlobalAffirmations();
    _cachedSituationalPlaylist = PersonalizationEngine.generateSituationalPlaylist(
      profile: _userProfileVector,
      pool: pool,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
      lastListenedTimestamps: _lastListenedTimestamps,
    );
    _cachedSituationalPlaylistKey = key;
    return _cachedSituationalPlaylist!;
  }

  /// Returns the ranked list of personalized playlists for the current user vector and mode (memoized)
  List<PlaylistMatch> getPersonalizedPlaylists() {
    final key = '${_userProfileVector.hashCode}_${isGrowthMode}_$_selectedMood';
    if (_cachedPersonalizedPlaylists != null && _cachedPersonalizedPlaylistsKey == key) {
      return _cachedPersonalizedPlaylists!;
    }
    _cachedPersonalizedPlaylists = PersonalizationEngine.rankPlaylists(
      profile: _userProfileVector,
      playlists: playlists_data.allPlaylists,
      isGrowthMode: isGrowthMode,
      mood: _selectedMood,
    );
    _cachedPersonalizedPlaylistsKey = key;
    return _cachedPersonalizedPlaylists!;
  }

  /// Adapts any playlist specifically for the active user: prunes habituated quotes and sequences
  /// affirmations into an escalating clinical therapeutic arc matched to user's ZPD state.
  Playlist adaptPlaylistForUser(Playlist playlist) {
    return playlist.adaptForUser(
      profile: _userProfileVector,
      lastListenedTimestamps: _lastListenedTimestamps,
      isGrowthMode: isGrowthMode,
    );
  }

  /// Synchronizes current hero affirmation, streak, and preferences with native OS widgets
  Future<void> syncNativeWidgets() async {
    try {
      final hero = getHeroAffirmation();
      await WidgetService.instance.updateWidgets(
        affirmation: hero,
        streakDays: _streakData.currentStreak,
        mood: _selectedMood.isNotEmpty ? _selectedMood : 'Peaceful',
      );
    } catch (e) {
      debugPrint('[AppProvider] syncNativeWidgets error: $e');
    }
  }

  Future<void> setUserArchetypeProfile({
    required List<UserArchetype> primary,
    required List<UserArchetype> secondary,
    required List<String> subLevels,
    required AffirmationTone tone,
    double believabilityPreference = 0.8,
    String? userName,
    String typedChallenge = '',
    String typedAspiration = '',
    int lifeStageIndex = -1,
    int somaticIndex = -1,
    bool isSomaticExpansion = false,
    int innerCriticIndex = -1,
    String limitingBelief = '',
    int dailyCommitmentMinutes = 10,
    String peakNeedTime = 'Morning',
  }) async {
    await loadState();

    if (userName != null && userName.trim().isNotEmpty) {
      _userName = userName.trim();
      await _storageService.setString('user_name', _userName);
    }
    if (typedChallenge.trim().isNotEmpty) {
      _userTypedChallenge = typedChallenge.trim();
      await _storageService.setUserTypedChallenge(_userTypedChallenge);
    }
    if (typedAspiration.trim().isNotEmpty) {
      _userTypedAspiration = typedAspiration.trim();
      await _storageService.setUserTypedAspiration(_userTypedAspiration);
    }

    final baseVector = PersonalizationEngine.buildArchetypeBaseVector(
      primary: primary,
      secondary: secondary,
      subLevels: subLevels,
      tone: tone,
      typedChallenge: _userTypedChallenge,
      typedAspiration: _userTypedAspiration,
      lifeStageIndex: lifeStageIndex,
      somaticIndex: somaticIndex,
      isSomaticExpansion: isSomaticExpansion,
      innerCriticIndex: innerCriticIndex,
      limitingBelief: limitingBelief,
    );
    // Derive clinical modalities from selected archetypes (Fix for Gap 1)
    final Set<TherapeuticModality> modalities = {};
    for (var a in [...primary, ...secondary]) {
      final meta = ArchetypeRegistry.getMetadata(a);
      modalities.addAll(meta.primaryModalities);
    }

    _userProfileVector = UserProfileVector(
      userName: _userName,
      userTypedChallenge: _userTypedChallenge,
      userTypedAspiration: _userTypedAspiration,
      primaryArchetypes: primary,
      secondaryArchetypes: secondary,
      selectedSubLevels: subLevels,
      preferredTone: tone,
      preferredModalities: modalities.toList(),
      vector: baseVector,
      baselineVector: baseVector,
      stateVector: baseVector,
      believabilityPreference: believabilityPreference,
      lastUpdated: DateTime.now(),
      completedSessionsCount: _completedSessionsCount,
      recentSkipCount: _recentSkipCount,
    );
    await _storageService.saveUserProfileVector(_userProfileVector);

    // Unify survey persistence with selected archetypes and tone
    final primaryMeta = ArchetypeRegistry.getMetadata(
        primary.isNotEmpty ? primary.first : UserArchetype.careerProfessional);
    _selectedGoal = primaryMeta.title;
    _selectedChallenge = _userTypedChallenge.isNotEmpty
        ? _userTypedChallenge
        : (subLevels.isNotEmpty ? subLevels.first : primaryMeta.shortDescription);
    _selectedVision = _userTypedAspiration.isNotEmpty ? _userTypedAspiration : tone.name;
    _selectedCommitment = 'Daily Routine';
    _invalidatePersonalizationCache();
    await _storageService.setSurveyAnswers(
        _selectedGoal, _selectedChallenge, _selectedVision, _selectedCommitment);

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
    _invalidatePersonalizationCache();
    final modeStr = mode == AppMode.healing ? 'healing' : (mode == AppMode.auto ? 'auto' : 'growth');
    await _storageService.setAppMode(modeStr);
    syncNativeWidgets();
    notifyListeners();
  }

  Future<void> setSelectedMood(String mood) async {
    if (_selectedMood == mood) {
      _selectedMood = '';
    } else {
      _selectedMood = mood;
    }
    _invalidatePersonalizationCache();
    await _storageService.setSelectedMood(_selectedMood);
    syncNativeWidgets();
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
    _invalidatePersonalizationCache();
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

  Future<void> toggleJournalFavorite(String id) async {
    final index = _journalEntries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _journalEntries[index].isFavorite = !_journalEntries[index].isFavorite;
      await _storageService.saveJournalEntries(_journalEntries);
      notifyListeners();
    }
  }

  Future<void> incrementStreak() async {
    _streakData.incrementStreak(DateTime.now());
    await _storageService.saveStreakData(_streakData);
    syncNativeWidgets();
    notifyListeners();
  }

  /// Records that an affirmation was listened to $>80% (implicit positive feedback, Fix for Gap 3 & Phase 1 Habituation)
  Future<void> recordAudioAffirmationCompleted(Affirmation affirmation) async {
    // 1. Record listening timestamp for Ebbinghaus habituation decay
    _lastListenedTimestamps[affirmation.id] = DateTime.now().millisecondsSinceEpoch;
    await _storageService.saveListeningTimestamps(_lastListenedTimestamps);

    // 2. Completed listen alleviates recent skip resistance
    if (_recentSkipCount > 0) {
      _recentSkipCount--;
      await _storageService.saveRecentSkipCount(_recentSkipCount);
    }

    if (affirmation.embeddingVector.isNotEmpty) {
      _userProfileVector = PersonalizationEngine.updateProfileWithInteraction(
        profile: _userProfileVector.copyWith(
          recentSkipCount: _recentSkipCount,
        ),
        affirmationVector: affirmation.embeddingVector,
        learningRate: 0.04, // Gentle passive feedback nudge
      );
      await _storageService.saveUserProfileVector(_userProfileVector);
    }
    _invalidatePersonalizationCache();
    notifyListeners();
  }

  /// Records that an affirmation was skipped early in <3s (implicit negative feedback, Fix for Gap 3 & ZPD safety retreat)
  Future<void> recordAudioAffirmationSkipped(Affirmation affirmation) async {
    // Increase recent skip count (capped at 5) to trigger ZPD safety retreat toward gentle grounding
    _recentSkipCount = (_recentSkipCount + 1).clamp(0, 5);
    await _storageService.saveRecentSkipCount(_recentSkipCount);

    if (affirmation.embeddingVector.isNotEmpty) {
      _userProfileVector = PersonalizationEngine.penalizeSkippedAffirmation(
        profile: _userProfileVector.copyWith(
          recentSkipCount: _recentSkipCount,
        ),
        affirmationVector: affirmation.embeddingVector,
        penaltyRate: 0.02, // Gentle negative nudge away from skipped theme
      );
      await _storageService.saveUserProfileVector(_userProfileVector);
    }
    _invalidatePersonalizationCache();
    notifyListeners();
  }

  /// Records audio playlist completion: increments listening streak, total listening days, and advances ZPD ladder (Phase 1)
  Future<void> recordAudioSessionCompleted(Playlist playlist) async {
    _streakData.incrementStreak(DateTime.now());
    await _storageService.saveStreakData(_streakData);

    // Advance ZPD Believability Ladder through completed session mastery
    _completedSessionsCount++;
    await _storageService.saveCompletedSessionsCount(_completedSessionsCount);
    _recentSkipCount = 0;
    await _storageService.saveRecentSkipCount(_recentSkipCount);

    _userProfileVector = _userProfileVector.copyWith(
      completedSessionsCount: _completedSessionsCount,
      recentSkipCount: _recentSkipCount,
    );

    // Reward user vector with session completion centroid alignment
    if (playlist.centroidVector.isNotEmpty) {
      _userProfileVector = PersonalizationEngine.updateProfileWithInteraction(
        profile: _userProfileVector,
        affirmationVector: playlist.centroidVector,
        learningRate: 0.06,
      );
    }
    await _storageService.saveUserProfileVector(_userProfileVector);
    _invalidatePersonalizationCache();
    syncNativeWidgets();
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

      // Online Learning: shift user profile vector slightly toward favorited affirmation using anchored dual-vector update
      if (matchingAff.embeddingVector.isNotEmpty) {
        _userProfileVector = PersonalizationEngine.updateProfileWithInteraction(
          profile: _userProfileVector,
          affirmationVector: matchingAff.embeddingVector,
          learningRate: 0.12,
        );
        await _storageService.saveUserProfileVector(_userProfileVector);
      }
    }
    _invalidatePersonalizationCache();
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

  int getTemplateTargetCount(String template) {
    switch (template) {
      case 'Single Hero':
        return 1;
      case '2 Blocks':
        return 2;
      case '4 Blocks':
        return 4;
      case '6 Blocks':
        return 6;
      case '8 Blocks':
        return 8;
      case 'Minimal Layout':
        return 4;
      default:
        return 4;
    }
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
    String currentTemplate = _activeVisionBoard.template;
    final currentCapacity = getTemplateTargetCount(currentTemplate);
    if (updatedBlocks.length > currentCapacity) {
      if (updatedBlocks.length <= 6) {
        currentTemplate = '6 Blocks';
      } else {
        currentTemplate = '8 Blocks';
      }
    }
    _activeVisionBoard = _activeVisionBoard.copyWith(
      template: currentTemplate,
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

  Future<void> reorderGoalBlocks(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _activeVisionBoard.blocks.length) return;
    if (newIndex < 0 || newIndex >= _activeVisionBoard.blocks.length) return;
    if (oldIndex == newIndex) return;

    final updatedBlocks = List<GoalBlock>.from(_activeVisionBoard.blocks);
    final item = updatedBlocks.removeAt(oldIndex);
    updatedBlocks.insert(newIndex, item);

    _activeVisionBoard = _activeVisionBoard.copyWith(
      blocks: updatedBlocks,
      lastModified: DateTime.now(),
    );
    await _storageService.saveActiveVisionBoard(_activeVisionBoard);
    notifyListeners();
  }

  Future<void> toggleGoalManifested(String id) async {
    final index = _activeVisionBoard.blocks.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updatedBlocks = List<GoalBlock>.from(_activeVisionBoard.blocks);
      final current = updatedBlocks[index];
      updatedBlocks[index] = current.copyWith(isManifested: !current.isManifested);
      _activeVisionBoard = _activeVisionBoard.copyWith(
        blocks: updatedBlocks,
        lastModified: DateTime.now(),
      );
      await _storageService.saveActiveVisionBoard(_activeVisionBoard);
      notifyListeners();
    }
  }

  Future<String> saveCustomGoalImage(XFile file) async {
    try {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64Str';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final visionDir = Directory('${dir.path}/vision_images');
        if (!await visionDir.exists()) {
          await visionDir.create(recursive: true);
        }
        final ext = file.name.split('.').last;
        final targetPath = '${visionDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final savedFile = await File(targetPath).writeAsBytes(await file.readAsBytes());
        return savedFile.path;
      }
    } catch (e) {
      debugPrint("Error saving custom goal image persistently: $e");
      return file.path;
    }
  }

  Future<void> deleteSavedBoard(String id) async {
    _savedBoards.removeWhere((b) => b.id == id);
    await _storageService.saveVisionBoards(_savedBoards);
    notifyListeners();
  }

  Future<void> duplicateSavedBoard(String id) async {
    final board = _savedBoards.firstWhere((b) => b.id == id, orElse: () => _activeVisionBoard);
    final dup = VisionBoard(
      id: 'board_${DateTime.now().millisecondsSinceEpoch}',
      title: '${board.title} (Copy)',
      template: board.template,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      blocks: List<GoalBlock>.from(board.blocks),
    );
    _savedBoards.insert(0, dup);
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
    _userName = 'Friend';
    _userEmail = '';
    _isCloudSyncEnabled = false;
    _favoriteAffirmations = [];
    _journalEntries = [];
    _userRecordings = [];
    _streakData = StreakData();
    _userProfileVector = UserProfileVector();
    _lastListenedTimestamps = {};
    _completedSessionsCount = 0;
    _recentSkipCount = 0;
    _currentNavIndex = 0;
    notifyListeners();
  }
}
