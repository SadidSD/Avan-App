import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/screens/onboarding/emotional_onboarding_screen.dart';

void main() {
  testWidgets('EmotionalOnboardingScreen renders Screen 1 and displays AVAN', (WidgetTester tester) async {
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

    // Should find the AVAN brandmark and Begin Sanctuary CTA
    expect(find.text('AVAN'), findsWidgets);
    expect(find.text('Begin Sanctuary'), findsOneWidget);
    expect(find.text('YOUR IDENTITY'), findsOneWidget);
  });
}
