import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/widgets/glass_card.dart';
import 'package:avan_app/widgets/avan_app_bar.dart';

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

  group('Optimization & Performance Verification Tests', () {
    test('getAllGlobalAffirmations() returns identical memoized instance across multiple calls', () {
      final list1 = getAllGlobalAffirmations();
      final list2 = getAllGlobalAffirmations();
      final list3 = getAllGlobalAffirmations();

      expect(list1.isNotEmpty, isTrue);
      expect(identical(list1, list2), isTrue, reason: 'Consecutive calls must return the same cached instance');
      expect(identical(list2, list3), isTrue);
    });

    test('AppProvider getPersonalizedPlaylists() caches output and invalidates on mode/mood shift', () {
      final appProvider = AppProvider();

      final playlistsA1 = appProvider.getPersonalizedPlaylists();
      final playlistsA2 = appProvider.getPersonalizedPlaylists();

      expect(playlistsA1.isNotEmpty, isTrue);
      expect(identical(playlistsA1, playlistsA2), isTrue, reason: 'Must return cached reference without re-ranking 63 playlists');

      // Invalidate by switching mode
      appProvider.setAppMode(AppMode.healing);
      final playlistsHealing = appProvider.getPersonalizedPlaylists();

      expect(identical(playlistsA1, playlistsHealing), isFalse, reason: 'Cache must invalidate on mode switch');

      final playlistsHealing2 = appProvider.getPersonalizedPlaylists();
      expect(identical(playlistsHealing, playlistsHealing2), isTrue);

      // Invalidate by switching mood
      appProvider.setSelectedMood('Energized');
      final playlistsMood = appProvider.getPersonalizedPlaylists();
      expect(identical(playlistsHealing2, playlistsMood), isFalse, reason: 'Cache must invalidate on mood shift');
    });

    test('AppProvider getHeroAffirmation() & getSituationalPlaylist() memoize and invalidate correctly', () {
      final appProvider = AppProvider();

      final hero1 = appProvider.getHeroAffirmation();
      final hero2 = appProvider.getHeroAffirmation();
      expect(identical(hero1, hero2), isTrue, reason: 'Hero affirmation must be memoized');

      final situational1 = appProvider.getSituationalPlaylist();
      final situational2 = appProvider.getSituationalPlaylist();
      expect(identical(situational1, situational2), isTrue, reason: 'Situational playlist must be memoized');

      // Change mode
      appProvider.setAppMode(AppMode.healing);
      final heroHealing = appProvider.getHeroAffirmation();
      final situationalHealing = appProvider.getSituationalPlaylist();

      expect(identical(situational1, situationalHealing), isFalse, reason: 'Situational playlist must regenerate on mode switch');
    });

    testWidgets('GlassCard respects Android adaptive blur without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: const MaterialApp(
            home: Scaffold(
              body: GlassCard(
                accentColor: Colors.amber,
                child: Text('Performance Adaptive Glass'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Performance Adaptive Glass'), findsOneWidget);
    });

    testWidgets('AvanAppBar renders on Android platform without backdrop filter overhead', (WidgetTester tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: MaterialApp(
            home: Scaffold(
              appBar: AvanAppBar(
                title: 'High Performance Sanctuary',
              ),
            ),
          ),
        ),
      );

      expect(find.text('High Performance Sanctuary'), findsOneWidget);
    });
  });
}
