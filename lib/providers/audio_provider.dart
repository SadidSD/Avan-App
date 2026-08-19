import 'dart:async';
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

  int _sessionDurationSeconds = 480; // Full playlist length in seconds (default 8 min)
  int _sessionPositionSeconds = 0;   // Current elapsed seconds in the playlist
  bool _isLoopEnabled = false;

  Timer? _sessionTicker;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0; // seconds

  AudioProvider();

  bool get isPlaying => _audioService.isPlaying;
  double get voiceVolume => _audioService.voiceVolume;
  double get voiceSpeed => _audioService.voiceSpeed;
  double get ambientVolume => _audioService.ambientVolume;
  AmbientSound get currentSound => _audioService.currentSound;

  int get positionSeconds => _sessionPositionSeconds;
  int get durationSeconds => _sessionDurationSeconds;
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

  double get _slotDurationSeconds {
    if (_currentPlaylist == null || _currentPlaylist!.affirmations.isEmpty) {
      return 60.0;
    }
    return _sessionDurationSeconds / _currentPlaylist!.affirmations.length;
  }

  int _parseDurationToSeconds(String durationStr) {
    final clean = durationStr.toLowerCase().trim();
    if (clean.contains('min')) {
      final numStr = RegExp(r'\d+').firstMatch(clean)?.group(0);
      if (numStr != null) {
        return int.parse(numStr) * 60;
      }
    } else if (clean.contains('sec')) {
      final numStr = RegExp(r'\d+').firstMatch(clean)?.group(0);
      if (numStr != null) {
        return int.parse(numStr);
      }
    }
    return 480; // default 8 min
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

    // Fallback filler if needed
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
      duration: '${relatedQuotes.length} min', // 1 min per affirmation line
      category: affirmation.category.isNotEmpty ? affirmation.category : 'Personalized',
      imagePath: parentPlaylist?.imagePath ?? 'assets/images/featured_meditation.jpg',
      isPremium: false,
      affirmations: relatedQuotes,
    );

    openPlaylist(dynamicPlaylist, context, 0);
  }

  /// Opens a playlist at a specific affirmation index and opens the Player Screen
  void openPlaylist(Playlist playlist, [BuildContext? context, int initialIndex = 0]) {
    _currentPlaylist = playlist;
    _sessionDurationSeconds = _parseDurationToSeconds(playlist.duration);
    _currentAffirmationIndex = (initialIndex >= 0 && initialIndex < playlist.affirmations.length)
        ? initialIndex
        : 0;
    _sessionPositionSeconds = (_currentAffirmationIndex * _slotDurationSeconds).round();
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

  void openCustomAudio({required String title, required String quote, String duration = '1 min'}) {
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
      affirmations: [customAffirmation],
    );
    _currentAffirmationIndex = 0;
    _sessionDurationSeconds = _parseDurationToSeconds(duration);
    _sessionPositionSeconds = 0;
    _isPlayerOpen = true;

    _playCurrentAffirmation();
    _startSessionTicker();
    notifyListeners();
  }

  void _playCurrentAffirmation() {
    final aff = currentAffirmation;
    if (aff != null) {
      _audioService.speakAffirmation(aff.quote);
    }
  }

  void _startSessionTicker() {
    _sessionTicker?.cancel();
    _sessionTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_audioService.isPlaying) return;

      if (_sessionPositionSeconds < _sessionDurationSeconds) {
        _sessionPositionSeconds++;

        final totalAffs = _currentPlaylist?.affirmations.length ?? 1;
        final slot = _slotDurationSeconds;
        final targetIndex = (_sessionPositionSeconds / slot).floor().clamp(0, totalAffs - 1);

        if (targetIndex != _currentAffirmationIndex) {
          _currentAffirmationIndex = targetIndex;
          _playCurrentAffirmation();
        }

        notifyListeners();
      } else {
        if (_isLoopEnabled) {
          _sessionPositionSeconds = 0;
          _currentAffirmationIndex = 0;
          _playCurrentAffirmation();
          notifyListeners();
        } else {
          _audioService.stop();
          _sessionTicker?.cancel();
          notifyListeners();
        }
      }
    });
  }

  void togglePlayPause() {
    if (_audioService.isPlaying) {
      _audioService.pause();
    } else {
      if (_sessionPositionSeconds >= _sessionDurationSeconds) {
        _sessionPositionSeconds = 0;
        _currentAffirmationIndex = 0;
      }
      _playCurrentAffirmation();
      _startSessionTicker();
    }
    notifyListeners();
  }

  void seekTo(int seconds) {
    _sessionPositionSeconds = seconds.clamp(0, _sessionDurationSeconds);
    final totalAffs = _currentPlaylist?.affirmations.length ?? 1;
    final slot = _slotDurationSeconds;
    final targetIndex = (_sessionPositionSeconds / slot).floor().clamp(0, totalAffs - 1);

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
    final totalAffs = _currentPlaylist!.affirmations.length;

    if (_currentAffirmationIndex < totalAffs - 1) {
      _currentAffirmationIndex++;
      _sessionPositionSeconds = (_currentAffirmationIndex * _slotDurationSeconds).round();
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

    if (_currentAffirmationIndex > 0) {
      _currentAffirmationIndex--;
      _sessionPositionSeconds = (_currentAffirmationIndex * _slotDurationSeconds).round();
      _playCurrentAffirmation();
    } else {
      _sessionPositionSeconds = 0;
      _playCurrentAffirmation();
    }
    notifyListeners();
  }

  void closePlayer() {
    _isPlayerOpen = false;
    _sessionTicker?.cancel();
    _audioService.stop();
    notifyListeners();
  }

  void setVoiceVolume(double vol) {
    _audioService.setVoiceVolume(vol);
    notifyListeners();
  }

  void setVoiceSpeed(double speed) {
    _audioService.setVoiceSpeed(speed);
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
    _sessionTicker?.cancel();
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
