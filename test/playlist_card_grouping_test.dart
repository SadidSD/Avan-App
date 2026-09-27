import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avan_app/data/playlist_groups.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/screens/home/home_tab.dart';
import 'package:avan_app/widgets/playlist_card.dart';
import 'package:avan_app/widgets/playlist_tracklist_sheet.dart';
import 'package:avan_app/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Playlist Grouping & Hierarchy Tests', () {
    test('All 63 playlists are properly registered across the 9 master groups', () {
      expect(masterPlaylistGroups.length, equals(9));

      final Set<String> registeredIds = {};
      for (final group in masterPlaylistGroups) {
        expect(group.id.isNotEmpty, isTrue);
        expect(group.title.isNotEmpty, isTrue);
        expect(group.emoji.isNotEmpty, isTrue);
        expect(group.description.isNotEmpty, isTrue);
        expect(group.playlistIds.isNotEmpty, isTrue);

        final playlists = group.playlists;
        expect(playlists.length, equals(group.playlistIds.length));

        for (final p in playlists) {
          registeredIds.add(p.id);
        }
      }

      // Verify all 63 playlists are represented
      for (final p in allPlaylists) {
        expect(
          registeredIds.contains(p.id),
          isTrue,
          reason: 'Playlist ${p.id} (${p.title}) must be part of at least one group',
        );
      }
    });

    test('findGroupByPlaylistId accurately finds the correct parent group', () {
      final morningGroup = findGroupByPlaylistId('pl_morning_neural');
      expect(morningGroup, isNotNull);
      expect(morningGroup!.id, equals('group_daily_essentials'));

      final panicGroup = findGroupByPlaylistId('pl_panic_release');
      expect(panicGroup, isNotNull);
      expect(panicGroup!.id, equals('group_anxiety_calm'));

      final founderGroup = findGroupByPlaylistId('pl_founder_resilience');
      expect(founderGroup, isNotNull);
      expect(founderGroup!.id, equals('group_career_agency'));

      final adhdGroup = findGroupByPlaylistId('pl_adhd_reset');
      expect(adhdGroup, isNotNull);
      expect(adhdGroup!.id, equals('group_focus_neurodiversity'));
    });

    testWidgets('PlaylistCard displays title, duration, track count, and handles tap',
        (WidgetTester tester) async {
      final testPlaylist = allPlaylists.first;
      bool cardTapped = false;
      bool playTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlaylistCard(
                playlist: testPlaylist,
                accentColor: AppColors.growthAccent,
                matchPercent: '95% Match',
                width: 170,
                onTap: () => cardTapped = true,
                onPlayTap: () => playTapped = true,
              ),
            ),
          ),
        ),
      );

      // Verify playlist title is rendered
      expect(find.text(testPlaylist.title), findsOneWidget);

      // Verify duration and track count are rendered
      expect(find.text(testPlaylist.duration), findsOneWidget);
      expect(find.text('${testPlaylist.affirmations.length} tracks'), findsOneWidget);

      // Verify match percentage badge is rendered
      expect(find.text('95% Match'), findsOneWidget);

      // Tap card
      await tester.tap(find.byType(PlaylistCard));
      expect(cardTapped, isTrue);

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      expect(playTapped, isTrue);
    });

    testWidgets('HomeTab renders PlaylistCards and Group Chips',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'onboardingStatus': true});
      tester.view.physicalSize = const Size(500, 1500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appProvider = AppProvider();
      final audioProvider = AudioProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppProvider>.value(value: appProvider),
            ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
          ],
          child: const MaterialApp(
            home: HomeTab(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify PlaylistCards are rendered on the Home Tab
      expect(find.byType(PlaylistCard), findsWidgets);

      // Verify Group selector chips are present
      expect(find.text('All Groups'), findsOneWidget);
      expect(find.text('Daily Essentials'), findsOneWidget);
      expect(find.text('Anxiety & Nervous System'), findsOneWidget);

      // Tap a PlaylistCard to open tracklist sheet
      final firstCard = find.byType(PlaylistCard).first;
      await tester.tap(firstCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify PlaylistTracklistSheet opened
      expect(find.byType(PlaylistTracklistSheet), findsOneWidget);
      expect(find.text('SESSION TRACKS'), findsOneWidget);

      audioProvider.dispose();
    });
  });
}
