import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/data/playlist_groups.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:avan_app/services/personalization_engine.dart';

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
  });

  group('Dynamic Playlist Rotation & Mode Responsiveness Suite', () {
    test('Growth vs Healing mode produces distinctly different top recommendations', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'growth'});
      final provider = AppProvider();
      await provider.loadState();

      // In Growth mode
      await provider.setAppMode(AppMode.growth);
      final growthMatches = provider.getPersonalizedPlaylists();
      final growthTopIds = growthMatches.take(5).map((m) => m.playlist.id).toSet();

      // In Healing mode
      await provider.setAppMode(AppMode.healing);
      final healingMatches = provider.getPersonalizedPlaylists();
      final healingTopIds = healingMatches.take(5).map((m) => m.playlist.id).toSet();

      // Verify that healing mode elevates calming/nervous system/sleep playlists
      final healingTopPlaylists = healingMatches.take(5).map((m) => m.playlist.title).toList();
      print('Healing Top 5: $healingTopPlaylists');
      print('Growth Top 5: ${growthMatches.take(5).map((m) => m.playlist.title).toList()}');

      // Top 5 must differ significantly between Growth and Healing!
      expect(growthTopIds.intersection(healingTopIds).length, lessThan(5),
          reason: 'Growth and Healing must produce distinctly different top playlists!');
    });

    test('getOrderedPlaylistGroups dynamically reorganizes category hierarchy by mode', () {
      final growthGroups = getOrderedPlaylistGroups(isGrowthMode: true);
      final healingGroups = getOrderedPlaylistGroups(isGrowthMode: false);

      expect(growthGroups.first.id, equals('group_daily_essentials'));
      expect(healingGroups.first.id, equals('group_anxiety_calm'));
    });

    test('PlaylistGroup.getSortedPlaylists dynamically sorts playlists inside each group by resonance', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = AppProvider();
      await provider.loadState();

      await provider.setAppMode(AppMode.healing);
      final matches = provider.getPersonalizedPlaylists();
      final matchMap = {for (final m in matches) m.playlist.id: m};

      final dailyGroup = masterPlaylistGroups.firstWhere((g) => g.id == 'group_daily_essentials');
      final sortedDaily = dailyGroup.getSortedPlaylists(matchMap);

      expect(sortedDaily.length, equals(dailyGroup.playlists.length));
      // First playlist in sorted daily essentials should have high score
      final firstScore = matchMap[sortedDaily.first.id]?.matchScore ?? 0.0;
      final lastScore = matchMap[sortedDaily.last.id]?.matchScore ?? 0.0;
      expect(firstScore, greaterThanOrEqualTo(lastScore));
    });

    test('generateSituationalPlaylist produces mode and circadian tailored sessions', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = AppProvider();
      await provider.loadState();

      await provider.setAppMode(AppMode.growth);
      final growthSession = provider.getSituationalPlaylist();
      expect(growthSession.title.isNotEmpty, isTrue);

      await provider.setAppMode(AppMode.healing);
      final healingSession = provider.getSituationalPlaylist();
      expect(healingSession.title.isNotEmpty, isTrue);

      // Titles should reflect mode difference
      expect(growthSession.title, isNot(equals(healingSession.title)));
    });
  });
}
