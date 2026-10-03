import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/screens/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen Typewriter Animation Tests', () {
    testWidgets('SplashScreen initializes with empty or initial characters and types avan', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      // Initially, during delay, 0 characters are visible
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(completed, isFalse);

      // Advance through delay (180ms) and typing (560ms)
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // After 800ms, typing is complete and 'AVAN' is fully rendered
      expect(find.text('AVAN'), findsOneWidget);

      // Advance through linger (450ms) and fade-out (550ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));

      expect(completed, isTrue);
    });

    testWidgets('Tapping SplashScreen skips animation immediately and triggers fade-out', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      expect(completed, isFalse);

      // Tap on screen to skip
      await tester.tap(find.byType(SplashScreen));
      await tester.pump();

      // Typing is immediately revealed
      expect(find.text('AVAN'), findsOneWidget);

      // Advance through fade-out (550ms)
      await tester.pump(const Duration(milliseconds: 600));
      expect(completed, isTrue);
    });
  });
}
