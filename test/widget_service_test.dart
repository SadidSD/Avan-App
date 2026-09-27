import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/services/widget_service.dart';
import 'package:avan_app/models/affirmation.dart';
import 'package:avan_app/providers/app_provider.dart';

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

  group('WidgetService Unit Tests', () {
    test('WidgetService instance is a singleton', () {
      final s1 = WidgetService.instance;
      final s2 = WidgetService.instance;
      expect(identical(s1, s2), isTrue);
    });

    test('WidgetService color resolvers resolve correctly for themes', () {
      final service = WidgetService.instance;

      // Background colors
      expect(service.getBackgroundColor('Dark Espresso'), equals(const Color(0xFF251A14)));
      expect(service.getBackgroundColor('Soft Beige'), equals(const Color(0xFFFFF8F2)));
      expect(service.getBackgroundColor('Warm Gradient'), equals(const Color(0xFFFBF0E6)));
      expect(service.getBackgroundColor('Minimal White'), equals(const Color(0xFFFFFFFF)));

      // Primary text colors
      expect(service.getPrimaryTextColor('Dark Espresso'), equals(const Color(0xFFF5E6D3)));
      expect(service.getPrimaryTextColor('Soft Beige'), equals(const Color(0xFF3D2C1E)));
      expect(service.getPrimaryTextColor('Minimal White'), equals(const Color(0xFF3D2C1E)));

      // Secondary text colors
      expect(service.getSecondaryTextColor('Dark Espresso'), equals(const Color(0xFFB8A089)));
      expect(service.getSecondaryTextColor('Soft Beige'), equals(const Color(0xFF8B7355)));
    });

    test('WidgetService font family resolver works', () {
      final service = WidgetService.instance;

      expect(service.getFontFamily('Elegant Serif'), equals('Cormorant Garamond'));
      expect(service.getFontFamily('Bold Rounded'), equals('Plus Jakarta Sans'));
      expect(service.getFontFamily('Clean Sans'), equals('Inter'));
    });

    test('WidgetPayload model serializes correctly', () {
      const payload = WidgetPayload(
        quote: 'I am capable and peaceful.',
        author: 'AVAN',
        category: 'Confidence',
        streakDays: 5,
        mood: 'Peaceful',
        theme: 'Dark Espresso',
        font: 'Elegant Serif',
        refreshFreq: 'Every 6 Hours',
      );

      final map = payload.toMap();
      expect(map['quote'], equals('I am capable and peaceful.'));
      expect(map['author'], equals('AVAN'));
      expect(map['category'], equals('Confidence'));
      expect(map['streakDays'], equals(5));
      expect(map['mood'], equals('Peaceful'));
      expect(map['theme'], equals('Dark Espresso'));
      expect(map['font'], equals('Elegant Serif'));
      expect(map['refreshFreq'], equals('Every 6 Hours'));
    });

    test('WidgetService.updateWidgets runs cleanly without unhandled errors', () async {
      final service = WidgetService.instance;
      final testAffirmation = Affirmation(
        id: 'test_widget_aff',
        quote: 'I am grounded, capable, and confident in all that I do.',
        category: 'Confidence',
        author: 'AVAN Test',
        embeddingVector: List.filled(16, 0.5),
      );

      await expectLater(
        service.updateWidgets(
          affirmation: testAffirmation,
          streakDays: 7,
          category: 'Confidence',
          mood: 'Grounded',
          theme: 'Dark Espresso',
          font: 'Elegant Serif',
          refreshFreq: 'Every 6 Hours',
        ),
        completes,
      );
    });

    test('AppProvider syncNativeWidgets updates without exception', () async {
      final provider = AppProvider();
      await provider.loadState();

      await expectLater(
        provider.syncNativeWidgets(),
        completes,
      );
    });
  });
}
