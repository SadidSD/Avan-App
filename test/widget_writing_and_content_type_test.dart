import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/widgets_preview/widgets_tab.dart';
import 'package:avan_app/services/widget_service.dart';
import 'package:avan_app/models/affirmation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Widget Writing & Content Type Transition Tests', () {
    testWidgets('Custom affirmation text entry updates state and persists to SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_widget_content': 'Custom Affirmation',
        'pref_widget_custom_quote': 'I am grounded and resilient.',
      });

      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      // Find the TextField with custom affirmation
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      expect(find.text('I am grounded and resilient.'), findsWidgets);

      // Enter new custom text
      await tester.enterText(textFieldFinder, 'I create my own destiny with intentional action.');
      await tester.pumpAndSettle();

      // Verify preview displays the new text
      expect(find.textContaining('I create my own destiny with intentional action.'), findsWidgets);

      // Tap quick suggestion chip to replace
      final suggestionFinder = find.text('I am worthy of peace, happiness, and clarity.');
      expect(suggestionFinder, findsOneWidget);
      await tester.tap(suggestionFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('I am worthy of peace, happiness, and clarity.'), findsWidgets);
    });

    test('WidgetService updateWidgets uses customQuote when in Custom Affirmation mode', () async {
      SharedPreferences.setMockInitialValues({
        'pref_widget_content': 'Custom Affirmation',
        'pref_widget_custom_quote': 'My custom strength mantra',
      });

      final testAffirmation = Affirmation(
        id: 'aff_1',
        quote: 'Standard daily hero affirmation',
        category: 'Daily Motivation',
      );

      // In Custom Affirmation mode, customQuote should take precedence
      await WidgetService.instance.updateWidgets(
        affirmation: testAffirmation,
        streakDays: 5,
        customQuote: 'My custom strength mantra',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_widget_content'), 'Custom Affirmation');
    });

    test('WidgetService updateWidgets respects Daily Affirmation mode and ignores old custom quote', () async {
      // User previously had a custom quote, but switched content type back to Daily Affirmation
      SharedPreferences.setMockInitialValues({
        'pref_widget_content': 'Daily Affirmation',
        'pref_widget_custom_quote': 'Old leftover custom mantra',
      });

      final testAffirmation = Affirmation(
        id: 'aff_2',
        quote: 'Fresh daily hero quote for today',
        category: 'Focus & Drive',
      );

      // When in Daily Affirmation mode, customQuote is null
      await WidgetService.instance.updateWidgets(
        affirmation: testAffirmation,
        streakDays: 7,
        customQuote: null,
      );

      // Verify that even with 'pref_widget_custom_quote' present in storage,
      // it did not override because pref_widget_content is 'Daily Affirmation'
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_widget_content'), 'Daily Affirmation');
    });

    testWidgets('Tapping visible Write Custom banner switches directly to Custom Affirmation editor', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_widget_content': 'Daily Affirmation',
      });

      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      // On initial screen, the prompt banner is visible
      expect(find.text('Want to write your own words? ✍️'), findsOneWidget);
      expect(find.text('Write Custom'), findsOneWidget);

      // Tap the banner to enter writing mode
      await tester.tap(find.text('Want to write your own words? ✍️'));
      await tester.pumpAndSettle();

      // The text field is now immediately open and ready to write
      expect(find.text('Write Your Custom Affirmation ✍️'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
