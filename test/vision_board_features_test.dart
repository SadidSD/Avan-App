import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/models/vision_board.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/vision_board/vision_board_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vision Board Advanced Features Tests', () {
    late AppProvider appProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appProvider = AppProvider();
      await appProvider.loadState();
      await appProvider.addGoalBlock(
        GoalBlock(
          id: 'test_1',
          title: 'My Dream Vacation',
          category: 'Travel',
          bgImageUrl: 'assets/images/dopamine_mountain_lake.jpg',
          tintValue: 0xFF8A85A0,
          quote: 'Exploring the world with wonder.',
          targetDate: 'Summer 2026',
        ),
      );
      await appProvider.addGoalBlock(
        GoalBlock(
          id: 'test_2',
          title: 'Launch My Studio',
          category: 'Career',
          bgImageUrl: 'assets/images/creative_studio_canvas.jpg',
          tintValue: 0xFFFFD700,
          quote: 'Creating meaningful impact every day.',
          targetDate: 'Dec 2026',
        ),
      );
    });

    test('reorderGoalBlocks moves blocks correctly', () async {
      final initialFirstTitle = appProvider.activeVisionBoard.blocks[0].title;
      final initialSecondTitle = appProvider.activeVisionBoard.blocks[1].title;

      await appProvider.reorderGoalBlocks(0, 1);

      expect(appProvider.activeVisionBoard.blocks[0].title, initialSecondTitle);
      expect(appProvider.activeVisionBoard.blocks[1].title, initialFirstTitle);
    });

    test('toggleGoalManifested flips isManifested state', () async {
      final blockId = appProvider.activeVisionBoard.blocks[0].id;
      expect(appProvider.activeVisionBoard.blocks[0].isManifested, false);

      await appProvider.toggleGoalManifested(blockId);
      expect(appProvider.activeVisionBoard.blocks[0].isManifested, true);

      await appProvider.toggleGoalManifested(blockId);
      expect(appProvider.activeVisionBoard.blocks[0].isManifested, false);
    });

    test('duplicateSavedBoard clones board correctly', () async {
      await appProvider.saveActiveBoardAsNew('Master Board');
      expect(appProvider.savedVisionBoards.length, 1);

      final savedId = appProvider.savedVisionBoards.first.id;
      await appProvider.duplicateSavedBoard(savedId);

      expect(appProvider.savedVisionBoards.length, 2);
      expect(appProvider.savedVisionBoards.any((b) => b.title.contains('Master Board (Copy)')), true);
    });

    testWidgets('VisionBoardTab renders card styles and manifested state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Set block 0 to polaroid and manifested
      final b0 = appProvider.activeVisionBoard.blocks[0].copyWith(
        cardStyle: 'polaroid',
        isManifested: true,
      );
      // Set block 1 to bold editorial
      final b1 = appProvider.activeVisionBoard.blocks[1].copyWith(
        cardStyle: 'bold',
        targetDate: '2026-12-31',
      );
      await appProvider.updateGoalBlock(b0.id, b0);
      await appProvider.updateGoalBlock(b1.id, b1);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: VisionBoardTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify titles are present
      expect(find.text(b0.title), findsOneWidget);
      expect(find.text(b1.title.toUpperCase()), findsOneWidget);

      // Verify Polaroid manifested tag
      expect(find.text('✨ Done'), findsOneWidget);
    });

    testWidgets('VisionBoardTab opens Manifestation Slideshow Modal', (WidgetTester tester) async {
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

      // Tap Visualize button in AppBar
      final visualizeBtn = find.byTooltip('Manifestation Meditation Mode');
      expect(visualizeBtn, findsOneWidget);
      await tester.tap(visualizeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify meditation screen elements
      expect(find.text('Inhale slowly... Feel the gratitude of this reality as already yours.'), findsOneWidget);
      expect(find.byTooltip('528Hz Solfeggio Healing Sound'), findsOneWidget);

      // Exit meditation
      await tester.tap(find.byTooltip('Exit Meditation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
