import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/widgets/onboarding_animations.dart';

void main() {
  group('Onboarding Animations Suite', () {
    testWidgets('TypewriterText types progressively and completes',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypewriterText(
              text: 'Hello World',
              durationPerChar: const Duration(milliseconds: 20),
              initialDelay: Duration.zero,
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Initially, text begins typing
      await tester.pump(const Duration(milliseconds: 50));
      expect(completed, isFalse);

      // Advance time beyond completion
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Hello World'), findsOneWidget);
      expect(completed, isTrue);
    });

    testWidgets('TypewriterText skipToEnd works on tap',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypewriterText(
              text: 'Tap to Skip Typing',
              durationPerChar: const Duration(milliseconds: 50),
              initialDelay: const Duration(milliseconds: 100),
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Before initial delay, text is not yet complete
      await tester.pump(const Duration(milliseconds: 20));
      expect(completed, isFalse);

      // Tap on the typewriter text to skip
      await tester.tap(find.byType(TypewriterText));
      await tester.pump();

      expect(completed, isTrue);
      expect(find.text('Tap to Skip Typing'), findsOneWidget);
    });

    testWidgets('BottomPopItem animates child into place with stagger',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                BottomPopItem(
                  index: 0,
                  baseDelay: Duration(milliseconds: 100),
                  staggerDelay: Duration(milliseconds: 50),
                  child: Text('Option 1'),
                ),
                BottomPopItem(
                  index: 1,
                  baseDelay: Duration(milliseconds: 100),
                  staggerDelay: Duration(milliseconds: 50),
                  child: Text('Option 2'),
                ),
              ],
            ),
          ),
        ),
      );

      // Right at start, opacity is 0
      final opacityFinder = find.byType(Opacity);
      expect(opacityFinder, findsNWidgets(2));
      Opacity op1 = tester.widget(opacityFinder.first);
      expect(op1.opacity, equals(0.0));

      // After 100ms, item 0 timer fires
      await tester.pump(const Duration(milliseconds: 100));
      // Advance animation frame
      await tester.pump(const Duration(milliseconds: 80));
      op1 = tester.widget(opacityFinder.first);
      expect(op1.opacity, greaterThan(0.0));

      // After settling, all items are fully visible
      await tester.pumpAndSettle();
      final finalOpacities = tester.widgetList<Opacity>(find.byType(Opacity));
      for (var op in finalOpacities) {
        expect(op.opacity, equals(1.0));
      }
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
    });
  });
}
