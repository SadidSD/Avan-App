import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/models/user_archetype.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/services/personalization_engine.dart';
import 'package:avan_app/screens/onboarding/emotional_onboarding_screen.dart';

void main() {
  group('Hyper-Personalized Onboarding & NLP Synthesis Tests', () {
    test('extractTextIntentVector accurately extracts Career and Confidence markers', () {
      final vec = PersonalizationEngine.extractTextIntentVector(
        'Stressed about my job interview with my boss, feel like an imposter',
        'Unshakeable confidence and executive presence',
      );

      // Dimension 0 is Career, Dimension 7 is Confidence
      expect(vec[0], greaterThan(0.2));
      expect(vec[7], greaterThan(0.2));
    });

    test('extractTextIntentVector accurately extracts Heartbreak and Somatic Calm markers', () {
      final vec = PersonalizationEngine.extractTextIntentVector(
        'Fresh breakup, heartbreak, cannot sleep and miss my ex',
        'Deep peace in my chest and emotional healing',
      );

      // Dimension 2 is Heartbreak, Dimension 13 is Somatic Calm/Sleep
      expect(vec[2], greaterThan(0.2));
      expect(vec[13], greaterThan(0.2));
    });

    testWidgets('EmotionalOnboardingScreen supports typing name and advancing', (WidgetTester tester) async {
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

      // Verify Screen 1 Name Input elements
      expect(find.text('AVAN'), findsWidgets);
      expect(find.text('YOUR IDENTITY'), findsOneWidget);
      expect(find.text('Begin Sanctuary'), findsOneWidget);

      // Enter name
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Maya');
      await tester.pump();

      // Tap Begin Sanctuary
      await tester.tap(find.text('Begin Sanctuary'));
      await tester.pumpAndSettle();

      // Should now be on Step 2 with personalized greeting: Welcome, Maya.
      expect(find.text('2 / 7'), findsOneWidget);
      expect(find.textContaining('Maya'), findsWidgets);
      expect(find.text('Quiet & Seeking Peace'), findsOneWidget);
    });

    testWidgets('Tapping a suggestion chip autofills challenge text field', (WidgetTester tester) async {
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

      // Step 1 -> Step 2
      await tester.enterText(find.byType(TextField), 'Maya');
      await tester.tap(find.text('Begin Sanctuary'));
      await tester.pumpAndSettle();

      // Step 2: Tap first mood card to auto-advance
      await tester.tap(find.text('Quiet & Seeking Peace'));
      // Allow 220ms auto-advance delay
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should now be on Step 3: Deep Friction (Type + Quick Chips)
      expect(find.text('3 / 7'), findsOneWidget);
      expect(find.text('CURRENT FRICTION'), findsOneWidget);

      // Tap 'Imposter syndrome at work' suggestion chip
      final chipFinder = find.text('Imposter syndrome at work');
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pump();

      // Verify the text field now contains the chip's text
      expect(find.textContaining('Imposter syndrome at work'), findsWidgets);
    });
  });
}
