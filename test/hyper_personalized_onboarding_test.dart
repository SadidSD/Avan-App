import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/models/onboarding_state.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/services/personalization_engine.dart';
import 'package:avan_app/screens/onboarding/emotional_onboarding_screen.dart';

void main() {
  group('Hyper-Personalized 25-Screen Onboarding Tests', () {
    test('extractTextIntentVector accurately extracts Career and Confidence markers', () {
      final vec = PersonalizationEngine.extractTextIntentVector(
        'Stressed about my job interview with my boss, feel like an imposter',
        'Unshakeable confidence and executive presence',
      );
      expect(vec[0], greaterThan(0.2));
      expect(vec[7], greaterThan(0.2));
    });

    test('extractTextIntentVector accurately extracts Heartbreak and Somatic Calm markers', () {
      final vec = PersonalizationEngine.extractTextIntentVector(
        'Fresh breakup, heartbreak, cannot sleep and miss my ex',
        'Deep peace in my chest and emotional healing',
      );
      expect(vec[2], greaterThan(0.2));
      expect(vec[13], greaterThan(0.2));
    });

    test('OnboardingState core wound labels are dynamic based on intent', () {
      final state = OnboardingState();
      
      state.intentIndex = 0; // Mind racing
      expect(state.getCoreWoundLabels()[0], contains('trust'));
      
      state.intentIndex = 1; // Healing
      expect(state.getCoreWoundLabels()[0], contains('replaying'));
      
      state.intentIndex = 2; // Level up
      expect(state.getCoreWoundLabels()[0], contains('start strong'));
    });

    test('OnboardingState sub-archetype labels are dynamic based on archetype', () {
      final state = OnboardingState();
      
      state.archetypeIndex = 0; // Career
      expect(state.getSubArchetypeLabels()[0], contains('Imposter'));
      
      state.archetypeIndex = 2; // Mental Health
      expect(state.getSubArchetypeLabels()[0], contains('Panic'));
    });

    test('OnboardingState believability preference maps correctly from skepticism', () {
      final state = OnboardingState();
      
      state.skepticismIndex = 0; // Guarded
      expect(state.believabilityPreference, 0.92);
      
      state.skepticismIndex = 3; // Open
      expect(state.believabilityPreference, 0.55);
    });

    testWidgets('EmotionalOnboardingScreen renders and auto-advances from sanctuary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => AudioProvider()),
          ],
          child: const MaterialApp(
            home: EmotionalOnboardingScreen(),
          ),
        ),
      );

      expect(find.byType(EmotionalOnboardingScreen), findsOneWidget);

      // Wait for sanctuary auto-advance (2.5s)
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      // Should now show screen 1 (Name input) with a TextField
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Name input advances to life stage screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => AudioProvider()),
          ],
          child: const MaterialApp(
            home: EmotionalOnboardingScreen(),
          ),
        ),
      );

      // Skip sanctuary
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextField), 'Maya');
      await tester.pump();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should show personalized life stage prompt with Maya's name
      expect(find.textContaining('Maya'), findsWidgets);
    });
  });
}
