import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/affirmation.dart';
import '../models/playlist.dart';
import '../services/audio_engine_service.dart';
import '../data/playlists_data.dart';
import '../data/affirmation_library.dart';
import '../screens/player/player_screen.dart';

class AudioProvider with ChangeNotifier {
  final AudioEngineService _audioService = AudioEngineService();

  List<Playlist> get playlists => allPlaylists;

  Playlist? _currentPlaylist;
  int _currentAffirmationIndex = 0;
  bool _isPlayerOpen = false;

  // Pacing: exactly 2 seconds of silence gap between affirmations
  static const int defaultGapSeconds = 2;
  int _gapBetweenAffirmations = defaultGapSeconds; 
  int _intervalPerAffirmation = 4 + defaultGapSeconds; 
  int _sessionDurationSeconds = 56;
  int _sessionPositionSeconds = 0;
  bool _isLoopEnabled = false;

  List<int> _affirmationDurations = [];
  List<int> _affirmationStartOffsets = [];

  Timer? _sessionTicker;
  Timer? _gapTimer;
  Timer? _watchdogTimer;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0; // seconds
  bool _isCurrentSpeechFinished = false;

  // Feedback Callbacks for Vector Personalization & Streaks (Fix for Gap 3 & 8)
  void Function(Affirmation affirmation)? onAffirmationCompleted;
  void Function(Playlist playlist)? onSessionCompleted;
  void Function(Affirmation affirmation)? onAffirmationSkipped;

  AudioProvider() {
    _audioService.setAffirmationCompletionHandler(_onSpeechCompleted);
  }

  bool get isPlaying => _audioService.isPlaying;
  double get voiceVolume => _audioService.voiceVolume;
  double get voiceSpeed => _audioService.voiceSpeed;
  double get ambientVolume => _audioService.ambientVolume;
  AmbientSound get currentSound => _audioService.currentSound;

  int get positionSeconds => _sessionPositionSeconds;
  int get durationSeconds => _sessionDurationSeconds;
  int get intervalPerAffirmation => _intervalPerAffirmation;
  int get gapBetweenAffirmations => _gapBetweenAffirmations;
  bool get isLoopEnabled => _isLoopEnabled;
  int get sleepTimerRemaining => _sleepTimerRemaining;

  Playlist? get currentPlaylist => _currentPlaylist;

  Affirmation? get currentAffirmation {
    if (_currentPlaylist == null) return null;
    if (_currentPlaylist!.affirmations.isEmpty) return null;
    if (_currentAffirmationIndex >= _currentPlaylist!.affirmations.length) {
      _currentAffirmationIndex = 0;
    }
    return _currentPlaylist!.affirmations[_currentAffirmationIndex];
  }

  int get currentAffirmationIndex => _currentAffirmationIndex;
  bool get isPlayerOpen => _isPlayerOpen;

  int _estimateAffirmationDuration(Affirmation aff) {
    final words = aff.quote.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final double speed = _audioService.voiceSpeed > 0 ? _audioService.voiceSpeed : 1.0;
    // Calibrated natural speech rate: ~2.1 words per second at speed 1.0 (calm pacing)
    final double speechSeconds = (words / (2.1 * speed)).clamp(3.0, 45.0);
    final double totalSeconds = speechSeconds + _gapBetweenAffirmations;
    return totalSeconds.round();
  }

  void _recalculateSessionTimeline() {
    if (_currentPlaylist == null || _currentPlaylist!.affirmations.isEmpty) {
      _affirmationDurations = [10];
      _affirmationStartOffsets = [0];
      _sessionDurationSeconds = 10;
      return;
    }

    final affs = _currentPlaylist!.affirmations;
    _affirmationDurations = affs.map(_estimateAffirmationDuration).toList();

    int runningOffset = 0;
    _affirmationStartOffsets = [];
    for (final dur in _affirmationDurations) {
      _affirmationStartOffsets.add(runningOffset);
      runningOffset += dur;
    }
    _sessionDurationSeconds = math.max(runningOffset, 1);
  }

  int _calculateRemainingEstimatedSeconds() {
    int remaining = 0;
    for (int i = _currentAffirmationIndex; i < _affirmationDurations.length; i++) {
      remaining += _affirmationDurations[i];
    }
    return remaining;
  }

  void setIntervalPerAffirmation(int gapSeconds) {
    _gapBetweenAffirmations = gapSeconds.clamp(2, 8);
    _intervalPerAffirmation = 4 + _gapBetweenAffirmations;
    _recalculateSessionTimeline();
    notifyListeners();
  }

