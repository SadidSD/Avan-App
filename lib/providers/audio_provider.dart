import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/affirmation.dart';
import '../models/playlist.dart';
import '../services/audio_engine_service.dart';
import '../data/playlists_data.dart';
import '../screens/player/player_screen.dart';

class AudioProvider with ChangeNotifier {
  final AudioEngineService _audioService = AudioEngineService();

  List<Playlist> get playlists => allPlaylists;

  Playlist? _currentPlaylist;
  int _currentAffirmationIndex = 0;
  bool _isPlayerOpen = false;

  AudioProvider() {
    // Set up engine callbacks
    _audioService.onComplete = () {
      if (_currentPlaylist == null) return;
      if (_currentAffirmationIndex < _currentPlaylist!.affirmations.length - 1) {
        nextAffirmation();
      } else {
        if (_audioService.isLoopEnabled) {
          _currentAffirmationIndex = 0;
          _playCurrentAffirmation();
        } else {
          // Finished playlist
          notifyListeners();
        }
      }
    };

    _audioService.onProgress = (position) {
      notifyListeners();
    };

    _audioService.onSleepTimerTick = (remaining) {
      notifyListeners();
    };
    
    _audioService.onSleepTimerComplete = () {
      notifyListeners();
    };
  }

  bool get isPlaying => _audioService.isPlaying;
  double get voiceVolume => _audioService.voiceVolume;
  double get voiceSpeed => _audioService.voiceSpeed;
  double get ambientVolume => _audioService.ambientVolume;
  AmbientSound get currentSound => _audioService.currentSound;
  int get positionSeconds => _audioService.positionSeconds;
  int get durationSeconds => _audioService.durationSeconds;
  bool get isLoopEnabled => _audioService.isLoopEnabled;
  int get sleepTimerRemaining => _audioService.sleepTimerRemaining;

  Playlist? get currentPlaylist => _currentPlaylist;
  
  Affirmation? get currentAffirmation {
    if (_currentPlaylist == null) return null;
    if (_currentPlaylist!.affirmations.isEmpty) return null;
    return _currentPlaylist!.affirmations[_currentAffirmationIndex];
  }

  int get currentAffirmationIndex => _currentAffirmationIndex;
  bool get isPlayerOpen => _isPlayerOpen;

  void togglePlayPause() {
    if (_audioService.isPlaying) {
      _audioService.pause();
    } else {
      if (currentAffirmation != null && _audioService.positionSeconds == 0) {
        _playCurrentAffirmation();
      } else if (currentAffirmation != null) {
         // resume not properly supported by flutter_tts in all cases, so restart the affirmation
         _playCurrentAffirmation();
      }
    }
    notifyListeners();
  }

  void openPlaylist(Playlist playlist, [BuildContext? context]) {
    _currentPlaylist = playlist;
    _currentAffirmationIndex = 0;
    _isPlayerOpen = true;
    _playCurrentAffirmation();
    notifyListeners();

    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    }
  }

  void playSingleQuote(String quote, {String title = 'Daily Affirmation'}) {
    openCustomAudio(title: title, quote: quote);
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
    _isPlayerOpen = true;
    _playCurrentAffirmation();
    notifyListeners();
  }

  void _playCurrentAffirmation() {
    final affirmation = currentAffirmation;
    if (affirmation != null) {
      _audioService.play(affirmation.quote);
    }
  }

  void closePlayer() {
    _isPlayerOpen = false;
    _audioService.stop();
    notifyListeners();
  }

  void nextAffirmation() {
    if (_currentPlaylist == null) return;
    if (_currentAffirmationIndex < _currentPlaylist!.affirmations.length - 1) {
      _currentAffirmationIndex++;
      _playCurrentAffirmation();
    } else if (isLoopEnabled) {
      _currentAffirmationIndex = 0;
      _playCurrentAffirmation();
    } else {
      _audioService.stop();
    }
    notifyListeners();
  }

  void previousAffirmation() {
    if (_currentPlaylist == null) return;
    if (_currentAffirmationIndex > 0) {
      _currentAffirmationIndex--;
      _playCurrentAffirmation();
    } else {
      // If at start, either loop to end or stay at start
      if (isLoopEnabled) {
        _currentAffirmationIndex = _currentPlaylist!.affirmations.length - 1;
        _playCurrentAffirmation();
      } else {
        _currentAffirmationIndex = 0;
        _playCurrentAffirmation();
      }
    }
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
    _audioService.toggleLoop();
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _audioService.startSleepTimer(minutes);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
