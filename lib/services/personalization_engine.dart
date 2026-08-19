import 'dart:math' as math;
import '../models/affirmation.dart';
import '../models/user_archetype.dart';
import '../models/user_profile_vector.dart';
import '../models/playlist.dart';

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
  static List<double> buildArchetypeBaseVector({
    required List<UserArchetype> primary,
    required List<UserArchetype> secondary,
    required List<String> subLevels,
    required AffirmationTone tone,
  }) {
    List<double> vec = List.filled(vectorDimensions, 0.05); // Base ambient noise

    // Helper to add weight to archetype index
    void addArchetypeWeight(UserArchetype type, double weight) {
      switch (type) {
        case UserArchetype.careerProfessional:
          vec[0] += 0.90 * weight; // Career
          vec[6] += 0.70 * weight; // Leadership
          vec[7] += 0.80 * weight; // Confidence
          vec[14] += 0.75 * weight; // Action
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
          vec[4] += 0.95 * weight; // Self-mastery
          vec[7] += 0.80 * weight; // Confidence
          vec[14] += 0.85 * weight; // Action
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

    // 1. Primary archetypes (Weight = 1.0)
    for (var a in primary) {
      addArchetypeWeight(a, 1.0);
    }

    // 2. Secondary archetypes (Weight = 0.55)
    for (var a in secondary) {
      addArchetypeWeight(a, 0.55);
    }

    // 3. Sub-level adjustments
    for (var sub in subLevels) {
      if (sub.contains('Founder')) vec[6] += 0.3;
      if (sub.contains('Panic') || sub.contains('Tension')) vec[1] += 0.3;
      if (sub.contains('Bedtime')) vec[13] += 0.3;
      if (sub.contains('Exam')) vec[11] += 0.3;
      if (sub.contains('Running') || sub.contains('Endurance')) vec[9] += 0.3;
      if (sub.contains('Toddler') || sub.contains('Newborn')) vec[8] += 0.3;
    }

    // 4. Tone modifier
    if (tone == AffirmationTone.gentleAndGrounding) {
      vec[13] += 0.3; // Boost somatic calm
      vec[15] += 0.2; // Boost believability
    } else if (tone == AffirmationTone.directAndActionable || tone == AffirmationTone.empowering) {
      vec[14] += 0.3; // Boost action/fire
    } else if (tone == AffirmationTone.simpleAndClear) {
      vec[10] += 0.4; // Boost simplicity
      vec[15] += 0.3;
    }

    // 5. Normalize vector
    return _normalize(vec);
  }

  /// Online dynamic EMA update when user interacts (favorites, completes audio, journals).
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

  /// Generates a personalized ranked queue of affirmations using multi-vector similarity,
  /// mode biasing, mood modulation, and believability gating.
  static List<Affirmation> getPersonalizedFeed({
    required UserProfileVector profile,
    required List<Affirmation> pool,
    required bool isGrowthMode,
    String? mood,
    int limit = 10,
    List<String> excludeIds = const [],
  }) {
    final userVec = profile.vector.isNotEmpty
        ? profile.vector
        : buildArchetypeBaseVector(
            primary: profile.primaryArchetypes,
            secondary: profile.secondaryArchetypes,
            subLevels: profile.selectedSubLevels,
            tone: profile.preferredTone,
          );

    final bool isIDDUser = profile.primaryArchetypes.contains(UserArchetype.personWithIDD);

    // Score each candidate affirmation
    List<Map<String, dynamic>> scored = [];

    for (var aff in pool) {
      if (excludeIds.contains(aff.id)) continue;

      // IDD safety filter: if user requested sensory/simple direct, prioritize accessible affirmations
      if (isIDDUser && aff.tone != AffirmationTone.simpleAndClear && aff.modality != TherapeuticModality.accessibleDirect) {
        // deprioritize complex philosophical affirmations
        continue;
      }

      // Base Cosine Similarity
      double sim = cosineSimilarity(userVec, aff.embeddingVector);

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

      // Sub-level direct match boost
      double subLevelBoost = 1.0;
      for (var sub in profile.selectedSubLevels) {
        if (aff.subLevels.contains(sub)) {
          subLevelBoost = 1.35;
          break;
        }
      }

      final finalScore = sim * modeBoost * moodBoost * subLevelBoost;
      scored.add({
        'affirmation': aff,
        'score': finalScore,
      });
    }

    // Sort by descending score
    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored.take(limit).map((e) => e['affirmation'] as Affirmation).toList();
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
