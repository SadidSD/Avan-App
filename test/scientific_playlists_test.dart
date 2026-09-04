import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/models/user_profile_vector.dart';
import 'package:avan_app/services/personalization_engine.dart';

void main() {
  group('Scientific Playlists Suite Tests (60 Playlists / 600+ Affirmations)', () {
    test('All 60 playlists are registered and valid', () {
      expect(allPlaylists.length, equals(60));
      expect(freePlaylists.length, equals(6));
      expect(premiumPlaylists.length, equals(54));
    });

    test('Every affirmation has a 16-dimensional embedding vector', () {
      final allAffs = getAllGlobalAffirmations();
      expect(allAffs.length, greaterThanOrEqualTo(600));

      for (var aff in allAffs) {
        expect(
          aff.embeddingVector.length,
          equals(16),
          reason: 'Affirmation ${aff.id} must have a 16-element embeddingVector',
        );
        expect(
          aff.quote.isNotEmpty,
          isTrue,
          reason: 'Affirmation ${aff.id} must not have empty text/quote',
        );
      }
    });

    test('Panic Release affirmations strongly align with Anxious Overthinker', () {
      final anxiousProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        selectedSubLevels: ['Chronic Panic & Physical Tension'],
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.anxiousOverthinker],
          secondary: [],
          subLevels: ['Chronic Panic & Physical Tension'],
          tone: AffirmationTone.gentleAndGrounding,
        ),
      );

      final panicPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_panic_release');
      final firstPanicAff = panicPlaylist.affirmations.first;

      final sim = PersonalizationEngine.cosineSimilarity(
        anxiousProfile.vector,
        firstPanicAff.embeddingVector,
      );

      expect(sim, greaterThan(0.70));
    });

    test('Founder Resilience affirmations strongly align with Career Professional', () {
      final founderProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        selectedSubLevels: ['Founder / Solopreneur'],
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.careerProfessional],
          secondary: [],
          subLevels: ['Founder / Solopreneur'],
          tone: AffirmationTone.empowering,
        ),
      );

      final founderPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_founder_resilience');
      final firstFounderAff = founderPlaylist.affirmations.first;

      final sim = PersonalizationEngine.cosineSimilarity(
        founderProfile.vector,
        firstFounderAff.embeddingVector,
      );

      expect(sim, greaterThan(0.70));
    });

    test('ADHD Reset affirmations align with Focus & Habits archetypes', () {
      final habitProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.selfImprovement],
        selectedSubLevels: ['Daily Habit & Consistency Builder', 'Deep Work & Focus Optimizer'],
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.selfImprovement],
          secondary: [],
          subLevels: ['Daily Habit & Consistency Builder', 'Deep Work & Focus Optimizer'],
          tone: AffirmationTone.directAndActionable,
        ),
      );

      final adhdPlaylist = allPlaylists.firstWhere((p) => p.id == 'pl_adhd_reset');
      final firstAdhdAff = adhdPlaylist.affirmations.first;

      final sim = PersonalizationEngine.cosineSimilarity(
        habitProfile.vector,
        firstAdhdAff.embeddingVector,
      );

      expect(sim, greaterThan(0.70));
    });
  });
}
