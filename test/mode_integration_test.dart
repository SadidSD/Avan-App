import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/data/playlist_groups.dart';
import 'package:avan_app/theme/app_colors.dart';

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

  group('Growth / Healing Mode Integration Tests', () {
    test('Mode toggle switches state, accent colors, and playlist rankings', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'growth'});

      final appProvider = AppProvider();
      await appProvider.loadState();

      expect(appProvider.isGrowthMode, isTrue);
      expect(AppColors.accentForMode(appProvider.isGrowthMode), equals(AppColors.growthAccent));

      final growthPlaylists = appProvider.getPersonalizedPlaylists();
      expect(growthPlaylists.isNotEmpty, isTrue);
      final growthTopIds = growthPlaylists.take(5).map((m) => m.playlist.id).toSet();

      // Switch to Healing mode
      await appProvider.setAppMode(AppMode.healing);

      expect(appProvider.isGrowthMode, isFalse);
      expect(appProvider.appModeSetting, equals(AppMode.healing));
      expect(AppColors.accentForMode(appProvider.isGrowthMode), equals(AppColors.healingAccent));

      final healingPlaylists = appProvider.getPersonalizedPlaylists();
      expect(healingPlaylists.isNotEmpty, isTrue);
      final healingTopIds = healingPlaylists.take(5).map((m) => m.playlist.id).toSet();

      // The top 5 playlists must be distinct between Growth and Healing modes
      expect(growthTopIds.intersection(healingTopIds).length, lessThan(3),
          reason: 'Growth and Healing modes must yield distinctly different top recommendations');

      // Verify group ordering is distinct
      final growthGroups = getOrderedPlaylistGroups(isGrowthMode: true);
      final healingGroups = getOrderedPlaylistGroups(isGrowthMode: false);
      expect(growthGroups.first.id, isNot(equals(healingGroups.first.id)),
          reason: 'Primary group must differ between Growth and Healing');

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('appMode'), equals('healing'));

      // Switch back to Growth mode
      await appProvider.setAppMode(AppMode.growth);
      expect(appProvider.isGrowthMode, isTrue);
      expect(prefs.getString('appMode'), equals('growth'));
    });
  });
}
