import 'affirmation.dart';
import 'user_archetype.dart';
import '../services/audio_engine_service.dart';

class Playlist {
  final String id;
  final String title;
  final String duration;
  final String category;
  final String imagePath;
  final bool isPremium;
  final List<Affirmation> affirmations;
  final AmbientSound defaultAmbientSound;
  final String? description;
  final List<UserArchetype>? targetArchetypes;
  final List<String>? targetSubLevels;
  final List<String>? tags;
  final String? archetypeId;
  final String? subtitle;

  Playlist({
    required this.id,
    required this.title,
    String? duration,
    String? estimatedDuration,
    String? totalDuration,
    String? durationText,
    String? durationString,
    String? category,
    String? imagePath,
    String? coverImageUrl,
    String? thumbnailUrl,
    this.isPremium = false,
    required this.affirmations,
    AmbientSound? defaultAmbientSound,
    AmbientSound? ambientSound,
    this.description,
    String? subtitle,
    List<UserArchetype>? targetArchetypes,
    List<UserArchetype>? primaryArchetypes,
    List<String>? targetSubLevels,
    List<String>? subLevels,
    this.tags,
    this.archetypeId,
  })  : duration = duration ?? estimatedDuration ?? totalDuration ?? durationText ?? durationString ?? '10 min',
        category = category ?? (tags != null && tags.isNotEmpty ? tags.first : 'Personal Growth'),
        imagePath = imagePath ?? coverImageUrl ?? thumbnailUrl ?? 'assets/images/featured_meditation.jpg',
        defaultAmbientSound = defaultAmbientSound ?? ambientSound ?? AmbientSound.solfeggio528,
        targetArchetypes = targetArchetypes ?? primaryArchetypes,
        targetSubLevels = targetSubLevels ?? subLevels,
        subtitle = subtitle ?? description;
}
