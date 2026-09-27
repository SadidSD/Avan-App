import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/services/audio_engine_service.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/player/player_screen.dart';
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (MethodCall methodCall) async => true,
    );
  });

  Widget buildTestPlayer(AudioProvider audioProvider, AppProvider appProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
        ChangeNotifierProvider<AppProvider>.value(value: appProvider),
      ],
      child: const MaterialApp(
        home: PlayerScreen(),
      ),
    );
  }

  group('PlayerScreen Mixer Highlight Tests (Option A)', () {
    testWidgets('Displays top-bar badge and interactive capsule when soundscape is active',
        (WidgetTester tester) async {
      final audioProvider = AudioProvider();
      final appProvider = AppProvider();

      final testPlaylist = allPlaylists.first;
      audioProvider.openPlaylist(testPlaylist);

      await tester.pumpWidget(buildTestPlayer(audioProvider, appProvider));
      await tester.pump();

      // Verify top-bar mixer button exists
      final topBarMixerFinder = find.byKey(const ValueKey('top_bar_mixer_button'));
      expect(topBarMixerFinder, findsOneWidget);

      // Verify interactive mixer capsule exists
      final capsuleFinder = find.byKey(const ValueKey('interactive_mixer_capsule'));
      expect(capsuleFinder, findsOneWidget);

      // Verify that the capsule displays the active sound name
      if (audioProvider.currentSound != AmbientSound.none) {
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Tap to adjust soundscape volume & gap pacing'), findsOneWidget);
      } else {
        expect(find.text('Audio & Soundscape Mixer'), findsWidgets);
      }

      // Tap the interactive capsule to open mixer sheet
      await tester.tap(capsuleFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Sheet title should appear
      expect(find.text('Audio & Ambient Mixer'), findsOneWidget);
      expect(find.text('Voice Volume'), findsOneWidget);
      expect(find.text('Ambient Soundscape Volume'), findsOneWidget);
      expect(find.text('Affirmation Gap Pacing'), findsOneWidget);

      audioProvider.dispose();
    });

    testWidgets('Tapping top-bar mixer badge also opens the audio & ambient mixer sheet',
        (WidgetTester tester) async {
      final audioProvider = AudioProvider();
      final appProvider = AppProvider();

      final testPlaylist = allPlaylists.first;
      audioProvider.openPlaylist(testPlaylist);

      await tester.pumpWidget(buildTestPlayer(audioProvider, appProvider));
      await tester.pump();

      final topBarMixerFinder = find.byKey(const ValueKey('top_bar_mixer_button'));
      await tester.tap(topBarMixerFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Audio & Ambient Mixer'), findsOneWidget);

      audioProvider.dispose();
    });
  });
}
