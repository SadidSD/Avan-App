import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../models/streak.dart';
import '../models/user_recording.dart';
import '../services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isPremium = false;
  bool _isOnboardingCompleted = false;
  int _currentNavIndex = 0;

  String _selectedGoal = 'Boost Confidence';
  String _selectedChallenge = 'Overthinking & Self-Doubt';
  String _selectedVision = 'Calm & Confident Mind';
  String _selectedCommitment = '10 Min/Day';

  StreakData _streakData = StreakData();
  List<JournalEntry> _journalEntries = [];
  List<String> _favoriteAffirmations = [];
  List<UserRecording> _userRecordings = [];

  bool get isPremium => _isPremium;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  int get currentNavIndex => _currentNavIndex;

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
    
    final survey = _storageService.getSurveyAnswers();
    _selectedGoal = survey['goal']!;
    _selectedChallenge = survey['challenge']!;
    _selectedVision = survey['vision']!;
    _selectedCommitment = survey['commitment']!;

    _streakData = _storageService.getStreakData();
    _journalEntries = _storageService.getJournalEntries();
    _favoriteAffirmations = _storageService.getFavoriteAffirmations();
    _userRecordings = _storageService.getUserRecordings();

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

  Future<void> toggleFavorite(String affirmationId) async {
    if (_favoriteAffirmations.contains(affirmationId)) {
      _favoriteAffirmations.remove(affirmationId);
    } else {
      _favoriteAffirmations.add(affirmationId);
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
    _currentNavIndex = 0;
    notifyListeners();
  }
}
