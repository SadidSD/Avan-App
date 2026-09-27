import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/vision_board/vision_board_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vision Board Template Tests', () {
    late AppProvider appProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appProvider = AppProvider();
      await appProvider.loadState();
    });

    test('Initial active board starts clean without hardcoded demo cards', () {
      expect(appProvider.activeVisionBoard.blocks.isEmpty, true);
    });

    test('setActiveTemplate updates template cleanly without demo cards', () async {
      await appProvider.setActiveTemplate('6 Blocks');
      expect(appProvider.activeVisionBoard.template, '6 Blocks');
      expect(appProvider.activeVisionBoard.blocks.isEmpty, true);

      await appProvider.setActiveTemplate('8 Blocks');
      expect(appProvider.activeVisionBoard.template, '8 Blocks');
      expect(appProvider.activeVisionBoard.blocks.isEmpty, true);

      await appProvider.setActiveTemplate('2 Blocks');
      expect(appProvider.activeVisionBoard.template, '2 Blocks');
      expect(appProvider.activeVisionBoard.blocks.isEmpty, true);
    });

    testWidgets('VisionBoardTab renders correct number of slots for templates', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: VisionBoardTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially 4 blocks template selected -> 4 slots
      expect(find.text('4 Blocks'), findsOneWidget);
      expect(find.text('6 Blocks'), findsOneWidget);
      expect(find.text('8 Blocks'), findsOneWidget);
      expect(find.text('Add Goal #1'), findsOneWidget);
      expect(find.text('Add Goal #4'), findsOneWidget);

      // Tap '6 Blocks' chip
      await tester.tap(find.text('6 Blocks'));
      await tester.pumpAndSettle();

      expect(appProvider.activeVisionBoard.template, '6 Blocks');
      expect(find.text('Add Goal #1'), findsOneWidget);
      expect(find.text('Add Goal #6'), findsOneWidget);

      // Tap '8 Blocks' chip
      await tester.tap(find.text('8 Blocks'));
      await tester.pumpAndSettle();

      expect(appProvider.activeVisionBoard.template, '8 Blocks');
      expect(find.text('Add Goal #8', skipOffstage: false), findsOneWidget);

      // Tap '2 Blocks' chip
      await tester.tap(find.text('2 Blocks'));
      await tester.pumpAndSettle();
      expect(appProvider.activeVisionBoard.template, '2 Blocks');
      expect(find.text('Add Goal #2'), findsOneWidget);
    });
  });
}
