import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/models/playlist.dart';
import 'package:avan_app/models/journal_entry.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/data/playlists_data.dart';
import 'package:intl/intl.dart';

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

  group('Flaw Resolutions & Edge Cases Test Suite', () {
    test('AudioProvider.openCustomAudio with speakTts: false sets up custom playlist without speech', () {
      final audioProvider = AudioProvider();

      audioProvider.openCustomAudio(
        title: 'My Custom Voice',
        quote: 'Personal Voice Studio Recording • 15s',
        duration: '15s',
        speakTts: false,
      );

      expect(audioProvider.currentPlaylist, isNotNull);
      expect(audioProvider.currentPlaylist!.title, 'My Custom Voice');
      expect(audioProvider.isPlayerOpen, isTrue);
      // Because speakTts: false, TTS is not triggered and isPlaying remains false
      expect(audioProvider.isPlaying, isFalse);
    });

    test('AudioProvider pause() and stop() function cleanly', () {
      final audioProvider = AudioProvider();
      expect(() => audioProvider.pause(), returnsNormally);
      expect(() => audioProvider.stop(), returnsNormally);
    });

    test('Playlist.resolveValidAssetPath maps non-existent playlist paths to valid assets', () {
      const validAssets = {
        'assets/images/featured_meditation.jpg',
        'assets/images/onboarding_archway_sun.jpg',
        'assets/images/onboarding_girl_profile.jpg',
        'assets/images/onboarding_moon_clouds.jpg',
        'assets/images/sleep_story_night.jpg',
        'assets/images/morning_neural_activation.jpg',
        'assets/images/deep_work_flow.jpg',
        'assets/images/sleep_onset_scan.jpg',
        'assets/images/stress_reset_sos.jpg',
        'assets/images/gratitude_neuro.jpg',
        'assets/images/self_worth_found.jpg',
        'assets/images/panic_tension_rel.jpg',
        'assets/images/social_anxiety_calm.jpg',
        'assets/images/bedtime_rumination.jpg',
        'assets/images/emotional_flood_rec.jpg',
        'assets/images/breakup_shock_surv.jpg',
        'assets/images/nocontact_strength.jpg',
        'assets/images/worth_rebuild_kint.jpg',
        'assets/images/bereavement_candle.jpg',
        'assets/images/founder_resilience.jpg',
        'assets/images/exec_presence_clarity.jpg',
        'assets/images/imposter_syndrome_ant.jpg',
        'assets/images/lgbtq_self_acceptance.jpg',
        'assets/images/trans_identity_prism.jpg',
        'assets/images/cultural_identity_text.jpg',
        'assets/images/pregame_tunnel_focus.jpg',
        'assets/images/endurance_ridge_dawn.jpg',
        'assets/images/injury_recovery_fern.jpg',
        'assets/images/exam_study_clarity.jpg',
        'assets/images/antiprocrastination_desk.jpg',
        'assets/images/patient_parenting_nurs.jpg',
        'assets/images/caregiver_porch_rest.jpg',
        'assets/images/abundance_spring_gold.jpg',
        'assets/images/intuition_mountain_tarn.jpg',
        'assets/images/proud_sunrise_porch.jpg',
        'assets/images/adhd_hourglass_reset.jpg',
        'assets/images/rsd_blanket_cocoon.jpg',
        'assets/images/task_stepping_stones.jpg',
        'assets/images/sensory_felt_quiet.jpg',
        'assets/images/dopamine_bonsai_calm.jpg',
        'assets/images/chronic_pain_spring.jpg',
        'assets/images/freeze_to_flow_ice.jpg',
        'assets/images/inner_child_treehouse.jpg',
        'assets/images/anger_discharge_waves.jpg',
        'assets/images/boundary_orchard_gate.jpg',
        'assets/images/scarcity_seedling_hands.jpg',
        'assets/images/negotiation_skyline_poise.jpg',
        'assets/images/public_stage_spotlight.jpg',
        'assets/images/career_pivot_crossroads.jpg',
        'assets/images/lighthouse_storm_shield.jpg',
        'assets/images/solitude_cabin_hearth.jpg',
        'assets/images/divorce_sunlit_room.jpg',
        'assets/images/anxious_attachment_anchor.jpg',
        'assets/images/avoidant_courtyard_roses.jpg',
        'assets/images/social_trust_mugs.jpg',
        'assets/images/body_neutrality_pool.jpg',
        'assets/images/midnight_awakening_moon.jpg',
        'assets/images/postpartum_linen_calm.jpg',
        'assets/images/midlife_olive_tree.jpg',
        'assets/images/aging_teak_maple.jpg',
        'assets/images/dopamine_mountain_lake.jpg',
        'assets/images/evening_pen_candle.jpg',
        'assets/images/stoic_marble_bust.jpg',
        'assets/images/creative_studio_canvas.jpg',
        'assets/images/crisis_calm_center.jpg',
        'assets/images/ruthless_chess_king.jpg',
      };

      // 1. Sleep category (fallback)
      final sleepPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/deep_rest.jpg',
        category: 'Sleep & Rest',
        tags: ['sleep', 'rest'],
        title: 'Deep Rest & Slumber',
      );
      expect(sleepPath, 'assets/images/sleep_story_night.jpg');
      expect(validAssets.contains(sleepPath), isTrue);

      // Specific playlist #52
      final midnightPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/midnight_awakening.jpg',
        category: 'Sleep & Rest',
        tags: ['sleep', 'rest'],
        title: 'Midnight Awakening & Sleep Continuity',
      );
      expect(midnightPath, 'assets/images/midnight_awakening_moon.jpg');
      expect(validAssets.contains(midnightPath), isTrue);

      // 2. Anxiety / Panic category
      final panicPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/panic_release.jpg',
        category: 'Anxiety & Panic',
        tags: ['panic', 'somatic'],
        title: 'Panic & Physical Tension Release',
      );
      expect(panicPath, 'assets/images/panic_tension_rel.jpg');
      expect(validAssets.contains(panicPath), isTrue);

      // 3. Career / High Agency category
      final careerPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/founder.jpg',
        category: 'Career & Wealth',
        tags: ['founder', 'career'],
        title: 'Founder Resilience',
      );
      expect(careerPath, 'assets/images/founder_resilience.jpg');
      expect(validAssets.contains(careerPath), isTrue);

      // 4. Identity / Self-Compassion category
      final identityPath = Playlist.resolveValidAssetPath(
        rawPath: 'assets/images/playlists/imposter.jpg',
        category: 'Identity & Self-Compassion',
        tags: ['identity', 'compassion'],
        title: 'Imposter Syndrome',
      );
      expect(identityPath, 'assets/images/imposter_syndrome_ant.jpg');
      expect(validAssets.contains(identityPath), isTrue);
    });

    test('EVERY single playlist in allPlaylists now resolves to a verified asset on disk', () {
      const validAssets = {
        'assets/images/featured_meditation.jpg',
        'assets/images/onboarding_archway_sun.jpg',
        'assets/images/onboarding_girl_profile.jpg',
        'assets/images/onboarding_moon_clouds.jpg',
        'assets/images/sleep_story_night.jpg',
        'assets/images/morning_neural_activation.jpg',
        'assets/images/deep_work_flow.jpg',
        'assets/images/sleep_onset_scan.jpg',
        'assets/images/stress_reset_sos.jpg',
        'assets/images/gratitude_neuro.jpg',
        'assets/images/self_worth_found.jpg',
        'assets/images/panic_tension_rel.jpg',
        'assets/images/social_anxiety_calm.jpg',
        'assets/images/bedtime_rumination.jpg',
        'assets/images/emotional_flood_rec.jpg',
        'assets/images/breakup_shock_surv.jpg',
        'assets/images/nocontact_strength.jpg',
        'assets/images/worth_rebuild_kint.jpg',
        'assets/images/bereavement_candle.jpg',
        'assets/images/founder_resilience.jpg',
        'assets/images/exec_presence_clarity.jpg',
        'assets/images/imposter_syndrome_ant.jpg',
        'assets/images/lgbtq_self_acceptance.jpg',
        'assets/images/trans_identity_prism.jpg',
        'assets/images/cultural_identity_text.jpg',
        'assets/images/pregame_tunnel_focus.jpg',
        'assets/images/endurance_ridge_dawn.jpg',
        'assets/images/injury_recovery_fern.jpg',
        'assets/images/exam_study_clarity.jpg',
        'assets/images/antiprocrastination_desk.jpg',
        'assets/images/patient_parenting_nurs.jpg',
        'assets/images/caregiver_porch_rest.jpg',
        'assets/images/abundance_spring_gold.jpg',
        'assets/images/intuition_mountain_tarn.jpg',
        'assets/images/proud_sunrise_porch.jpg',
        'assets/images/adhd_hourglass_reset.jpg',
        'assets/images/rsd_blanket_cocoon.jpg',
        'assets/images/task_stepping_stones.jpg',
        'assets/images/sensory_felt_quiet.jpg',
        'assets/images/dopamine_bonsai_calm.jpg',
        'assets/images/chronic_pain_spring.jpg',
        'assets/images/freeze_to_flow_ice.jpg',
        'assets/images/inner_child_treehouse.jpg',
        'assets/images/anger_discharge_waves.jpg',
        'assets/images/boundary_orchard_gate.jpg',
        'assets/images/scarcity_seedling_hands.jpg',
        'assets/images/negotiation_skyline_poise.jpg',
        'assets/images/public_stage_spotlight.jpg',
        'assets/images/career_pivot_crossroads.jpg',
        'assets/images/lighthouse_storm_shield.jpg',
        'assets/images/solitude_cabin_hearth.jpg',
        'assets/images/divorce_sunlit_room.jpg',
        'assets/images/anxious_attachment_anchor.jpg',
        'assets/images/avoidant_courtyard_roses.jpg',
        'assets/images/social_trust_mugs.jpg',
        'assets/images/body_neutrality_pool.jpg',
        'assets/images/midnight_awakening_moon.jpg',
        'assets/images/postpartum_linen_calm.jpg',
        'assets/images/midlife_olive_tree.jpg',
        'assets/images/aging_teak_maple.jpg',
        'assets/images/dopamine_mountain_lake.jpg',
        'assets/images/evening_pen_candle.jpg',
        'assets/images/stoic_marble_bust.jpg',
        'assets/images/creative_studio_canvas.jpg',
        'assets/images/crisis_calm_center.jpg',
        'assets/images/ruthless_chess_king.jpg',
      };

      expect(allPlaylists.length, greaterThan(60));

      for (final pl in allPlaylists) {
        expect(
          validAssets.contains(pl.imagePath),
          isTrue,
          reason: 'Playlist "${pl.title}" (id: ${pl.id}) has unmapped imagePath: "${pl.imagePath}"',
        );
      }
    });

    test('JournalEntry date formatting produces user-friendly string', () {
      final entry = JournalEntry(
        id: 'test_1',
        title: 'Morning Reflections',
        body: 'Feeling grounded and ready for deep focus.',
        mood: 'Peaceful',
        date: DateTime(2026, 9, 5, 8, 30),
      );

      final formatted = DateFormat('MMM d, yyyy • h:mm a').format(entry.date);
      expect(formatted, 'Sep 5, 2026 • 8:30 AM');
    });
  });
}
