import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/models/onboarding_state.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/services/personalization_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Advanced Adaptive Onboarding & Algorithmic Integration Tests', () {
    test('High-agency 2 AM thought detects expansion and adapts validation & somatic labels', () {
      final state = OnboardingState();
      state.userName = 'Zack';
      state.intentIndex = 2; // Level up and grow
      state.twoAmThought = 'Excited about scaling our new startup features and hitting our revenue goal';

      expect(state.activeTrack, equals(EmotionalTrack.expansion));
      expect(state.isHighAgencyThought, isTrue);

      // Verify validation text is empowering, not mournful
      final validation = state.getValidationText();
      expect(validation, contains('drive is rare'));
      expect(validation, isNot(contains('courage to say out loud')));

      // Verify somatic options are momentum/electricity, not chest tightness/nausea
      final somaticPrompt = state.getSomaticPrompt();
      expect(somaticPrompt, contains('drive'));

      final somaticLabels = state.getSomaticLabels();
      expect(somaticLabels.first, contains('Restless electricity'));
      expect(somaticLabels.first, isNot(contains('tightness, pressure')));
    });

    test('Vulnerable distress 2 AM thought detects restoration and retains compassionate grounding', () {
      final state = OnboardingState();
      state.userName = 'Emma';
      state.intentIndex = 1; // Healing from something painful
      state.twoAmThought = 'Heartbreak, crying every night and feeling so alone and broken';

      expect(state.activeTrack, equals(EmotionalTrack.restoration));
      expect(state.isHighAgencyThought, isFalse);

      final validation = state.getValidationText();
      expect(validation, contains('takes courage to say out loud'));

      final somaticPrompt = state.getSomaticPrompt();
      expect(somaticPrompt, contains('where do you feel it most in your body'));

      final somaticLabels = state.getSomaticLabels();
      expect(somaticLabels.first, contains('tightness, pressure'));
    });

    test('Automatic Secondary Archetype synthesis pairs Career with Anxious Overthinker', () {
      final state = OnboardingState();
      state.intentIndex = 0; // Mind won't stop racing
      state.archetypeIndex = 0; // Career primary

      final primary = state.getPrimaryArchetype();
      expect(primary, equals(UserArchetype.careerProfessional));

      final secondary = state.deriveSecondaryArchetype(primary);
      expect(secondary, equals(UserArchetype.anxiousOverthinker));
    });

    test('All 11 archetypes resolve correctly from onboarding', () {
      final state = OnboardingState();

      final expected = [
        UserArchetype.careerProfessional,
        UserArchetype.heartbreakSurvivor,
        UserArchetype.anxiousOverthinker,
        UserArchetype.selfImprovement,
        UserArchetype.spiritualSeeker,
        UserArchetype.athlete,
        UserArchetype.student,
        UserArchetype.parentCaregiver,
        UserArchetype.grievingIndividual,
        UserArchetype.lgbtqia,
        UserArchetype.personWithIDD,
      ];

      for (int i = 0; i < expected.length; i++) {
        state.archetypeIndex = i;
        expect(state.getPrimaryArchetype(), equals(expected[i]));
        expect(state.getSubArchetypeLabels(), isNotEmpty);
      }
    });

    test('buildArchetypeBaseVector incorporates rich onboarding fields (lifeStage, somatic, critic)', () {
      // 1. Student baseline
      final studentVec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.student],
        secondary: [],
        subLevels: ['High school & college exam prep'],
        tone: AffirmationTone.directAndActionable,
        lifeStageIndex: 0, // Student
      );
      expect(studentVec[11], greaterThan(0.3)); // High Academic dimension

      // 2. High-energy somatic expansion boosts action and vitality
      final energeticVec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [UserArchetype.selfImprovement],
        subLevels: ['Founder / Solopreneur'],
        tone: AffirmationTone.empowering,
        somaticIndex: 0, // Restless electricity
        isSomaticExpansion: true,
      );
      expect(energeticVec[14], greaterThan(0.3)); // High action

      // 3. Somatic distress boosts somatic calm and anxiety relief
      final distressVec = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.anxiousOverthinker],
        secondary: [],
        subLevels: ['Panic attacks & physical tension'],
        tone: AffirmationTone.gentleAndGrounding,
        somaticIndex: 0, // Chest tightness
        isSomaticExpansion: false,
      );
      expect(distressVec[13], greaterThan(0.3)); // High somatic calm
    });

    test('AppProvider.setUserArchetypeProfile correctly updates 75/25 multi-archetype vector', () async {
      final provider = AppProvider();
      await provider.loadState();

      await provider.setUserArchetypeProfile(
        primary: [UserArchetype.careerProfessional],
        secondary: [UserArchetype.anxiousOverthinker],
        subLevels: ['Founder / Solopreneur'],
        tone: AffirmationTone.empowering,
        lifeStageIndex: 1, // Early Career
        somaticIndex: 0,   // Restless electricity
        isSomaticExpansion: true,
        typedChallenge: 'Scaling my seed-stage company to series A',
        typedAspiration: 'Calm execution and fearless leadership',
      );

      expect(provider.userProfileVector.primaryArchetypes, contains(UserArchetype.careerProfessional));
      expect(provider.userProfileVector.secondaryArchetypes, contains(UserArchetype.anxiousOverthinker));
      expect(provider.userProfileVector.vector.length, equals(16));

      // Cosine similarity to career should be dominant (primary 75%)
      final careerCentroid = PersonalizationEngine.buildArchetypeBaseVector(
        primary: [UserArchetype.careerProfessional],
        secondary: [],
        subLevels: [],
        tone: AffirmationTone.empowering,
      );
      final similarity = PersonalizationEngine.cosineSimilarity(
        provider.userProfileVector.vector,
        careerCentroid,
      );
      expect(similarity, greaterThan(0.65));
    });
  });
}
