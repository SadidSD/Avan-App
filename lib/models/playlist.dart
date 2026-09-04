import 'dart:math' as math;
import 'affirmation.dart';
import 'user_archetype.dart';
import 'user_profile_vector.dart';
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
  double? _cachedCohesion;
  double? _cachedAverageBelievability;

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

    // Directional mean resultant length R in [0, 1] (spherical dispersion measure)
    double norm = 0.0;
    for (var val in avg) {
      norm += val * val;
    }
    norm = math.sqrt(norm);
    _cachedCohesion = norm.clamp(0.0, 1.0);

    // Normalize to unit length for standard cosine similarity
    if (norm == 0.0) {
      _cachedCentroid = avg;
    } else {
      _cachedCentroid = avg.map((v) => v / norm).toList();
    }

    return _cachedCentroid!;
  }

  /// Directional mean resultant length R in [0, 1] measuring internal thematic cohesion of affirmations.
  double get cohesionScore {
    if (_cachedCohesion != null) return _cachedCohesion!;
    final _ = centroidVector;
    return _cachedCohesion ?? 1.0;
  }

  /// Returns the mean believability score of all affirmations in this playlist.
  /// (Higher = gentle/grounding, lower = bold/aspirational).
  double get averageBelievabilityScore {
    if (_cachedAverageBelievability != null) return _cachedAverageBelievability!;
    if (affirmations.isEmpty) return 0.8;
    double sum = 0.0;
    for (final aff in affirmations) {
      sum += aff.believabilityScore;
    }
    _cachedAverageBelievability = sum / affirmations.length;
    return _cachedAverageBelievability!;
  }

  /// Returns the declared target archetypes, or dynamically aggregates distinct archetypes
  /// from all constituent affirmations to eliminate ranking metadata blind spots.
  List<UserArchetype> get effectiveTargetArchetypes {
    if (targetArchetypes != null && targetArchetypes!.isNotEmpty) {
      return targetArchetypes!;
    }
    final Set<UserArchetype> derived = {};
    for (final aff in affirmations) {
      derived.addAll(aff.primaryArchetypes);
    }
    return derived.toList();
  }

  /// Returns the declared target sub-levels, or dynamically aggregates distinct sub-levels
  /// from all constituent affirmations.
  List<String> get effectiveTargetSubLevels {
    if (targetSubLevels != null && targetSubLevels!.isNotEmpty) {
      return targetSubLevels!;
    }
    final Set<String> derived = {};
    for (final aff in affirmations) {
      derived.addAll(aff.subLevels);
    }
    return derived.toList();
  }

  /// Returns a dynamically adapted copy of this playlist sequenced specifically
  /// for the active user's current habituation state and ZPD therapeutic arc.
  Playlist adaptForUser({
    required UserProfileVector profile,
    Map<String, int>? lastListenedTimestamps,
    bool isGrowthMode = true,
    DateTime? now,
  }) {
    if (affirmations.length <= 2) return this;

    final currentTime = now ?? DateTime.now();

    // 1. Calculate each affirmation's habituation freshness H in [0.20, 1.0]
    final scoredAffirmations = affirmations.map((aff) {
      final lastHeard = lastListenedTimestamps?[aff.id];
      double habituation = 1.0;
      if (lastHeard != null && lastHeard > 0) {
        final elapsedMs = currentTime.millisecondsSinceEpoch - lastHeard;
        if (elapsedMs > 0) {
          final elapsedHours = elapsedMs / (3600.0 * 1000.0);
          final decay = math.exp(-elapsedHours / 40.0);
          habituation = (1.0 - 0.80 * decay).clamp(0.20, 1.0);
        }
      }

      return (
        affirmation: aff,
        habituation: habituation,
        believability: aff.believabilityScore,
      );
    }).toList();

    // 2. Split into fresh vs recently heard (stale) affirmations
    // Affirmations with H >= 0.50 are fresh. Stale ones (H < 0.50) are moved toward the end.
    final fresh = scoredAffirmations.where((s) => s.habituation >= 0.50).toList();
    final stale = scoredAffirmations.where((s) => s.habituation < 0.50).toList();

    // 3. Sort fresh affirmations into a clinical therapeutic arc:
    // Grounding (high believability >= 0.85) -> Reframing -> High Agency / Action
    fresh.sort((a, b) => b.believability.compareTo(a.believability));
    stale.sort((a, b) => b.believability.compareTo(a.believability));

    final reordered = [
      ...fresh.map((s) => s.affirmation),
      ...stale.map((s) => s.affirmation),
    ];

    return Playlist(
      id: id,
      title: title,
      duration: duration,
      category: category,
      imagePath: imagePath,
      isPremium: isPremium,
      defaultAmbientSound: defaultAmbientSound,
      description: description,
      subtitle: subtitle,
      targetArchetypes: targetArchetypes,
      targetSubLevels: targetSubLevels,
      tags: tags,
      archetypeId: archetypeId,
      affirmations: reordered,
    );
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
