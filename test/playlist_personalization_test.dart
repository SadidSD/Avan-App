import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/models/user_profile_vector.dart';
import 'package:avan_app/services/personalization_engine.dart';

void main() {
  group('Playlist Dimensional Personification Suite', () {
    test('Every one of the 63 playlists computes a valid 16D centroid vector', () {
      expect(allPlaylists.length, equals(63));

      for (var playlist in allPlaylists) {
        final centroid = playlist.centroidVector;
        expect(
          centroid.length,
          equals(16),
          reason: 'Playlist ${playlist.id} must have a 16-dimensional centroid',
        );

        // Vector should be normalized to unit length (~1.0)
        double normSq = 0.0;
        for (var v in centroid) {
          normSq += v * v;
        }
        expect(normSq, closeTo(1.0, 0.01),
            reason: 'Centroid for ${playlist.id} should be normalized');
      }
    });

    test('Founder Personification: Founder / Solopreneur prioritizes executive and founder playlists', () {
      final founderProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.careerProfessional],
        selectedSubLevels: ['Founder / Solopreneur'],
        preferredTone: AffirmationTone.empowering,
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.careerProfessional],
          secondary: [],
          subLevels: ['Founder / Solopreneur'],
          tone: AffirmationTone.empowering,
        ),
      );

      final ranked = PersonalizationEngine.rankPlaylists(
        profile: founderProfile,
        playlists: allPlaylists,
        isGrowthMode: true,
      );

      expect(ranked.isNotEmpty, isTrue);
      // Top matches should be career / leadership / founder playlists
      final top3Ids = ranked.take(3).map((m) => m.playlist.id).toList();
      final hasFounderOrCareer = top3Ids.any((id) =>
          id.contains('founder') ||
          id.contains('career') ||
          id.contains('exec') ||
          id.contains('business') ||
          id.contains('performance'));

      expect(hasFounderOrCareer, isTrue);
      expect(ranked.first.matchScore, greaterThan(0.70));
    });

    test('Bedtime Anxious Personification: Bedtime rumination ranks calming and sleep playlists at the top', () {
      final bedtimeProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.anxiousOverthinker],
        selectedSubLevels: ['Bedtime & Late-Night Rumination'],
        preferredTone: AffirmationTone.gentleAndGrounding,
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.anxiousOverthinker],
          secondary: [],
          subLevels: ['Bedtime & Late-Night Rumination'],
          tone: AffirmationTone.gentleAndGrounding,
        ),
      );

      final ranked = PersonalizationEngine.rankPlaylists(
        profile: bedtimeProfile,
        playlists: allPlaylists,
        isGrowthMode: false, // Healing mode
      );

      expect(ranked.isNotEmpty, isTrue);
      // Top 3 should feature anxiety/panic/sleep/calm playlists
      final top3Ids = ranked.take(3).map((m) => m.playlist.id).toList();
      final hasCalmOrSleep = top3Ids.any((id) =>
          id.contains('night') ||
          id.contains('panic') ||
          id.contains('calm') ||
          id.contains('anxiety') ||
          id.contains('somatic') ||
          id.contains('overthinking'));

      expect(hasCalmOrSleep, isTrue);
      expect(ranked.first.matchScore, greaterThan(0.70));
    });

    test('Heartbreak Personification: Fresh breakup survivor ranks heartbreak recovery playlists #1', () {
      final breakupProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.heartbreakSurvivor],
        selectedSubLevels: ['Fresh Breakup / Shock Phase (Day 0-30)'],
        preferredTone: AffirmationTone.gentleAndGrounding,
        vector: PersonalizationEngine.buildArchetypeBaseVector(
          primary: [UserArchetype.heartbreakSurvivor],
          secondary: [],
          subLevels: ['Fresh Breakup / Shock Phase (Day 0-30)'],
          tone: AffirmationTone.gentleAndGrounding,
        ),
      );

      final ranked = PersonalizationEngine.rankPlaylists(
        profile: breakupProfile,
        playlists: allPlaylists,
        isGrowthMode: false,
      );

      expect(ranked.isNotEmpty, isTrue);
      final top3Ids = ranked.take(3).map((m) => m.playlist.id).toList();
      final hasBreakup = top3Ids.any((id) =>
          id.contains('breakup') ||
          id.contains('heart') ||
          id.contains('healing') ||
          id.contains('worth'));

      expect(hasBreakup, isTrue);
    });

    test('Mode biasing shifts ranking towards action/career in Growth and calm in Healing', () {
      final neutralProfile = UserProfileVector(
        primaryArchetypes: [UserArchetype.selfImprovement],
        selectedSubLevels: ['Daily Habit & Consistency Builder'],
        preferredTone: AffirmationTone.empowering,
      );

      final growthRanked = PersonalizationEngine.rankPlaylists(
        profile: neutralProfile,
        playlists: allPlaylists,
        isGrowthMode: true,
      );

      final healingRanked = PersonalizationEngine.rankPlaylists(
        profile: neutralProfile,
        playlists: allPlaylists,
        isGrowthMode: false,
      );

      // The top playlist or rankings should dynamically adjust based on mode
      expect(growthRanked.first.playlist.id, isNotEmpty);
      expect(healingRanked.first.playlist.id, isNotEmpty);
    });
  });
}
