import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/models/user_profile_vector.dart';
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
  });
}
