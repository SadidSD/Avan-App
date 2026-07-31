import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../models/user_recording.dart';

class MyVoiceTab extends StatefulWidget {
  const MyVoiceTab({Key? key}) : super(key: key);

  @override
  State<MyVoiceTab> createState() => _MyVoiceTabState();
}

class _MyVoiceTabState extends State<MyVoiceTab> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  
  String _filter = 'All'; // 'All', 'Favorites', 'Recent'

  String? _currentlyPlayingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _currentlyPlayingId = null;
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: '');
        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    _timer?.cancel();
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    setState(() => _isPaused = false);
    _startTimer();
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });

    if (path != null) {
      _showSaveDialog(path, _recordDuration);
    }
  }
  
  void _showSaveDialog(String path, int durationSeconds) {
    final controller = TextEditingController(text: 'My Affirmation');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Save Recording', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Recording Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Discard', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final newRecording = UserRecording(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: controller.text.trim().isEmpty ? 'Untitled' : controller.text.trim(),
                  durationSeconds: durationSeconds,
                  date: DateTime.now(),
                  audioPath: path,
                );
                context.read<AppProvider>().addUserRecording(newRecording);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _playPause(UserRecording rec) async {
    final audioProvider = context.read<AudioProvider>();
    if (_currentlyPlayingId == rec.id && _isPlaying) {
      await _audioPlayer.pause();
    } else {
      audioProvider.openCustomAudio(
        title: rec.title,
        quote: 'Personal Voice Studio Recording • ${_formatDuration(rec.durationSeconds)}',
        duration: '${rec.durationSeconds}s',
      );
      try {
        await _audioPlayer.play(kIsWeb ? UrlSource(rec.audioPath) : DeviceFileSource(rec.audioPath));
      } catch (e) {
        debugPrint('Playing simulated audio for web demo: $e');
      }
      setState(() {
        _currentlyPlayingId = rec.id;
      });
    }
  }

  void _renameDialog(UserRecording rec) {
    final controller = TextEditingController(text: rec.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Rename', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().renameUserRecording(rec.id, controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    List<UserRecording> displayList = List.from(provider.userRecordings);
    
    if (_filter == 'Favorites') {
      displayList.retainWhere((e) => e.isFavorite);
    } else if (_filter == 'Recent') {
      displayList.sort((a, b) => b.date.compareTo(a.date));
      if (displayList.length > 5) displayList = displayList.sublist(0, 5);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Voice Studio',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Recording Section
              CustomCard(
                backgroundColor: AppColors.softBeige,
                child: Column(
                  children: [
                    Text(
                      _isRecording ? 'Recording...' : 'Record Your Voice',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_recordDuration),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.buttonDark),
                    ),
                    const SizedBox(height: 16),
                    if (_isRecording)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 48,
                            icon: Icon(_isPaused ? Icons.play_circle_fill_rounded : Icons.pause_circle_filled_rounded, color: AppColors.tanAccent),
                            onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                            onPressed: _stopRecording,
                          ),
                        ],
                      )
                    else
                      IconButton(
                        iconSize: 64,
                        icon: const Icon(Icons.mic_rounded, color: AppColors.buttonDark),
                        onPressed: _startRecording,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Favorites', 'Recent'].map((f) {
                    final isSelected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _filter = f),
                        selectedColor: AppColors.buttonDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.softBeige,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Recordings List
              Expanded(
                child: displayList.isEmpty
                    ? const Center(child: Text('No recordings yet.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final rec = displayList[index];
                          final isThisPlaying = _currentlyPlayingId == rec.id && _isPlaying;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: CustomCard(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isThisPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      color: AppColors.buttonDark,
                                    ),
                                    iconSize: 36,
                                    onPressed: () => _playPause(rec),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(rec.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${DateFormat('MMM d, yyyy').format(rec.date)} • ${_formatDuration(rec.durationSeconds)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      rec.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: rec.isFavorite ? Colors.redAccent : AppColors.tanAccent,
                                    ),
                                    onPressed: () => provider.toggleFavoriteRecording(rec.id),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.tanAccent),
                                    onSelected: (val) {
                                      if (val == 'rename') {
                                        _renameDialog(rec);
                                      } else if (val == 'delete') {
                                        provider.deleteUserRecording(rec.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'rename', child: Text('Rename')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
