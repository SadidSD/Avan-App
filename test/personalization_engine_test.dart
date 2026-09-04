import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/models/user_profile_vector.dart';
import 'package:avan_app/models/affirmation.dart';
import 'package:avan_app/models/playlist.dart';
import 'package:avan_app/services/personalization_engine.dart';
import 'package:avan_app/data/affirmation_library.dart';

void main() {
  group('PersonalizationEngine Tests', () {
    test('Cosine similarity of identical vectors is 1.0', () {
      final v1 = [1.0, 0.0, 0.5, 0.2];
      final v2 = [1.0, 0.0, 0.5, 0.2];
      final sim = PersonalizationEngine.cosineSimilarity(v1, v2);
      expect(sim, closeTo(1.0, 0.001));
    });

    test('Cosine similarity of orthogonal vectors is 0.0', () {
      final v1 = [1.0, 0.0, 0.0, 0.0];
      final v2 = [0.0, 1.0, 0.0, 0.0];
      final sim = PersonalizationEngine.cosineSimilarity(v1, v2);
      expect(sim, closeTo(0.0, 0.001));
    });

    test('buildArchetypeBaseVector creates normalized 16D vector', () {
      final vec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [UserArchetype.athlete],
        subLevels: ['Founder / Solopreneur', 'Competitive Game Prep & Clutch Mindset'],
        tone: AffirmationTone.empowering,
      );

      expect(vec.length, equals(16));
      // Career dimension [0] should be high
      expect(vec[0], greaterThan(0.3));
      // Athletic dimension [9] should be high
      expect(vec[9], greaterThan(0.2));
    });

    test('Personalized feed prioritizes relevant affirmations for Career Founder', () {
      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        selectedSubLevels: ['Founder / Solopreneur'],
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.careerProfessional],
          secondary: [],
          subLevels: ['Founder / Solopreneur'],
          tone: AffirmationTone.empowering,
        ),
      );

      final feed = PersonalizationEngine.getPersonalizedFeed(
        profile: profile,
        pool: comprehensiveAffirmationLibrary,
        isGrowthMode: true,
        limit: 5,
      );

      expect(feed.isNotEmpty, isTrue);
      // Top affirmation should be career/founder focused
      expect(feed.first.category, equals('Career & Ambition'));
    });

    test('Personalized feed for IDD user enforces accessible direct affirmations', () {
      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.personWithIDD],
        selectedSubLevels: ['Sensory Calming & Grounding'],
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.personWithIDD],
          secondary: [],
          subLevels: ['Sensory Calming & Grounding'],
          tone: AffirmationTone.simpleAndClear,
        ),
      );

      final feed = PersonalizationEngine.getPersonalizedFeed(
        profile: profile,
        pool: comprehensiveAffirmationLibrary,
        isGrowthMode: false,
        limit: 5,
      );

      expect(feed.isNotEmpty, isTrue);
      for (var aff in feed) {
        expect(aff.tone, equals(AffirmationTone.simpleAndClear));
      }
    });

    test('Online EMA update shifts user vector toward favorited affirmation', () {
      final initialVec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [],
        subLevels: [],
        tone: AffirmationTone.empowering,
      );

      // Grieving affirmation vector
      final griefAff = comprehensiveAffirmationLibrary.firstWhere(
        (a) => a.primaryArchetypes.contains(UserArchetype.grievingIndividual),
      );

      final updatedVec = PersonalizationEngine.updateVectorWithInteraction(
        currentVector: initialVec,
        affirmationVector: griefAff.embeddingVector,
        learningRate: 0.20,
      );

      // Grief dimension [3] should increase after interaction
      expect(updatedVec[3], greaterThan(initialVec[3]));
    });

    test('Multi-Archetype convex combination preserves primary Career dominance (Flaw 1 & 7)', () {
      final vec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [UserArchetype.anxiousOverthinker, UserArchetype.heartbreakSurvivor],
        subLevels: ['Founder / Solopreneur'],
        tone: AffirmationTone.empowering,
      );

      // Career dimension [0] must stay dominant despite secondary archetypes
      expect(vec[0], greaterThan(0.35));
      // Action dimension [14] should also be high
      expect(vec[14], greaterThan(0.30));
    });

    test('Anchored dual-vector EMA update resists catastrophic profile drift (Flaw 2)', () {
      final initialBase = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [],
        subLevels: ['Founder / Solopreneur'],
        tone: AffirmationTone.empowering,
      );

      var profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        selectedSubLevels: ['Founder / Solopreneur'],
        vector: initialBase,
        baselineVector: initialBase,
        stateVector: initialBase,
      );

      // Pure sleep/calm affirmation vector (high somatic calm [13], zero career [0])
      final sleepAffVec = [
        0.0, 0.2, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.95, 0.0, 0.8
      ];

      // Simulate 30 consecutive nighttime interactions
      for (int i = 0; i < 30; i++) {
        profile = PersonalizationEngine.updateProfileWithInteraction(
          profile: profile,
          affirmationVector: sleepAffVec,
          learningRate: 0.15,
        );
      }

      // Baseline vector should remain 100% immutable
      expect(profile.baselineVector[0], equals(initialBase[0]));

      // Dynamic state vector adapted to sleep/calm
      expect(profile.stateVector[13], greaterThan(0.70));

      // Effective blended vector PRESERVES Career dominance (cannot drop below 0.25)
      expect(profile.effectiveVector[0], greaterThan(0.25));
      expect(profile.interactionCount, equals(30));
    });

    test('Exponential believability penalty gates toxic positivity for vulnerable users (Flaw 3)', () {
      final anxiousProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        selectedSubLevels: ['Panic Attacks & Acute Physical Tension'],
        preferredTone: AffirmationTone.gentleAndGrounding,
        believabilityPreference: 0.90, // High need for gentle believable reframing
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.anxiousOverthinker],
          secondary: [],
          subLevels: ['Panic Attacks & Acute Physical Tension'],
          tone: AffirmationTone.gentleAndGrounding,
        ),
      );

      final calmAff = Affirmation(
        id: 'aff_gentle_calm',
        text: 'I can breathe through this sensation; my body knows how to regulate itself.',
        category: 'Calm Mind',
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        tone: AffirmationTone.gentleAndGrounding,
        embeddingVector: [0.05, 0.85, 0.10, 0.05, 0.10, 0.05, 0.05, 0.20, 0.05, 0.05, 0.10, 0.05, 0.05, 0.90, 0.10, 0.90],
        believabilityScore: 0.95, // High believability
      );

      final radicalAff = Affirmation(
        id: 'aff_radical_toxic',
        text: 'I am invincible and nothing in the universe can ever touch or worry me.',
        category: 'Calm Mind',
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        tone: AffirmationTone.empowering,
        embeddingVector: [0.05, 0.85, 0.10, 0.05, 0.10, 0.05, 0.05, 0.20, 0.05, 0.05, 0.10, 0.05, 0.05, 0.90, 0.10, 0.90],
        believabilityScore: 0.20, // Radically unbelievable for panic sufferers
      );

      final feed = PersonalizationEngine.getPersonalizedFeed(
        profile: anxiousProfile,
        pool: [radicalAff, calmAff],
        isGrowthMode: false,
        limit: 2,
      );

      // Gentle believable affirmation must be ranked #1
      expect(feed.first.id, equals('aff_gentle_calm'));
    });

    test('Multiplicative ranking and cohesion prevent metric distortion and phantom centroids (Flaw 4 & 5)', () {
      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        selectedSubLevels: ['Founder / Solopreneur'],
        preferredTone: AffirmationTone.empowering,
      );

      // Cohesive playlist
      final cohesiveAffs = [
        Affirmation(
          id: 'aff_c1',
          text: 'Focused execution',
          category: 'Career',
          embeddingVector: [0.8, 0.1, 0.0, 0.0, 0.2, 0.0, 0.7, 0.7, 0.0, 0.0, 0.0, 0.2, 0.0, 0.1, 0.8, 0.5],
        ),
        Affirmation(
          id: 'aff_c2',
          text: 'Building momentum',
          category: 'Career',
          embeddingVector: [0.85, 0.1, 0.0, 0.0, 0.2, 0.0, 0.65, 0.7, 0.0, 0.0, 0.0, 0.2, 0.0, 0.1, 0.75, 0.5],
        ),
      ];
      final cohesivePlaylist = Playlist(
        id: 'pl_cohesive',
        title: 'Executive Focus',
        affirmations: cohesiveAffs,
        targetArchetypes: [UserArchetype.careerProfessional],
        targetSubLevels: ['Founder / Solopreneur'],
      );

      expect(cohesivePlaylist.cohesionScore, greaterThan(0.95));

      final ranked = PersonalizationEngine.rankPlaylists(
        profile: profile,
        playlists: [cohesivePlaylist],
        isGrowthMode: true,
      );

      expect(ranked.first.matchScore, greaterThan(0.75));
      expect(ranked.first.matchScore, lessThanOrEqualTo(0.99));
    });

    test('AffirmationTone.philosophical synthesizes Stoic, Wisdom, and Calm dimensions', () {
      final vec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [],
        subLevels: [],
        tone: AffirmationTone.philosophical,
      );

      // Stoic/Acceptance [4] and Wisdom/Perspective [5] must be elevated
      expect(vec[4], greaterThan(0.20));
      expect(vec[5], greaterThan(0.20));
      expect(vec[13], greaterThan(0.15));
    });

    test('preferredModalities boosts matching affirmation score in feed', () {
      final actAff = Affirmation(
        id: 'aff_act',
        text: 'I acknowledge this feeling without judgment and take a step forward.',
        category: 'Mindfulness',
        modality: TherapeuticModality.actValues,
        tone: AffirmationTone.philosophical,
        embeddingVector: [0.1, 0.5, 0.1, 0.1, 0.5, 0.5, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.5, 0.1, 0.5],
      );

      final cbtAff = Affirmation(
        id: 'aff_cbt',
        text: 'I replace this negative thought with a realistic observation.',
        category: 'Cognitive',
        modality: TherapeuticModality.cbtReframe,
        tone: AffirmationTone.philosophical,
        embeddingVector: [0.1, 0.5, 0.1, 0.1, 0.5, 0.5, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.5, 0.1, 0.5],
      );

      final profileWithAct = UserProfileVector(
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        preferredModalities: [TherapeuticModality.actValues],
        vector: [0.1, 0.5, 0.1, 0.1, 0.5, 0.5, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.5, 0.1, 0.5],
      );

      final feed = PersonalizationEngine.getPersonalizedFeed(
        profile: profileWithAct,
        pool: [cbtAff, actAff],
        isGrowthMode: false,
        limit: 2,
      );

      // ACT affirmation must rank #1 due to the 1.20x modality boost
      expect(feed.first.id, equals('aff_act'));
    });

    test('MMR diversity selection suppresses redundant near-duplicate affirmations', () {
      final baseVec = [0.8, 0.2, 0.0, 0.0, 0.1, 0.1, 0.5, 0.7, 0.0, 0.0, 0.0, 0.1, 0.0, 0.1, 0.8, 0.5];

      final duplicate1 = Affirmation(
        id: 'aff_dup_1',
        text: 'I am executing my work today with discipline and power.',
        category: 'Career',
        embeddingVector: List<double>.from(baseVec),
      );
      final duplicate2 = Affirmation(
        id: 'aff_dup_2',
        text: 'I execute my daily work with power and discipline.',
        category: 'Career',
        embeddingVector: baseVec.map((x) => x * 0.98).toList(),
      );
      final diverse = Affirmation(
        id: 'aff_diverse',
        text: 'I maintain calm equilibrium and restore my nervous system.',
        category: 'Rest',
        embeddingVector: [0.1, 0.2, 0.0, 0.0, 0.6, 0.6, 0.1, 0.1, 0.0, 0.0, 0.0, 0.1, 0.0, 0.9, 0.1, 0.8],
      );

      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        vector: List<double>.from(baseVec),
      );

      final feed = PersonalizationEngine.getPersonalizedFeed(
        profile: profile,
        pool: [duplicate1, duplicate2, diverse],
        isGrowthMode: true,
        limit: 2,
      );

      expect(feed.length, equals(2));
      expect(feed[0].id, equals('aff_dup_1'));
      expect(feed[1].id, equals('aff_diverse'));
    });

    test('penalizeSkippedAffirmation dampens state vector weight along skipped dimension', () {
      final initialVec = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        vector: initialVec,
        baselineVector: initialVec,
        stateVector: initialVec,
      );

      final skippedVec = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      final penalizedProfile = PersonalizationEngine.penalizeSkippedAffirmation(
        profile: profile,
        affirmationVector: skippedVec,
        penaltyRate: 0.15,
      );

      // Dimension [9] in stateVector should be reduced compared to baseline
      expect(penalizedProfile.stateVector[9], lessThan(profile.stateVector[9]));
      expect(penalizedProfile.effectiveVector[9], lessThan(profile.effectiveVector[9]));
    });

    test('Ebbinghaus spaced habituation curve mathematically suppresses recent listens and recovers', () {
      final now = DateTime.now();

      // Fresh affirmation (never listened)
      final freshMultiplier = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: null,
        now: now,
      );
      expect(freshMultiplier, equals(1.0));

      // Just listened (0 hours ago)
      final immediateMultiplier = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: now.millisecondsSinceEpoch,
        now: now,
      );
      expect(immediateMultiplier, closeTo(0.20, 0.01));

      // Listened 12 hours ago
      final t12h = now.subtract(const Duration(hours: 12)).millisecondsSinceEpoch;
      final mult12h = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: t12h,
        now: now,
      );
      expect(mult12h, greaterThan(0.35));
      expect(mult12h, lessThan(0.45));

      // Listened 40 hours ago (half-life)
      final t40h = now.subtract(const Duration(hours: 40)).millisecondsSinceEpoch;
      final mult40h = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: t40h,
        now: now,
      );
      expect(mult40h, closeTo(0.705, 0.02));

      // Listened 96 hours ago (4 days)
      final t96h = now.subtract(const Duration(hours: 96)).millisecondsSinceEpoch;
      final mult96h = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: t96h,
        now: now,
      );
      expect(mult96h, greaterThan(0.90));

      // Listened 7 days ago
      final t7d = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
      final mult7d = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: t7d,
        now: now,
      );
      expect(mult7d, greaterThan(0.98));
    });

    test('Ebbinghaus habituation in getPersonalizedFeed demotes recently heard quote', () {
      final now = DateTime.now();
      final baseVec = [0.8, 0.2, 0.0, 0.0, 0.1, 0.1, 0.5, 0.7, 0.0, 0.0, 0.0, 0.1, 0.0, 0.1, 0.8, 0.5];

      // Highly relevant affirmation A (cosine similarity 1.0 to userVec)
      final affA = Affirmation(
        id: 'aff_habit_A',
        text: 'Top relevant quote',
        category: 'Career',
        embeddingVector: List<double>.from(baseVec),
      );

      // Slightly lower relevant affirmation B (distinct direction, cosine similarity ~0.85)
      final affB = Affirmation(
        id: 'aff_habit_B',
        text: 'Alternative relevant quote',
        category: 'Career',
        embeddingVector: [0.5, 0.5, 0.0, 0.0, 0.1, 0.1, 0.3, 0.4, 0.0, 0.0, 0.0, 0.1, 0.0, 0.1, 0.5, 0.4],
      );

      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        vector: List<double>.from(baseVec),
      );

      // Without listening history: affA is ranked #1
      final feedWithoutHistory = PersonalizationEngine.getPersonalizedFeed(
        profile: profile,
        pool: [affB, affA],
        isGrowthMode: true,
        limit: 2,
      );
      expect(feedWithoutHistory.first.id, equals('aff_habit_A'));

      // With listening history: affA was just listened to 1 hour ago
      final feedWithHistory = PersonalizationEngine.getPersonalizedFeed(
        profile: profile,
        pool: [affB, affA],
        isGrowthMode: true,
        limit: 2,
        lastListenedTimestamps: {
          'aff_habit_A': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        },
      );

      // affA should be demoted due to habituation penalty, so affB ranks #1!
      expect(feedWithHistory.first.id, equals('aff_habit_B'));
    });

    test('ZPD Dynamic Believability Ladder expands agency window with consistency and retreats upon skips', () {
      final baseline = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        believabilityPreference: 0.85,
        completedSessionsCount: 0,
        recentSkipCount: 0,
      );

      // Initial day 1: effective believability is exactly baseline
      expect(baseline.effectiveBelievabilityPreference, closeTo(0.85, 0.001));

      // After 10 completed sessions: growth shifts ladder toward higher agency (lower believability score need)
      final advancedProfile = baseline.copyWith(completedSessionsCount: 10);
      expect(advancedProfile.effectiveBelievabilityPreference, lessThan(0.85));
      expect(advancedProfile.effectiveBelievabilityPreference, closeTo(0.795, 0.02));

      // After 30 completed sessions: agency expands further
      final masterProfile = baseline.copyWith(completedSessionsCount: 30);
      expect(masterProfile.effectiveBelievabilityPreference, lessThan(0.75));
      expect(masterProfile.effectiveBelievabilityPreference, greaterThan(0.45));

      // If user starts rapidly skipping (e.g. 3 skips), safety retreat brings ladder back up
      final retreatProfile = masterProfile.copyWith(recentSkipCount: 3);
      expect(retreatProfile.effectiveBelievabilityPreference, greaterThan(masterProfile.effectiveBelievabilityPreference));
    });

    test('Playlist ranking enforces dynamic ZPD believability gating', () {
      final userVec = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5];

      // Vulnerable user needing gentle grounding (believability = 0.90)
      final profile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        believabilityPreference: 0.90,
        completedSessionsCount: 0,
        recentSkipCount: 0,
        vector: userVec,
      );

      // Aggressive aspirational playlist with low believability (0.35)
      final aggressivePlaylist = Playlist(
        id: 'p_aggressive',
        title: 'Executive Dominance',
        affirmations: [
          Affirmation(
            id: 'a_agg_1',
            text: 'I dominate every room.',
            believabilityScore: 0.35,
            embeddingVector: userVec,
          ),
        ],
      );

      // Gentle grounding playlist with high believability (0.88)
      final gentlePlaylist = Playlist(
        id: 'p_gentle',
        title: 'Grounded Confidence',
        affirmations: [
          Affirmation(
            id: 'a_gentle_1',
            text: 'I am taking it one steady step at a time.',
            believabilityScore: 0.88,
            embeddingVector: userVec,
          ),
        ],
      );

      expect(aggressivePlaylist.averageBelievabilityScore, closeTo(0.35, 0.01));
      expect(gentlePlaylist.averageBelievabilityScore, closeTo(0.88, 0.01));

      final ranked = PersonalizationEngine.rankPlaylists(
        profile: profile,
        playlists: [aggressivePlaylist, gentlePlaylist],
        isGrowthMode: true,
      );

      // Gentle playlist should rank #1 due to ZPD believability gating protecting the user from cognitive rejection
      expect(ranked.first.playlist.id, equals('p_gentle'));
    });

    test('computeHabituationMultiplier handles clock skew, negative elapsed time, and zero recovery gracefully', () {
      final now = DateTime.now();

      // Normal recent listen: should be penalized (0.20)
      final fresh = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: now.millisecondsSinceEpoch,
        now: now,
      );
      expect(fresh, closeTo(0.20, 0.01));

      // Clock skew: timestamp 1 hour in the future (>10m) should return unpenalized 1.0
      final futureTime = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;
      final futureSkew = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: futureTime,
        now: now,
      );
      expect(futureSkew, equals(1.0));

      // Zero or negative recovery hours returns unpenalized 1.0
      final zeroRecovery = PersonalizationEngine.computeHabituationMultiplier(
        lastListenedEpochMs: now.millisecondsSinceEpoch,
        now: now,
        recoveryHours: 0,
      );
      expect(zeroRecovery, equals(1.0));
    });

    test('UserProfileVector defensively handles negative session/skip counts and NaN values', () {
      final profile = UserProfileVector(
        completedSessionsCount: -5,
        recentSkipCount: -2,
        believabilityPreference: 0.8,
      );

      // Defensive clamping should keep it within valid range without NaN
      expect(profile.effectiveBelievabilityPreference, closeTo(0.8, 0.01));
      expect(profile.effectiveBelievabilityPreference.isNaN, isFalse);
    });
  });
}