  /// Opens a specific affirmation and builds a complete multi-quote affirmation session
  void openAffirmation({
    required Affirmation affirmation,
    Playlist? parentPlaylist,
    BuildContext? context,
  }) {
    if (parentPlaylist != null) {
      final index = parentPlaylist.affirmations.indexWhere((a) => a.id == affirmation.id);
      if (index != -1) {
        openPlaylist(parentPlaylist, context, index);
        return;
      }
    }

    // Assemble a full personalized 8-quote session around this theme
    final List<Affirmation> relatedQuotes = [affirmation];
    final category = affirmation.category.toLowerCase();

    for (final aff in comprehensiveAffirmationLibrary) {
      if (relatedQuotes.length >= 8) break;
      if (aff.id != affirmation.id) {
        if (aff.category.toLowerCase() == category ||
            (aff.primaryArchetypes.isNotEmpty &&
             affirmation.primaryArchetypes.isNotEmpty &&
             aff.primaryArchetypes.first == affirmation.primaryArchetypes.first)) {
          relatedQuotes.add(aff);
        }
      }
    }

    if (relatedQuotes.length < 6) {
      for (final aff in comprehensiveAffirmationLibrary) {
        if (relatedQuotes.length >= 8) break;
        if (!relatedQuotes.any((item) => item.id == aff.id)) {
          relatedQuotes.add(aff);
        }
      }
    }

    final dynamicPlaylist = Playlist(
      id: 'personalized_session_${affirmation.id}',
      title: affirmation.category.isNotEmpty ? affirmation.category : 'Daily Affirmations',
      duration: '${(relatedQuotes.length * _intervalPerAffirmation / 60).ceil()} min',
      category: affirmation.category.isNotEmpty ? affirmation.category : 'Personalized',
      imagePath: parentPlaylist?.imagePath ?? 'assets/images/featured_meditation.jpg',
      isPremium: false,
      defaultAmbientSound: parentPlaylist?.defaultAmbientSound ?? AmbientSound.solfeggio528,
      affirmations: relatedQuotes,
    );

    openPlaylist(dynamicPlaylist, context, 0);
  }

