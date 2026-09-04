import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/models/user_archetype.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding Algorithm & Affirmation Integration Tests', () {
    test('setUserArchetypeProfile stores custom believability preference and syncs survey state', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.setUserArchetypeProfile(
        primary: [UserArchetype.careerProfessional],
        secondary: [UserArchetype.anxiousOverthinker],
        subLevels: ['Founder / Solopreneur', 'Bedtime & Late-Night Rumination'],
        tone: AffirmationTone.directAndActionable,
        believabilityPreference: 0.55,
      );

      // Verify believability baseline
      expect(provider.userProfileVector.believabilityPreference, equals(0.55));
      expect(provider.userProfileVector.effectiveBelievabilityPreference, closeTo(0.55, 0.01));

      // Verify tone and archetypes
      expect(provider.userProfileVector.preferredTone, equals(AffirmationTone.directAndActionable));
      expect(provider.userProfileVector.primaryArchetypes, contains(UserArchetype.careerProfessional));
      expect(provider.userProfileVector.secondaryArchetypes, contains(UserArchetype.anxiousOverthinker));

      // Verify survey synchronization (no stale/mock survey data)
      expect(provider.selectedGoal, contains('Career'));
      expect(provider.selectedChallenge, equals('Founder / Solopreneur'));
      expect(provider.selectedVision, equals('directAndActionable'));
    });

    test('High-Skepticism / Anti-Toxic Positivity believability preference (0.92) is respected', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.setUserArchetypeProfile(
        primary: [UserArchetype.heartbreakSurvivor],
        secondary: [UserArchetype.anxiousOverthinker],
        subLevels: ['Fresh Breakup / Shock Phase (Day 0-30)'],
        tone: AffirmationTone.gentleAndGrounding,
        believabilityPreference: 0.92,
      );

      expect(provider.userProfileVector.believabilityPreference, equals(0.92));
      expect(provider.userProfileVector.effectiveBelievabilityPreference, closeTo(0.92, 0.01));
    });

    test('getHeroAffirmation and getSituationalPlaylist produce tailored output for calibrated profile', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.setUserArchetypeProfile(
        primary: [UserArchetype.athlete],
        secondary: [UserArchetype.selfImprovement],
        subLevels: ['Competitive Game Prep & Clutch Mindset'],
        tone: AffirmationTone.empowering,
        believabilityPreference: 0.60,
      );

      final hero = provider.getHeroAffirmation();
      expect(hero.quote.isNotEmpty, isTrue);
      expect(hero.id.isNotEmpty, isTrue);

      final playlist = provider.getSituationalPlaylist();
      expect(playlist.affirmations.isNotEmpty, isTrue);
      expect(playlist.title, contains('Athlete'));
    });
  });
}
