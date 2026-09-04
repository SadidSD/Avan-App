import 'dart:math' as math;
import '../models/affirmation.dart';
import '../models/user_archetype.dart';
import '../models/user_profile_vector.dart';
import '../models/playlist.dart';

class PlaylistMatch {
  final Playlist playlist;
  final double matchScore; // 0.0 - 1.0
  final String matchPercent; // e.g. '98%'
  final String resonanceReason;

  const PlaylistMatch({
    required this.playlist,
    required this.matchScore,
    required this.matchPercent,
    required this.resonanceReason,
  });
}

class PersonalizationEngine {
  static const int vectorDimensions = 16;

  /// Calculates cosine similarity between two 16-dimensional continuous vectors.
  /// Result is between -1.0 and 1.0 (clamped to [0.0, 1.0] for similarity).
  static double cosineSimilarity(List<double> v1, List<double> v2) {
    if (v1.isEmpty || v2.isEmpty || v1.length != v2.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normA += v1[i] * v1[i];
      normB += v2[i] * v2[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;
    final similarity = dotProduct / (math.sqrt(normA) * math.sqrt(normB));
    return similarity.clamp(0.0, 1.0);
  }

  /// Synthesizes a 16-dimensional user vector from primary & secondary archetypes + sub-levels.
  /// Uses independent archetype normalization and 75/25 convex combination to prevent
  /// cross-archetype constructive interference / dilution.
  static List<double> buildArchetypeBaseVector({
    required List<UserArchetype> primary,
    required List<UserArchetype> secondary,
    required List<String> subLevels,
    required AffirmationTone tone,
  }) {
    List<double> vec = List.filled(vectorDimensions, 0.005); // Minimal ambient noise (eliminates orthogonal drag)

    // 1. Primary archetypes (normalized independently to guarantee primary dominance)
    List<double> primaryVec = List.filled(vectorDimensions, 0.0);
    for (var a in primary) {
      _addArchetypeWeightTo(primaryVec, a, 1.0);
    }
    if (primary.isNotEmpty) {
      primaryVec = _normalize(primaryVec);
    }

    // 2. Secondary archetypes (normalized independently)
    List<double> secondaryVec = List.filled(vectorDimensions, 0.0);
    for (var a in secondary) {
      _addArchetypeWeightTo(secondaryVec, a, 1.0);
    }
    if (secondary.isNotEmpty) {
      secondaryVec = _normalize(secondaryVec);
    }

    // Convex combination: 75% primary dominance, 25% secondary (or 100% primary if no secondary)
    for (int i = 0; i < vectorDimensions; i++) {
      if (secondary.isNotEmpty) {
        vec[i] += 0.75 * primaryVec[i] + 0.25 * secondaryVec[i];
      } else {
        vec[i] += primaryVec[i];
      }
    }

    // 3. Sub-level adjustments across all 33+ archetype situations (case-insensitive & robust)
    for (var rawSub in subLevels) {
      final sub = rawSub.toLowerCase();
      // Career
      if (sub.contains('founder') || sub.contains('solopreneur')) { vec[0] += 0.40; vec[6] += 0.35; vec[14] += 0.30; }
      if (sub.contains('corporate') || sub.contains('leader') || sub.contains('executive')) { vec[6] += 0.35; vec[0] += 0.25; }
      if (sub.contains('contributor') || sub.contains('climber')) { vec[0] += 0.35; vec[7] += 0.25; }
      if (sub.contains('sales') || sub.contains('client')) { vec[7] += 0.35; vec[14] += 0.30; vec[0] += 0.20; }

      // Anxiety
      if (sub.contains('panic') || sub.contains('tension')) { vec[1] += 0.40; vec[13] += 0.35; }
      if (sub.contains('social') || sub.contains('performance anxiety')) { vec[1] += 0.35; vec[7] += 0.30; }
      if (sub.contains('bedtime') || sub.contains('rumination')) { vec[13] += 0.40; vec[15] += 0.35; }

      // Heartbreak
      if (sub.contains('shock') || sub.contains('fresh breakup')) { vec[2] += 0.40; vec[13] += 0.35; vec[15] += 0.30; }
      if (sub.contains('yearning') || sub.contains('no-contact')) { vec[2] += 0.35; vec[3] += 0.25; vec[13] += 0.30; }
      if (sub.contains('rediscovery') || sub.contains('self-worth')) { vec[7] += 0.40; vec[14] += 0.30; }
      if (sub.contains('divorce') || sub.contains('separation')) { vec[2] += 0.35; vec[7] += 0.30; }

      // Grief
      if (sub.contains('parent') || sub.contains('sibling')) { vec[3] += 0.40; vec[13] += 0.35; }
      if (sub.contains('partner') || sub.contains('spouse')) { vec[3] += 0.40; vec[2] += 0.25; vec[13] += 0.35; }
      if (sub.contains('young adult')) { vec[3] += 0.35; vec[7] += 0.30; }
      if (sub.contains('anticipatory') || sub.contains('illness')) { vec[3] += 0.35; vec[1] += 0.25; vec[13] += 0.35; }

      // Self-Improvement
      if (sub.contains('consistency') || sub.contains('daily habit')) { vec[4] += 0.45; vec[14] += 0.35; }
      if (sub.contains('deep work') || sub.contains('focus optimizer')) { vec[4] += 0.35; vec[14] += 0.40; vec[0] += 0.20; }
      if (sub.contains('stoic') || sub.contains('philosophy')) { vec[13] += 0.35; vec[15] += 0.35; }

      // Spiritual
      if (sub.contains('attraction') || sub.contains('abundance')) { vec[5] += 0.40; vec[14] += 0.30; }
      if (sub.contains('intuition') || sub.contains('inner wisdom')) { vec[5] += 0.40; vec[13] += 0.35; }
      if (sub.contains('gratitude') || sub.contains('alignment')) { vec[5] += 0.35; vec[13] += 0.35; }

      // Parenting
      if (sub.contains('newborn') || sub.contains('toddler')) { vec[8] += 0.40; vec[13] += 0.35; }
      if (sub.contains('school-age') || sub.contains('teen')) { vec[8] += 0.40; vec[1] += 0.25; }
      if (sub.contains('caregiver') || sub.contains('elder')) { vec[8] += 0.40; vec[13] += 0.35; }

      // Athlete
      if (sub.contains('endurance') || sub.contains('running') || sub.contains('fitness')) { vec[9] += 0.40; vec[4] += 0.30; }
      if (sub.contains('prep') || sub.contains('clutch mindset')) { vec[9] += 0.40; vec[7] += 0.35; vec[14] += 0.35; }
      if (sub.contains('injury') || sub.contains('mental reset')) { vec[9] += 0.35; vec[13] += 0.35; vec[15] += 0.30; }

      // Accessible / IDD
      if (sub.contains('sensory') || sub.contains('calming')) { vec[10] += 0.40; vec[13] += 0.35; }
      if (sub.contains('pride') || sub.contains('capability')) { vec[10] += 0.35; vec[7] += 0.40; }
      if (sub.contains('belonging') || sub.contains('friendship')) { vec[10] += 0.35; vec[15] += 0.35; }

      // Student
      if (sub.contains('exam')) { vec[11] += 0.40; vec[1] += 0.30; }
      if (sub.contains('grad') || sub.contains('medical') || sub.contains('professional exam')) { vec[11] += 0.40; vec[0] += 0.30; }
      if (sub.contains('procrastination') || sub.contains('study motivation')) { vec[11] += 0.35; vec[14] += 0.35; }

      // LGBTQIA+
      if (sub.contains('authenticity') || sub.contains('coming out')) { vec[12] += 0.40; vec[7] += 0.35; }
      if (sub.contains('challenging spaces')) { vec[12] += 0.35; vec[13] += 0.35; }
      if (sub.contains('trans') || sub.contains('non-binary')) { vec[12] += 0.45; vec[7] += 0.35; }
    }

    // 4. Tone modifier
    if (tone == AffirmationTone.gentleAndGrounding) {
      vec[13] += 0.3; // Boost somatic calm
      vec[15] += 0.2; // Boost believability
    } else if (tone == AffirmationTone.directAndActionable || tone == AffirmationTone.empowering) {
      vec[14] += 0.3; // Boost action/fire
    } else if (tone == AffirmationTone.philosophical) {
      vec[4] += 0.35; // Boost stoic self-mastery & discipline
      vec[5] += 0.30; // Boost spiritual & philosophical wisdom
      vec[13] += 0.25; // Boost inner calm & equanimity
    } else if (tone == AffirmationTone.simpleAndClear) {
      vec[10] += 0.4; // Boost simplicity
      vec[15] += 0.3;
    }

    // 5. Normalize vector
    return _normalize(vec);
  }

  static void _addArchetypeWeightTo(List<double> vec, UserArchetype type, double weight) {
    switch (type) {
      case UserArchetype.careerProfessional:
        vec[0] += 1.15 * weight; // Career
        vec[6] += 0.65 * weight; // Leadership
        vec[7] += 0.70 * weight; // Confidence
        vec[14] += 0.70 * weight; // Action
        break;
      case UserArchetype.anxiousOverthinker:
        vec[1] += 0.95 * weight; // Anxiety
        vec[13] += 0.90 * weight; // Somatic calm
        vec[15] += 0.90 * weight; // High believability
        break;
      case UserArchetype.heartbreakSurvivor:
        vec[2] += 0.95 * weight; // Heartbreak
        vec[7] += 0.75 * weight; // Self-esteem
        vec[13] += 0.80 * weight; // Healing
        vec[15] += 0.85 * weight;
        break;
      case UserArchetype.grievingIndividual:
        vec[3] += 0.98 * weight; // Grief
        vec[13] += 0.95 * weight; // Somatic calm
        vec[15] += 0.95 * weight; // Believability
        break;
      case UserArchetype.selfImprovement:
        vec[4] += 1.05 * weight; // Self-mastery
        vec[7] += 0.70 * weight; // Confidence
        vec[14] += 0.80 * weight; // Action
        break;
      case UserArchetype.spiritualSeeker:
        vec[5] += 0.98 * weight; // Spiritual
        vec[13] += 0.70 * weight;
        vec[14] += 0.60 * weight;
        break;
      case UserArchetype.parentCaregiver:
        vec[8] += 0.95 * weight; // Caregiving
        vec[1] += 0.50 * weight; // Stress
        vec[13] += 0.85 * weight; // Calm
        break;
      case UserArchetype.athlete:
        vec[9] += 0.95 * weight; // Athletic
        vec[4] += 0.70 * weight; // Habits
        vec[14] += 0.95 * weight; // Action
        break;
      case UserArchetype.personWithIDD:
        vec[10] += 0.99 * weight; // IDD simplicity
        vec[7] += 0.85 * weight; // Pride
        vec[13] += 0.90 * weight; // Sensory calm
        vec[15] += 1.00 * weight; // 100% concrete believability
        break;
      case UserArchetype.student:
        vec[11] += 0.95 * weight; // Academic
        vec[0] += 0.40 * weight; // Career
        vec[1] += 0.50 * weight; // Exam anxiety
        vec[14] += 0.70 * weight;
        break;
      case UserArchetype.lgbtqia:
        vec[12] += 0.98 * weight; // LGBTQIA+
        vec[7] += 0.90 * weight; // Pride & self-worth
        vec[13] += 0.70 * weight;
        break;
    }
  }

  /// Online dynamic EMA update for a raw continuous vector.
  static List<double> updateVectorWithInteraction({
    required List<double> currentVector,
    required List<double> affirmationVector,
    double learningRate = 0.15,
  }) {
    if (currentVector.length != vectorDimensions ||
        affirmationVector.length != vectorDimensions) {
      return currentVector;
    }

    List<double> updated = List.filled(vectorDimensions, 0.0);
    for (int i = 0; i < vectorDimensions; i++) {
      updated[i] = (1.0 - learningRate) * currentVector[i] +
          learningRate * affirmationVector[i];
    }
    return _normalize(updated);
  }

  /// Anchored dual-vector online interaction update (Fix for Flaw 2 - Catastrophic Profile Drift).
  /// Updates dynamic [stateVector] via EMA while preserving immutable [baselineVector].
  /// Blends 70% permanent trait anchor with 30% dynamic state to prevent catastrophic forgetting.
  static UserProfileVector updateProfileWithInteraction({
    required UserProfileVector profile,
    required List<double> affirmationVector,
    double learningRate = 0.15,
  }) {
    if (affirmationVector.length != vectorDimensions) {
      return profile;
    }

    final currentState = profile.stateVector.isNotEmpty
        ? profile.stateVector
        : (profile.vector.isNotEmpty ? profile.vector : List.filled(vectorDimensions, 0.0));

    final updatedState = updateVectorWithInteraction(
      currentVector: currentState,
      affirmationVector: affirmationVector,
      learningRate: learningRate,
    );

    final updatedProfile = profile.copyWith(
      stateVector: updatedState,
      interactionCount: profile.interactionCount + 1,
      lastUpdated: DateTime.now(),
    );

    // Keep active vector in sync with effectiveVector (70/30 trait-state blend)
    return updatedProfile.copyWith(
      vector: updatedProfile.effectiveVector,
    );
  }

  /// Negative gradient step when a user rapidly skips an affirmation (Fix for Gap 3).
  /// Gently nudges the dynamic state vector away from the skipped affirmation without destabilizing the anchor.
  static UserProfileVector penalizeSkippedAffirmation({
    required UserProfileVector profile,
    required List<double> affirmationVector,
    double penaltyRate = 0.03,
  }) {
    if (affirmationVector.length != vectorDimensions) return profile;

    final currentState = profile.stateVector.isNotEmpty
        ? profile.stateVector
        : (profile.vector.isNotEmpty ? profile.vector : List.filled(vectorDimensions, 0.0));

    final List<double> updated = List.filled(vectorDimensions, 0.0);
    for (int i = 0; i < vectorDimensions; i++) {
      updated[i] = currentState[i] - penaltyRate * affirmationVector[i];
      if (updated[i] < 0.0) updated[i] = 0.0;
    }

    final normalizedState = _normalize(updated);
    final updatedProfile = profile.copyWith(
      stateVector: normalizedState,
      lastUpdated: DateTime.now(),
    );

    return updatedProfile.copyWith(
      vector: updatedProfile.effectiveVector,
    );
  }

  /// Computes the Ebbinghaus spaced habituation multiplier H(a, delta_t) in [0.20, 1.0].
  /// Prevents semantic fatigue / desensitization by penalizing recently heard affirmations
  /// and recovering full neural potency over a characteristic half-life tau = 40 hours.
  static double computeHabituationMultiplier({
    required int? lastListenedEpochMs,
    required DateTime now,
    double minMultiplier = 0.20,
    double recoveryHours = 40.0,
  }) {
    if (lastListenedEpochMs == null || lastListenedEpochMs <= 0) return 1.0;

    final elapsedMs = now.millisecondsSinceEpoch - lastListenedEpochMs;
    if (elapsedMs <= 0) return minMultiplier;

    final elapsedHours = elapsedMs / (3600.0 * 1000.0);
    // H(t) = 1.0 - (1.0 - minMultiplier) * exp(-elapsedHours / recoveryHours)
    final decay = math.exp(-elapsedHours / recoveryHours);
    final multiplier = 1.0 - (1.0 - minMultiplier) * decay;
    return multiplier.clamp(minMultiplier, 1.0);
  }

  /// Generates a personalized ranked queue of affirmations using multi-vector similarity,
  /// mode biasing, mood modulation, dynamic ZPD believability gating, and Ebbinghaus habituation decay.
  static List<Affirmation> getPersonalizedFeed({
    required UserProfileVector profile,
    required List<Affirmation> pool,
    required bool isGrowthMode,
    String? mood,
    int limit = 10,
    List<String> excludeIds = const [],
    Map<String, int>? lastListenedTimestamps,
  }) {
    final userVec = (profile.effectiveVector.isNotEmpty && profile.effectiveVector.any((v) => v != 0.0))
        ? profile.effectiveVector
        : ((profile.vector.isNotEmpty && profile.vector.any((v) => v != 0.0))
            ? profile.vector
            : buildArchetypeBaseVector(
                primary: profile.primaryArchetypes,
                secondary: profile.secondaryArchetypes,
                subLevels: profile.selectedSubLevels,
                tone: profile.preferredTone,
              ));

    final bool isIDDUser = profile.primaryArchetypes.contains(UserArchetype.personWithIDD);

    // Score each candidate affirmation
    List<Map<String, dynamic>> scored = [];
    final now = DateTime.now();

    for (var aff in pool) {
      if (excludeIds.contains(aff.id)) continue;

      // IDD safety filter: if user requested sensory/simple direct, prioritize accessible affirmations
      if (isIDDUser && aff.tone != AffirmationTone.simpleAndClear && aff.modality != TherapeuticModality.accessibleDirect) {
        // deprioritize complex philosophical affirmations
        continue;
      }

      // Base Cosine Similarity
      double sim = cosineSimilarity(userVec, aff.embeddingVector);

      // Dynamic ZPD Believability Penalty Gating (Zone of Proximal Development)
      // Uses effectiveBelievabilityPreference which scales as the user builds listening mastery
      final double userBelievabilityNeed = profile.effectiveBelievabilityPreference;
      final double deltaBelievability = math.max(0.0, userBelievabilityNeed - aff.believabilityScore);
      final double believabilityGate = math.exp(-3.0 * deltaBelievability * deltaBelievability);

      // Contextual Boost: App Mode (Growth vs. Healing)
      double modeBoost = 1.0;
      if (isGrowthMode) {
        // Growth mode boosts Action [14] and Ambition [0]
        if (aff.embeddingVector.length > 14 && aff.embeddingVector[14] > 0.6) {
          modeBoost = 1.25;
        }
      } else {
        // Healing mode boosts Somatic Calm [13], Anxiety Grounding [1], Heartbreak [2], Grief [3]
        if (aff.embeddingVector.length > 13 && aff.embeddingVector[13] > 0.6) {
          modeBoost = 1.25;
        }
      }

      // Contextual Boost: Selected Mood
      double moodBoost = 1.0;
      if (mood != null && mood.isNotEmpty) {
        final lowerMood = mood.toLowerCase();
        if (lowerMood.contains('anxious') && aff.tags.contains('grounding')) moodBoost = 1.30;
        if (lowerMood.contains('sad') && (aff.category == 'Self Love' || aff.category == 'Calm Mind')) moodBoost = 1.30;
        if (lowerMood.contains('motivated') && (aff.category == 'Motivation' || aff.category == 'Success')) moodBoost = 1.30;
        if (lowerMood.contains('tired') && aff.category == 'Better Sleep') moodBoost = 1.30;
      }

      // Sub-level direct match boost (robust case-insensitive check)
      double subLevelBoost = 1.0;
      for (var sub in profile.selectedSubLevels) {
        final lowerSub = sub.toLowerCase();
        if (aff.subLevels.any((s) => s.toLowerCase().contains(lowerSub) || lowerSub.contains(s.toLowerCase()))) {
          subLevelBoost = 1.35;
          break;
        }
      }

      // Clinical Therapeutic Modality Boost (Fix for Gap 1)
      double modalityBoost = 1.0;
      if (profile.preferredModalities.contains(aff.modality)) {
        modalityBoost = 1.20;
      }

      // Circadian Time-of-Day Dynamics (Fix for Gap 7)
      final hour = now.hour;
      double circadianBoost = 1.0;
      if (hour >= 22 || hour < 5) {
        // Late night soothing smoothing
        if (aff.embeddingVector.length > 13 && aff.embeddingVector[13] > 0.5) {
          circadianBoost *= 1.25;
        }
        if (aff.embeddingVector.length > 14 && aff.embeddingVector[14] > 0.6) {
          circadianBoost *= 0.80; // Soften high-arousal action
        }
      } else if (hour >= 6 && hour < 11) {
        // Morning activation
        if (aff.embeddingVector.length > 14 && aff.embeddingVector[14] > 0.5) {
          circadianBoost *= 1.15;
        }
      }

      // Ebbinghaus Spaced Habituation Decay
      double habituationMultiplier = 1.0;
      if (lastListenedTimestamps != null && lastListenedTimestamps.containsKey(aff.id)) {
        habituationMultiplier = computeHabituationMultiplier(
          lastListenedEpochMs: lastListenedTimestamps[aff.id],
          now: now,
        );
      }

      final finalScore = sim * modeBoost * moodBoost * subLevelBoost * modalityBoost * circadianBoost * believabilityGate * habituationMultiplier;
      scored.add({
        'affirmation': aff,
        'score': finalScore,
      });
    }

    // Sort descending by initial relevance score
    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    if (scored.length <= limit) {
      return scored.map((e) => e['affirmation'] as Affirmation).toList();
    }

    // Maximal Marginal Relevance (MMR) Selection with lambda = 0.75 (Fix for Gap 4 - Greedy Top-K Redundancy)
    // Balances high relevance against semantic overlap to guarantee diverse, multi-faceted recommendations
    final List<Affirmation> selected = [];
    final List<Map<String, dynamic>> remaining = List.from(scored);

    // Pick top-scoring candidate first
    final first = remaining.removeAt(0);
    selected.add(first['affirmation'] as Affirmation);

    const double lambda = 0.70;
    final double maxScore = scored.isNotEmpty ? (scored.first['score'] as double) : 1.0;

    while (selected.length < limit && remaining.isNotEmpty) {
      double bestMmrScore = -double.infinity;
      int bestIdx = 0;

      for (int i = 0; i < remaining.length; i++) {
        final candidateAff = remaining[i]['affirmation'] as Affirmation;
        final candidateScore = remaining[i]['score'] as double;
        final normScore = maxScore > 0 ? (candidateScore / maxScore) : candidateScore;

        // Calculate max similarity with already selected affirmations
        double maxSimilarityToSelected = 0.0;
        for (var sel in selected) {
          final sim = cosineSimilarity(candidateAff.embeddingVector, sel.embeddingVector);
          if (sim > maxSimilarityToSelected) {
            maxSimilarityToSelected = sim;
          }
        }

        // Steep penalty for near-duplicate affirmations (cosine similarity > 0.85)
        final redundancyPenalty = maxSimilarityToSelected > 0.85 ? 0.35 : 0.0;
        final mmrScore = lambda * normScore - (1.0 - lambda) * maxSimilarityToSelected - redundancyPenalty;

        if (mmrScore > bestMmrScore) {
          bestMmrScore = mmrScore;
          bestIdx = i;
        }
      }

      final chosen = remaining.removeAt(bestIdx);
      selected.add(chosen['affirmation'] as Affirmation);
    }

    return selected;
  }

  /// Returns the single most relevant affirmation for the Hero card of the day.
  static Affirmation getHeroAffirmation({
    required UserProfileVector profile,
    required List<Affirmation> pool,
    required bool isGrowthMode,
    String? mood,
  }) {
    final feed = getPersonalizedFeed(
      profile: profile,
      pool: pool,
      isGrowthMode: isGrowthMode,
      mood: mood,
      limit: 1,
    );
    if (feed.isNotEmpty) return feed.first;
    return pool.first;
  }

  /// Generates a dynamic situational playlist tailored to the user's primary need.
  static Playlist generateSituationalPlaylist({
    required UserProfileVector profile,
    required List<Affirmation> pool,
    required bool isGrowthMode,
  }) {
    final feed = getPersonalizedFeed(
      profile: profile,
      pool: pool,
      isGrowthMode: isGrowthMode,
      limit: 8,
    );

    final primaryMeta = ArchetypeRegistry.getMetadata(
      profile.primaryArchetypes.isNotEmpty
          ? profile.primaryArchetypes.first
          : UserArchetype.careerProfessional,
    );

    return Playlist(
      id: 'pl_personalized_dynamic',
      title: '${primaryMeta.title} Mastery',
      duration: '10 min',
      category: primaryMeta.title,
      imagePath: 'assets/images/onboarding_archway_sun.jpg',
      isPremium: false,
      affirmations: feed,
    );
  }

  /// Ranks playlists based on 16D cosine similarity between the user's effective vector
  /// and each playlist's centroid vector, with multiplicative confidence modulation,
  /// cohesion scaling, and circadian day-seeded organic exploration.
  static List<PlaylistMatch> rankPlaylists({
    required UserProfileVector profile,
    required List<Playlist> playlists,
    required bool isGrowthMode,
    String? mood,
  }) {
    final userVec = (profile.effectiveVector.isNotEmpty && profile.effectiveVector.any((v) => v != 0.0))
        ? profile.effectiveVector
        : ((profile.vector.isNotEmpty && profile.vector.any((v) => v != 0.0))
            ? profile.vector
            : buildArchetypeBaseVector(
                primary: profile.primaryArchetypes,
                secondary: profile.secondaryArchetypes,
                subLevels: profile.selectedSubLevels,
                tone: profile.preferredTone,
              ));

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    final List<PlaylistMatch> matches = [];

    for (final playlist in playlists) {
      final centroid = playlist.centroidVector;
      if (centroid.isEmpty) {
        matches.add(PlaylistMatch(
          playlist: playlist,
          matchScore: 0.50,
          matchPercent: '75%',
          resonanceReason: 'Curated for you',
        ));
        continue;
      }

      // 1. Raw cosine similarity between user vector and playlist centroid
      final double sim = cosineSimilarity(userVec, centroid);

      // 2. Cohesion factor (Fix for Flaw 5 - Centroid Dispersion Paradox)
      // Scale by directional mean resultant length R: cohesion in [0.90, 1.0]
      final double cohesionFactor = 0.90 + 0.10 * playlist.cohesionScore;

      // 3. Multiplicative Confidence Modulators (Fix for Flaw 4 - Hybrid Metric Distortion)
      // Archetype affinity: x1.15 multiplier instead of additive scalar
      double archetypeFactor = 1.0;
      bool hasArchetypeAffinity = false;
      if (playlist.targetArchetypes != null && profile.primaryArchetypes.isNotEmpty) {
        for (var primary in profile.primaryArchetypes) {
          if (playlist.targetArchetypes!.contains(primary)) {
            hasArchetypeAffinity = true;
            archetypeFactor = 1.15;
            break;
          }
        }
      }

      // Sub-level affinity: x1.10 multiplier instead of additive scalar (with robust string match)
      double subLevelFactor = 1.0;
      if (playlist.targetSubLevels != null) {
        for (var sub in profile.selectedSubLevels) {
          final lowerSub = sub.toLowerCase();
          if (playlist.targetSubLevels!.any((ts) {
            final lowerTs = ts.toLowerCase();
            return lowerTs.contains(lowerSub) || lowerSub.contains(lowerTs);
          })) {
            subLevelFactor = 1.10;
            break;
          }
        }
      }

      // Mode alignment: x1.06 multiplier instead of additive scalar
      double modeFactor = 1.0;
      if (isGrowthMode) {
        if (centroid.length > 14 && centroid[14] > 0.3) {
          modeFactor = 1.06;
        }
      } else {
        if (centroid.length > 13 && centroid[13] > 0.3) {
          modeFactor = 1.06;
        }
      }

      // Multiplicative base score
      final double baseScore = sim * cohesionFactor * archetypeFactor * subLevelFactor * modeFactor;

      // 4. Circadian Day-Seeded Exploration Jitter (+/- 2%) (Fix for Flaw 6 - Deterministic Feed Stagnation)
      final double jitter = 0.02 * math.sin(playlist.id.hashCode.toDouble() + dayOfYear.toDouble());

      final double clampedScore = (baseScore + jitter).clamp(0.0, 0.99);

      // Match percentage string: map to realistic user-facing resonance (e.g. 60%-99%)
      final percentVal = (clampedScore * 100).round().clamp(60, 99);
      final percentStr = '$percentVal%';

      // Resonance reason
      String reason = 'Curated for your profile';
      if (hasArchetypeAffinity && profile.primaryArchetypes.isNotEmpty) {
        final meta = ArchetypeRegistry.getMetadata(profile.primaryArchetypes.first);
        reason = 'Aligned with ${meta.title}';
      } else if (isGrowthMode) {
        reason = 'Optimized for high performance';
      } else {
        reason = 'Optimized for grounding & calm';
      }

      matches.add(PlaylistMatch(
        playlist: playlist,
        matchScore: clampedScore,
        matchPercent: percentStr,
        resonanceReason: reason,
      ));
    }

    // Sort descending by matchScore
    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return matches;
  }

  static List<double> _normalize(List<double> vec) {
    double sumSq = 0.0;
    for (var val in vec) {
      sumSq += val * val;
    }
    if (sumSq == 0.0) return vec;
    double mag = math.sqrt(sumSq);
    return vec.map((e) => e / mag).toList();
  }
}
