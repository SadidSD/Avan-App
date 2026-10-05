import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/models/playlist.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/widgets/playlist_card.dart';
import 'package:avan_app/widgets/playlist_tracklist_sheet.dart';
import 'package:avan_app/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaylistCard & Tracklist PRO Badge Display Tests', () {
    late Playlist proPlaylist;
    late Playlist freePlaylist;

    setUp(() {
      proPlaylist = allPlaylists.firstWhere((p) => p.isPremium);
      freePlaylist = allPlaylists.firstWhere((p) => !p.isPremium);
    });

    testWidgets('Non-premium user: Pro card displays PRO and lock icon, Free card displays FREE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PlaylistCard(
                  playlist: proPlaylist,
                  accentColor: AppColors.growthAccent,
                  isPremiumUser: false,
                ),
                PlaylistCard(
                  playlist: freePlaylist,
                  accentColor: AppColors.growthAccent,
                  isPremiumUser: false,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify PRO badge is visible for non-premium user on pro card
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Verify FREE badge is visible on free card
      expect(find.text('FREE'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('Premium user: Pro card HIDES PRO badge and lock icon completely',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PlaylistCard(
                  playlist: proPlaylist,
                  accentColor: AppColors.growthAccent,
                  isPremiumUser: true,
                ),
                PlaylistCard(
                  playlist: freePlaylist,
                  accentColor: AppColors.growthAccent,
                  isPremiumUser: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify PRO badge and lock icon are completely hidden above pro card
      expect(find.text('PRO'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      // Verify FREE badge remains on free card
      expect(find.text('FREE'), findsOneWidget);
    });

    testWidgets('AppProvider context reactivity: Toggling premium hides PRO badge dynamically',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'is_premium': false});
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: MaterialApp(
            home: Scaffold(
              body: PlaylistCard(
                playlist: proPlaylist,
                accentColor: AppColors.growthAccent,
              ),
            ),
          ),
        ),
      );

      // Before buying premium: shows PRO
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Simulate purchasing premium
      await appProvider.setPremium(true);
      await tester.pumpAndSettle();

      // After buying premium: PRO badge is gone!
      expect(find.text('PRO'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });

    testWidgets('PlaylistTracklistSheet shows UNLOCKED ✨ instead of PRO 🔒 after purchase',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'premiumStatus': true});
      final appProvider = AppProvider();
      await appProvider.loadState();
      await appProvider.setPremium(true);
      final audioProvider = AudioProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppProvider>.value(value: appProvider),
            ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    PlaylistTracklistSheet.show(
                      context: context,
                      playlist: proPlaylist,
                      accentColor: AppColors.growthAccent,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify it does NOT show PRO 🔒
      expect(find.text('PRO 🔒'), findsNothing);
      // Verify it displays UNLOCKED ✨
      expect(find.text('UNLOCKED ✨'), findsOneWidget);
      // Verify action button shows Play Full Session instead of Unlock with PRO
      expect(find.text('Play Full Session'), findsOneWidget);
      expect(find.text('Unlock with PRO'), findsNothing);

      audioProvider.dispose();
    });
  });
}