  /// Opens a playlist at a specific affirmation index and opens the Player Screen
  void openPlaylist(Playlist playlist, [BuildContext? context, int initialIndex = 0]) {
    final bool isDifferent = _currentPlaylist?.id != playlist.id;

    _currentPlaylist = playlist;
    // Every playlist always enforces the standard 2-second default gap
    _gapBetweenAffirmations = defaultGapSeconds;
    _intervalPerAffirmation = 4 + defaultGapSeconds;
    _recalculateSessionTimeline();

    // Cancel all prior playlist session timers and stop previous audio
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionTicker?.cancel();
    _audioService.stop();

    _currentAffirmationIndex = (initialIndex >= 0 && initialIndex < playlist.affirmations.length)
        ? initialIndex
        : 0;
    _sessionPositionSeconds = (_currentAffirmationIndex < _affirmationStartOffsets.length)
        ? _affirmationStartOffsets[_currentAffirmationIndex]
        : 0;

    // Auto-activate the playlist's unique curated background soundscape!
    _audioService.setAmbientSound(playlist.defaultAmbientSound);
    _isPlayerOpen = true;

    _playCurrentAffirmation();
    _startSessionTicker();
    notifyListeners();

    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    }
  }

  void playSingleQuote(String quote, {String title = 'Daily Affirmation'}) {
    openCustomAudio(title: title, quote: quote, duration: '1 min');
  }

  void openCustomAudio({
    required String title,
    required String quote,
    String duration = '1 min',
    bool speakTts = true,
  }) {
    _gapBetweenAffirmations = defaultGapSeconds;
    _intervalPerAffirmation = 4 + defaultGapSeconds;
    final customAffirmation = Affirmation(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      quote: quote,
      category: 'Voice Studio',
    );
    _currentPlaylist = Playlist(
      id: 'custom_playlist',
      title: title,
      duration: duration,
      category: 'Voice Studio',
      imagePath: 'assets/images/featured_meditation.jpg',
      isPremium: false,
      defaultAmbientSound: AmbientSound.solfeggio432,
      affirmations: [customAffirmation],
    );
    _currentAffirmationIndex = 0;
    _sessionDurationSeconds = _intervalPerAffirmation;
    _sessionPositionSeconds = 0;
    _isPlayerOpen = true;

    if (speakTts) {
      _playCurrentAffirmation();
      _startSessionTicker();
    }
    notifyListeners();
  }

  void _onSpeechCompleted() {
    if (!_audioService.isPlaying) return;
    if (_isCurrentSpeechFinished) return;
    _isCurrentSpeechFinished = true;
    _watchdogTimer?.cancel();
    _gapTimer?.cancel();

    // Trigger implicit completion feedback (Fix for Gap 3)
    final completedAff = currentAffirmation;
    if (completedAff != null) {
      onAffirmationCompleted?.call(completedAff);
    }

    // Exactly 2 seconds silence gap before next affirmation
    _gapTimer = Timer(Duration(seconds: _gapBetweenAffirmations), () {
      if (!_audioService.isPlaying) return;
      _advanceToNextAffirmation();
    });
  }

  void _playCurrentAffirmation() {
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _isCurrentSpeechFinished = false;

    final aff = currentAffirmation;
    if (aff != null) {
      _audioService.speakAffirmation(aff.quote);

      // Generous fallback watchdog in case platform callback completely drops/crashes
      // At slow meditative pace (rate 0.48 / 0.88), speech is ~1.0-1.5 words per second.
      // We calculate a safe upper bound and add 20s buffer so watchdog never interrupts valid speech.
      final words = aff.quote.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final maxWaitSec = (words * 2.0).ceil().clamp(15, 90) + _gapBetweenAffirmations + 20;
      _watchdogTimer = Timer(Duration(seconds: maxWaitSec), () {
        if (_audioService.isPlaying && !_isCurrentSpeechFinished) {
          debugPrint("AudioProvider: Watchdog fallback triggered after ${maxWaitSec}s - initiating completion gap");
          _onSpeechCompleted();
        }
      });
    }
  }

  void _advanceToNextAffirmation() {
    if (_currentPlaylist == null) return;
    final totalAffs = _currentPlaylist!.affirmations.length;

    if (_currentAffirmationIndex < totalAffs - 1) {
      _currentAffirmationIndex++;

      // Smooth progression: update recorded start offset without jumping the current timeline
      if (_currentAffirmationIndex < _affirmationStartOffsets.length) {
        _affirmationStartOffsets[_currentAffirmationIndex] = _sessionPositionSeconds;
      }

      // Dynamically ensure total session duration has enough room for remaining affirmations
      final remainingEstimate = _calculateRemainingEstimatedSeconds();
      if (_sessionPositionSeconds + remainingEstimate > _sessionDurationSeconds) {
        _sessionDurationSeconds = _sessionPositionSeconds + remainingEstimate;
      }

      _playCurrentAffirmation();
    } else if (_isLoopEnabled) {
      _currentAffirmationIndex = 0;
      _sessionPositionSeconds = 0;
      _playCurrentAffirmation();
    } else {
      _audioService.stop();
      _sessionPositionSeconds = _sessionDurationSeconds;
      _gapTimer?.cancel();
      _watchdogTimer?.cancel();

      // Trigger session completion (Fix for Gap 8 - Streak & Listening Days)
      if (_currentPlaylist != null) {
        onSessionCompleted?.call(_currentPlaylist!);
      }
    }
    notifyListeners();
  }

  void _startSessionTicker() {
    _sessionTicker?.cancel();
    _sessionTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_audioService.isPlaying) return;

      // Expand total duration dynamically if speech + gap is running slightly longer
      // so the ticker never gets stuck before the playlist finishes
      if (_sessionPositionSeconds >= _sessionDurationSeconds - 1 &&
          _currentAffirmationIndex < (_currentPlaylist?.affirmations.length ?? 1) - 1) {
        _sessionDurationSeconds = _sessionPositionSeconds + 2;
      }

      if (_sessionPositionSeconds < _sessionDurationSeconds) {
        _sessionPositionSeconds++;
        notifyListeners();
      }
    });
  }

  void togglePlayPause() {
    if (_audioService.isPlaying) {
      pause();
    } else {
      if (_sessionPositionSeconds >= _sessionDurationSeconds) {
        _sessionPositionSeconds = 0;
        _currentAffirmationIndex = 0;
      }
      if (_isCurrentSpeechFinished && _currentAffirmationIndex < (_currentPlaylist?.affirmations.length ?? 1) - 1) {
        _advanceToNextAffirmation();
      } else {
        _playCurrentAffirmation();
      }
      _startSessionTicker();
      notifyListeners();
    }
  }

  void pause() {
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionTicker?.cancel();
    _audioService.pause();
    notifyListeners();
  }

  void stop() {
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionTicker?.cancel();
    _audioService.stop();
    notifyListeners();
  }

  void seekTo(int seconds) {
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionPositionSeconds = seconds.clamp(0, _sessionDurationSeconds);

    int targetIndex = 0;
    for (int i = _affirmationStartOffsets.length - 1; i >= 0; i--) {
      if (_sessionPositionSeconds >= _affirmationStartOffsets[i]) {
        targetIndex = i;
        break;
      }
    }

    final totalAffs = _currentPlaylist?.affirmations.length ?? 1;
    targetIndex = targetIndex.clamp(0, totalAffs - 1);

    if (targetIndex != _currentAffirmationIndex) {
      _currentAffirmationIndex = targetIndex;
      if (_audioService.isPlaying) {
        _playCurrentAffirmation();
      }
    }
    notifyListeners();
  }

  void nextAffirmation() {
    if (_currentPlaylist == null) return;
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();

    // Trigger negative skip signal ONLY if speech was still ongoing (early skip).
    // If speech already finished and we are just in the reflection gap, do NOT penalize!
    if (!_isCurrentSpeechFinished) {
      final skippedAff = currentAffirmation;
      if (skippedAff != null) {
        onAffirmationSkipped?.call(skippedAff);
      }
    }

    final totalAffs = _currentPlaylist!.affirmations.length;

    if (_currentAffirmationIndex < totalAffs - 1) {
      _currentAffirmationIndex++;
      final targetOffset = (_currentAffirmationIndex < _affirmationStartOffsets.length)
          ? _affirmationStartOffsets[_currentAffirmationIndex]
          : _sessionPositionSeconds;
      _sessionPositionSeconds = math.max(_sessionPositionSeconds, targetOffset);
      _playCurrentAffirmation();
    } else if (_isLoopEnabled) {
      _currentAffirmationIndex = 0;
      _sessionPositionSeconds = 0;
      _playCurrentAffirmation();
    } else {
      _audioService.stop();
      _sessionPositionSeconds = _sessionDurationSeconds;
    }
    notifyListeners();
  }

  void previousAffirmation() {
    if (_currentPlaylist == null) return;
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();

    if (_currentAffirmationIndex > 0) {
      _currentAffirmationIndex--;
      final targetOffset = (_currentAffirmationIndex < _affirmationStartOffsets.length)
          ? _affirmationStartOffsets[_currentAffirmationIndex]
          : 0;
      _sessionPositionSeconds = targetOffset;
      _playCurrentAffirmation();
    } else {
      _sessionPositionSeconds = 0;
      _playCurrentAffirmation();
    }
    notifyListeners();
  }

  void closePlayer() {
    _isPlayerOpen = false;
    _currentPlaylist = null;
    _currentAffirmationIndex = 0;
    _sessionPositionSeconds = 0;
    _gapBetweenAffirmations = defaultGapSeconds;
    _intervalPerAffirmation = 4 + defaultGapSeconds;
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionTicker?.cancel();
    _audioService.setAmbientSound(AmbientSound.none);
    _audioService.stop();
    notifyListeners();
  }

  void setVoiceVolume(double vol) {
    _audioService.setVoiceVolume(vol);
    notifyListeners();
  }

  void setVoiceSpeed(double speed) {
    _audioService.setVoiceSpeed(speed);
    _recalculateSessionTimeline();
    notifyListeners();
  }

  void setAmbientVolume(double vol) {
    _audioService.setAmbientVolume(vol);
    notifyListeners();
  }

  void setAmbientSound(AmbientSound sound) {
    _audioService.setAmbientSound(sound);
    notifyListeners();
  }

  void setGapBetweenAffirmations(int seconds) {
    _gapBetweenAffirmations = seconds.clamp(2, 8);
    _intervalPerAffirmation = 4 + _gapBetweenAffirmations;
    _recalculateSessionTimeline();
    notifyListeners();
  }

  void toggleLoop() {
    _isLoopEnabled = !_isLoopEnabled;
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = minutes * 60;

    if (minutes > 0) {
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_sleepTimerRemaining > 0) {
          _sleepTimerRemaining--;
          notifyListeners();
        } else {
          _sleepTimer?.cancel();
          _sleepTimer = null;
          closePlayer();
        }
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gapTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionTicker?.cancel();
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
