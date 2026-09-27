import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/widgets/mode_toggle_pill.dart';
import 'package:avan_app/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModeTogglePill Widget Tests', () {
    testWidgets('Renders Growth and Healing segments with correct initial state',
        (WidgetTester tester) async {
      AppMode selectedMode = AppMode.growth;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModeTogglePill(
                currentMode: selectedMode,
                onModeChanged: (mode) => selectedMode = mode,
              ),
            ),
          ),
        ),
      );

      expect(find.text('🌿 Growth'), findsOneWidget);
      expect(find.text('🌊 Healing'), findsOneWidget);

      // Verify tapping Healing switches to Healing mode
      await tester.tap(find.text('🌊 Healing'));
      await tester.pump();

      expect(selectedMode, equals(AppMode.healing));
    });

    testWidgets('Tapping Growth while in Healing switches back to Growth',
        (WidgetTester tester) async {
      AppMode selectedMode = AppMode.healing;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: ModeTogglePill(
                    currentMode: selectedMode,
                    onModeChanged: (mode) {
                      setState(() {
                        selectedMode = mode;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(selectedMode, equals(AppMode.healing));

      // Tap Growth
      await tester.tap(find.text('🌿 Growth'));
      await tester.pumpAndSettle();

      expect(selectedMode, equals(AppMode.growth));

      // Tap Growth again when already on Growth -> should stay Growth
      await tester.tap(find.text('🌿 Growth'));
      await tester.pumpAndSettle();

      expect(selectedMode, equals(AppMode.growth));
    });
  });
}
