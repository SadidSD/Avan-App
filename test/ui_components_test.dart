import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/widgets/avan_app_bar.dart';
import 'package:avan_app/widgets/empty_state_card.dart';
import 'package:avan_app/widgets/mood_selector_row.dart';
import 'package:avan_app/screens/widgets_preview/widgets_tab.dart';
import 'package:avan_app/screens/profile/profile_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_widget_type': 'Medium (2x1)',
      'pref_widget_content': 'Daily Affirmation',
      'pref_widget_theme': 'Dark Espresso',
      'pref_widget_refresh': 'Every 6 Hours',
      'pref_widget_font': 'Elegant Serif',
      'selectedMood': 'Peaceful',
    });
  });

  group('Reusable UI Components Tests', () {
    testWidgets('AvanAppBar renders title, back button, and actions', (tester) async {
      bool backTapped = false;
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AvanAppBar(
              title: 'Sacred Sanctuary',
              showBackButton: true,
              onBack: () => backTapped = true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => actionTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sacred Sanctuary'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      expect(backTapped, isTrue);

      await tester.tap(find.byIcon(Icons.settings));
      expect(actionTapped, isTrue);
    });

    testWidgets('EmptyStateCard renders icon, texts, and triggers action callback', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateCard(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on any affirmation to save it here for daily remembrance.',
              actionText: 'Explore Wisdom',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No Favorites Yet'), findsOneWidget);
      expect(
        find.text('Tap the heart icon on any affirmation to save it here for daily remembrance.'),
        findsOneWidget,
      );
      expect(find.text('Explore Wisdom'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.text('Explore Wisdom'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('MoodSelectorRow displays moods and calls onMoodSelected on tap', (tester) async {
      String selected = 'Calm';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MoodSelectorRow(
                  selectedMood: selected,
                  onMoodSelected: (newMood) {
                    setState(() => selected = newMood);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('HOW IS YOUR HEART TODAY?'), findsOneWidget);
      expect(find.text('Calm'), findsOneWidget);
      expect(find.text('Anxious'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);

      // Tap on 'Anxious'
      await tester.tap(find.text('Anxious'));
      await tester.pumpAndSettle();

      expect(selected, equals('Anxious'));

      // Tap 'Clear'
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(selected, equals(''));
    });

    testWidgets('WidgetsTab renders without errors and loads dynamic provider state', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: WidgetsTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Widgets Studio'), findsOneWidget);
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('Widget Options'), findsOneWidget);
      expect(find.text('Save & Add Widget to Screen ✨'), findsOneWidget);
    });

    testWidgets('WidgetsTab allows writing and previewing custom affirmations', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: WidgetsTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dropdown and select Custom Affirmation
      await tester.tap(find.text('Daily Affirmation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom Affirmation').last);
      await tester.pumpAndSettle();

      expect(find.text('Write Your Custom Affirmation ✍️'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Type a custom mantra
      await tester.enterText(find.byType(TextField), 'I am unstoppable and filled with peace.');
      await tester.pumpAndSettle();

      expect(find.text('"I am unstoppable and filled with peace."'), findsOneWidget);
    });

    testWidgets('ProfileTab renders Account & Cloud Backup and Supabase Sign-In card', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: Scaffold(body: ProfileTab()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Supabase Sign-In prompt when user is not signed in
      expect(find.text('Account & Cloud Backup'), findsOneWidget);
      expect(find.text('Sign In / Register'), findsOneWidget);
      expect(find.text('Supabase Cloud Vault / Sync ☁️'), findsOneWidget);
    });
  });
}
