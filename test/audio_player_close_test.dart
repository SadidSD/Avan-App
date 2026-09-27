import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/widgets/audio_player_bar.dart';
import 'package:avan_app/data/playlists_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') return <String, dynamic>{};
        return true;
      },
    );
  });

  group('AudioPlayerBar Close / Dismiss Tests', () {
    test('AudioProvider.closePlayer resets playlist and stops playback', () {
      final audioProvider = AudioProvider();
      final testPlaylist = allPlaylists.first;

      audioProvider.openPlaylist(testPlaylist);
      expect(audioProvider.currentPlaylist, isNotNull);
      expect(audioProvider.isPlayerOpen, isTrue);

      audioProvider.closePlayer();
      expect(audioProvider.currentPlaylist, isNull);
      expect(audioProvider.isPlayerOpen, isFalse);
      expect(audioProvider.currentAffirmation, isNull);

      audioProvider.dispose();
    });

    testWidgets('AudioPlayerBar displays close button and tapping it calls closePlayer',
        (WidgetTester tester) async {
      final audioProvider = AudioProvider();
      final appProvider = AppProvider();

      final testPlaylist = allPlaylists.first;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
            ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AudioPlayerBar(),
            ),
          ),
        ),
      );

      // Initially no playlist is loaded, AudioPlayerBar should be empty
      expect(find.byKey(const ValueKey('close_player_button')), findsNothing);

      // Open a playlist
      audioProvider.openPlaylist(testPlaylist);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Mini player and close button should now be visible
      expect(find.byKey(const ValueKey('close_player_button')), findsOneWidget);
      expect(find.text(testPlaylist.title), findsOneWidget);

      // Tap the close button
      await tester.tap(find.byKey(const ValueKey('close_player_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // AudioProvider should now have null currentPlaylist
      expect(audioProvider.currentPlaylist, isNull);
      expect(audioProvider.isPlayerOpen, isFalse);

      // AudioPlayerBar should now be dismissed / gone
      expect(find.byKey(const ValueKey('close_player_button')), findsNothing);
      expect(find.text(testPlaylist.title), findsNothing);

      audioProvider.dispose();
    });
  });
}
