import 'dart:math' as math;
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

  List<double>? _cachedCentroid;

  /// Returns the normalized 16-dimensional centroid vector representing the semantic center
  /// of all affirmations in this playlist.
  List<double> get centroidVector {
    if (_cachedCentroid != null) return _cachedCentroid!;
    if (affirmations.isEmpty) return const [];

    int dim = 0;
    for (final aff in affirmations) {
      if (aff.embeddingVector.isNotEmpty) {
        dim = aff.embeddingVector.length;
        break;
      }
    }
    if (dim == 0) return const [];

    final sum = List<double>.filled(dim, 0.0);
    int count = 0;
    for (final aff in affirmations) {
      if (aff.embeddingVector.length == dim) {
        for (int i = 0; i < dim; i++) {
          sum[i] += aff.embeddingVector[i];
        }
        count++;
      }
    }
    if (count == 0) return const [];

    // Average vector
    final avg = sum.map((v) => v / count).toList();

    // Normalize to unit length for standard cosine similarity
    double norm = 0.0;
    for (var val in avg) {
      norm += val * val;
    }
    norm = math.sqrt(norm);
    if (norm == 0.0) {
      _cachedCentroid = avg;
    } else {
      _cachedCentroid = avg.map((v) => v / norm).toList();
    }

    return _cachedCentroid!;
  }

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
