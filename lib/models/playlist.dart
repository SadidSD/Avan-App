import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'affirmation.dart';
import 'user_archetype.dart';
import 'user_profile_vector.dart';
import '../services/audio_engine_service.dart';

class Playlist {
  final String id;
  final String title;
  final String duration;
  final String category;
  final String imagePath;
  final bool isPremium;
  final List<Affirmation> affirmations;
  final AmbientSound defaultAmbientSound;
  final String? description;
  final List<UserArchetype>? targetArchetypes;
  final List<String>? targetSubLevels;
  final List<String>? tags;
  final String? archetypeId;
  final String? subtitle;

  List<double>? _cachedCentroid;
  double? _cachedCohesion;
  double? _cachedAverageBelievability;

  /// Returns the normalized 16-dimensional centroid vector representing the semantic center
  /// of all affirmations in this playlist.
  List<double> get centroidVector {
    if (_cachedCentroid != null) return _cachedCentroid!;
    if (affirmations.isEmpty) return const [];

    int dim = 0;
    for (final aff in affirmations) {
      if (aff.embeddingVector.isNotEmpty) {
        dim = aff.embeddingVector.length;
        break;
      }
    }
    if (dim == 0) return const [];

    final sum = List<double>.filled(dim, 0.0);
    int count = 0;
    for (final aff in affirmations) {
      if (aff.embeddingVector.length == dim) {
        for (int i = 0; i < dim; i++) {
          sum[i] += aff.embeddingVector[i];
        }
        count++;
      }
    }
    if (count == 0) return const [];

    // Average vector
    final avg = sum.map((v) => v / count).toList();

    // Directional mean resultant length R in [0, 1] (spherical dispersion measure)
    double norm = 0.0;
    for (var val in avg) {
      norm += val * val;
    }
    norm = math.sqrt(norm);
    _cachedCohesion = norm.clamp(0.0, 1.0);

    // Normalize to unit length for standard cosine similarity
    if (norm == 0.0) {
      _cachedCentroid = avg;
    } else {
      _cachedCentroid = avg.map((v) => v / norm).toList();
    }

    return _cachedCentroid!;
  }

  /// Directional mean resultant length R in [0, 1] measuring internal thematic cohesion of affirmations.
  double get cohesionScore {
    if (_cachedCohesion != null) return _cachedCohesion!;
    final _ = centroidVector;
    return _cachedCohesion ?? 1.0;
  }

  /// Returns the mean believability score of all affirmations in this playlist.
  /// (Higher = gentle/grounding, lower = bold/aspirational).
  double get averageBelievabilityScore {
    if (_cachedAverageBelievability != null) return _cachedAverageBelievability!;
    if (affirmations.isEmpty) return 0.8;
    double sum = 0.0;
    for (final aff in affirmations) {
      sum += aff.believabilityScore;
    }
    _cachedAverageBelievability = sum / affirmations.length;
    return _cachedAverageBelievability!;
  }

  /// Returns the declared target archetypes, or dynamically aggregates distinct archetypes
  /// from all constituent affirmations to eliminate ranking metadata blind spots.
  List<UserArchetype> get effectiveTargetArchetypes {
    if (targetArchetypes != null && targetArchetypes!.isNotEmpty) {
      return targetArchetypes!;
    }
    final Set<UserArchetype> derived = {};
    for (final aff in affirmations) {
      derived.addAll(aff.primaryArchetypes);
    }
    return derived.toList();
  }

  /// Returns the declared target sub-levels, or dynamically aggregates distinct sub-levels
  /// from all constituent affirmations.
  List<String> get effectiveTargetSubLevels {
    if (targetSubLevels != null && targetSubLevels!.isNotEmpty) {
      return targetSubLevels!;
    }
    final Set<String> derived = {};
    for (final aff in affirmations) {
      derived.addAll(aff.subLevels);
    }
    return derived.toList();
  }

  /// Returns a dynamically adapted copy of this playlist sequenced specifically
  /// for the active user's current habituation state and ZPD therapeutic arc.
  Playlist adaptForUser({
    required UserProfileVector profile,
    Map<String, int>? lastListenedTimestamps,
    bool isGrowthMode = true,
    DateTime? now,
  }) {
    if (affirmations.length <= 2) return this;

    final currentTime = now ?? DateTime.now();

    // 1. Calculate each affirmation's habituation freshness H in [0.20, 1.0]
    final scoredAffirmations = affirmations.map((aff) {
      final lastHeard = lastListenedTimestamps?[aff.id];
      double habituation = 1.0;
      if (lastHeard != null && lastHeard > 0) {
        final elapsedMs = currentTime.millisecondsSinceEpoch - lastHeard;
        if (elapsedMs > 0) {
          final elapsedHours = elapsedMs / (3600.0 * 1000.0);
          final decay = math.exp(-elapsedHours / 40.0);
          habituation = (1.0 - 0.80 * decay).clamp(0.20, 1.0);
        }
      }

      return (
        affirmation: aff,
        habituation: habituation,
        believability: aff.believabilityScore,
      );
    }).toList();

    // 2. Split into fresh vs recently heard (stale) affirmations
    // Affirmations with H >= 0.50 are fresh. Stale ones (H < 0.50) are moved toward the end.
    final fresh = scoredAffirmations.where((s) => s.habituation >= 0.50).toList();
    final stale = scoredAffirmations.where((s) => s.habituation < 0.50).toList();

    // 3. Sort fresh affirmations into a clinical therapeutic arc:
    // Grounding (high believability >= 0.85) -> Reframing -> High Agency / Action
    fresh.sort((a, b) => b.believability.compareTo(a.believability));
    stale.sort((a, b) => b.believability.compareTo(a.believability));

    final reordered = [
      ...fresh.map((s) => s.affirmation),
      ...stale.map((s) => s.affirmation),
    ];

    return Playlist(
      id: id,
      title: title,
      duration: duration,
      category: category,
      imagePath: imagePath,
      isPremium: isPremium,
      defaultAmbientSound: defaultAmbientSound,
      description: description,
      subtitle: subtitle,
      targetArchetypes: targetArchetypes,
      targetSubLevels: targetSubLevels,
      tags: tags,
      archetypeId: archetypeId,
      affirmations: reordered,
    );
  }

  /// Visually distinct atmospheric gradient reflecting this playlist's emotional theme
  LinearGradient get atmosphericGradient {
    final cat = category.toLowerCase();
    final t = title.toLowerCase();
    if (cat.contains('anxiety') || t.contains('panic') || t.contains('tension') || t.contains('calm') || t.contains('stress')) {
      return const LinearGradient(
        colors: [Color(0x66162E4A), Color(0x990A1A2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('morning') || t.contains('neural') || t.contains('activation') || t.contains('flow') || t.contains('energy')) {
      return const LinearGradient(
        colors: [Color(0x66114B32), Color(0x990A2E1F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('heartbreak') || cat.contains('grief') || t.contains('breakup') || t.contains('loss') || t.contains('contact')) {
      return const LinearGradient(
        colors: [Color(0x664A1525), Color(0x992B0D16)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('career') || cat.contains('leadership') || t.contains('founder') || t.contains('executive') || t.contains('imposter')) {
      return const LinearGradient(
        colors: [Color(0x664A3815), Color(0x99291E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('sleep') || cat.contains('night') || t.contains('rumination') || t.contains('scan')) {
      return const LinearGradient(
        colors: [Color(0x770D1B2A), Color(0xAA060C14)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('student') || t.contains('exam') || t.contains('procrastination') || t.contains('study')) {
      return const LinearGradient(
        colors: [Color(0x662C1D4D), Color(0x99180E2E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('athlete') || t.contains('endurance') || t.contains('game') || t.contains('injury')) {
      return const LinearGradient(
        colors: [Color(0x664D1D1D), Color(0x992E0E0E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cat.contains('lgbtq') || t.contains('trans') || t.contains('identity')) {
      return const LinearGradient(
        colors: [Color(0x664A1540), Color(0x99290B23)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0x442C1810), Color(0x771A110D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Thematic icon or emoji for this playlist category
  String get categoryEmoji {
    final cat = category.toLowerCase();
    final t = title.toLowerCase();
    if (cat.contains('anxiety') || t.contains('panic') || t.contains('calm')) return '🌊';
    if (cat.contains('morning') || t.contains('neural') || t.contains('activation')) return '🌿';
    if (cat.contains('heartbreak') || t.contains('breakup')) return '💔';
    if (cat.contains('grief') || t.contains('bereavement')) return '🕊️';
    if (cat.contains('career') || t.contains('founder') || t.contains('executive')) return '💼';
    if (cat.contains('sleep') || t.contains('night')) return '🌙';
    if (cat.contains('student') || t.contains('exam')) return '📚';
    if (cat.contains('athlete') || t.contains('game')) return '⚡';
    if (cat.contains('lgbtq') || t.contains('identity')) return '🌈';
    if (cat.contains('gratitude')) return '✨';
    return '✨';
  }

  static String resolveValidAssetPath({
    String? rawPath,
    required String category,
    List<String>? tags,
    String? title,
  }) {
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

    if (rawPath != null && validAssets.contains(rawPath)) {
      return rawPath;
    }

    final combined =
        '${category.toLowerCase()} ${(tags ?? []).join(" ").toLowerCase()} ${(title ?? "").toLowerCase()} ${(rawPath ?? "").toLowerCase()}';

    // Specific Playlists
    if (combined.contains('morning neural') || combined.contains('neural activation')) {
      return 'assets/images/morning_neural_activation.jpg';
    }
    if (combined.contains('deep work') || combined.contains('flow state')) {
      return 'assets/images/deep_work_flow.jpg';
    }
    if (combined.contains('sleep onset') || combined.contains('body scan')) {
      return 'assets/images/sleep_onset_scan.jpg';
    }
    if (combined.contains('stress reset') || combined.contains('sos')) {
      return 'assets/images/stress_reset_sos.jpg';
    }
    if (combined.contains('gratitude neuro') || combined.contains('gratitude neuroplasticity')) {
      return 'assets/images/gratitude_neuro.jpg';
    }
    if (combined.contains('self-worth foundation') || combined.contains('self worth foundation')) {
      return 'assets/images/self_worth_found.jpg';
    }
    if (combined.contains('panic & physical') || combined.contains('panic release')) {
      return 'assets/images/panic_tension_rel.jpg';
    }
    if (combined.contains('social & performance') || combined.contains('social anxiety')) {
      return 'assets/images/social_anxiety_calm.jpg';
    }
    if (combined.contains('bedtime rumination') || combined.contains('rumination detox')) {
      return 'assets/images/bedtime_rumination.jpg';
    }
    if (combined.contains('emotional flooding') || combined.contains('flooding recovery')) {
      return 'assets/images/emotional_flood_rec.jpg';
    }
    if (combined.contains('fresh breakup') || combined.contains('shock & survival')) {
      return 'assets/images/breakup_shock_surv.jpg';
    }
    if (combined.contains('no-contact') || combined.contains('no contact')) {
      return 'assets/images/nocontact_strength.jpg';
    }
    if (combined.contains('worth rebuild') || combined.contains('rebuild after loss')) {
      return 'assets/images/worth_rebuild_kint.jpg';
    }
    if (combined.contains('bereavement') || combined.contains('continuing bonds')) {
      return 'assets/images/bereavement_candle.jpg';
    }
    if (combined.contains('founder') || combined.contains('founder resilience')) {
      return 'assets/images/founder_resilience.jpg';
    }
    if (combined.contains('executive presence') || combined.contains('decision clarity')) {
      return 'assets/images/exec_presence_clarity.jpg';
    }
    if (combined.contains('imposter syndrome') || combined.contains('imposter')) {
      return 'assets/images/imposter_syndrome_ant.jpg';
    }
    if (combined.contains('radical self-acceptance') || combined.contains('lgbtq')) {
      return 'assets/images/lgbtq_self_acceptance.jpg';
    }
    if (combined.contains('trans & non-binary') || combined.contains('trans')) {
      return 'assets/images/trans_identity_prism.jpg';
    }
    if (combined.contains('cultural identity') || combined.contains('belonging')) {
      return 'assets/images/cultural_identity_text.jpg';
    }
    if (combined.contains('pre-game') || combined.contains('pregame')) {
      return 'assets/images/pregame_tunnel_focus.jpg';
    }
    if (combined.contains('endurance') || combined.contains('pain threshold')) {
      return 'assets/images/endurance_ridge_dawn.jpg';
    }
    if (combined.contains('injury recovery') || combined.contains('injury')) {
      return 'assets/images/injury_recovery_fern.jpg';
    }
    if (combined.contains('exam confidence') || combined.contains('memory trust')) {
      return 'assets/images/exam_study_clarity.jpg';
    }
    if (combined.contains('anti-procrastination') || combined.contains('study drive')) {
      return 'assets/images/antiprocrastination_desk.jpg';
    }
    if (combined.contains('patient parenting') || combined.contains('guilt release')) {
      return 'assets/images/patient_parenting_nurs.jpg';
    }
    if (combined.contains('caregiver burnout') || combined.contains('caregiver')) {
      return 'assets/images/caregiver_porch_rest.jpg';
    }
    if (combined.contains('abundance') || combined.contains('attraction alignment')) {
      return 'assets/images/abundance_spring_gold.jpg';
    }
    if (combined.contains('intuition') || combined.contains('inner wisdom')) {
      return 'assets/images/intuition_mountain_tarn.jpg';
    }
    if (combined.contains('proud of me') || combined.contains('simple & direct')) {
      return 'assets/images/proud_sunrise_porch.jpg';
    }
    if (combined.contains('adhd') || combined.contains('executive dysfunction')) {
      return 'assets/images/adhd_hourglass_reset.jpg';
    }
    if (combined.contains('rejection sensitive') || combined.contains('dysphoria')) {
      return 'assets/images/rsd_blanket_cocoon.jpg';
    }
    if (combined.contains('task switching') || combined.contains('mental transition')) {
      return 'assets/images/task_stepping_stones.jpg';
    }
    if (combined.contains('sensory overload') || combined.contains('decompression')) {
      return 'assets/images/sensory_felt_quiet.jpg';
    }
    if (combined.contains('dopamine fasting') || combined.contains('screen detachment')) {
      return 'assets/images/dopamine_bonsai_calm.jpg';
    }
    if (combined.contains('chronic pain') || combined.contains('illness compassion')) {
      return 'assets/images/chronic_pain_spring.jpg';
    }
    if (combined.contains('freeze to flow') || combined.contains('nervous system: freeze')) {
      return 'assets/images/freeze_to_flow_ice.jpg';
    }
    if (combined.contains('inner child') || combined.contains('reparenting')) {
      return 'assets/images/inner_child_treehouse.jpg';
    }
    if (combined.contains('anger & irritability') || combined.contains('irritability discharge')) {
      return 'assets/images/anger_discharge_waves.jpg';
    }
    if (combined.contains('boundary') || combined.contains('without guilt')) {
      return 'assets/images/boundary_orchard_gate.jpg';
    }
    if (combined.contains('scarcity') || combined.contains('financial')) {
      return 'assets/images/scarcity_seedling_hands.jpg';
    }
    if (combined.contains('negotiation') || combined.contains('high-stakes')) {
      return 'assets/images/negotiation_skyline_poise.jpg';
    }
    if (combined.contains('public speaking') || combined.contains('stage composure')) {
      return 'assets/images/public_stage_spotlight.jpg';
    }
    if (combined.contains('career pivot') || combined.contains('reinvention')) {
      return 'assets/images/career_pivot_crossroads.jpg';
    }
    if (combined.contains('workplace toxicity') || combined.contains('toxicity shield')) {
      return 'assets/images/lighthouse_storm_shield.jpg';
    }
    if (combined.contains('solitude') || combined.contains('loneliness alchemy')) {
      return 'assets/images/solitude_cabin_hearth.jpg';
    }
    if (combined.contains('divorce') || combined.contains('separation healing')) {
      return 'assets/images/divorce_sunlit_room.jpg';
    }
    if (combined.contains('anxious attachment') || combined.contains('attachment soothing')) {
      return 'assets/images/anxious_attachment_anchor.jpg';
    }
    if (combined.contains('avoidant attachment') || combined.contains('attachment softening')) {
      return 'assets/images/avoidant_courtyard_roses.jpg';
    }
    if (combined.contains('social trust') || combined.contains('rebuilding social')) {
      return 'assets/images/social_trust_mugs.jpg';
    }
    if (combined.contains('body neutrality') || combined.contains('mirror peace')) {
      return 'assets/images/body_neutrality_pool.jpg';
    }
    if (combined.contains('midnight awakening') || combined.contains('sleep continuity')) {
      return 'assets/images/midnight_awakening_moon.jpg';
    }
    if (combined.contains('post-partum') || combined.contains('matrescence') || combined.contains('new mom')) {
      return 'assets/images/postpartum_linen_calm.jpg';
    }
    if (combined.contains('hormonal') || combined.contains('mid-life') || combined.contains('transition poise')) {
      return 'assets/images/midlife_olive_tree.jpg';
    }
    if (combined.contains('aging') || combined.contains('ego integrity')) {
      return 'assets/images/aging_teak_maple.jpg';
    }
    if (combined.contains('cold-start') || combined.contains('dopamine ignition')) {
      return 'assets/images/dopamine_mountain_lake.jpg';
    }
    if (combined.contains('evening shutdown') || combined.contains('mental unload')) {
      return 'assets/images/evening_pen_candle.jpg';
    }
    if (combined.contains('stoic') || combined.contains('memento mori')) {
      return 'assets/images/stoic_marble_bust.jpg';
    }
    if (combined.contains('creative block') || combined.contains('block dissolution')) {
      return 'assets/images/creative_studio_canvas.jpg';
    }
    if (combined.contains('crisis composure') || combined.contains('under fire')) {
      return 'assets/images/crisis_calm_center.jpg';
    }
    if (combined.contains('ruthless execution') || combined.contains('strategic leverage')) {
      return 'assets/images/ruthless_chess_king.jpg';
    }
    if (combined.contains('audacious ambition') || combined.contains('unapologetic power')) {
      return 'assets/images/founder_resilience.jpg';
    }
    if (combined.contains('relentless tenacity') || combined.contains('high-pain tolerance')) {
      return 'assets/images/endurance_ridge_dawn.jpg';
    }

    // 1. Sleep, Night, Bedtime, Rest
    if (combined.contains('sleep') ||
        combined.contains('night') ||
        combined.contains('bedtime') ||
        combined.contains('rest') ||
        combined.contains('awakening')) {
      return 'assets/images/sleep_story_night.jpg';
    }

    // 2. Anxiety, Panic, Calm, Grief, Heartbreak, Somatic, Nervous System
    if (combined.contains('anxiety') ||
        combined.contains('panic') ||
        combined.contains('calm') ||
        combined.contains('grief') ||
        combined.contains('heartbreak') ||
        combined.contains('breakup') ||
        combined.contains('trauma') ||
        combined.contains('loneliness')) {
      return 'assets/images/onboarding_moon_clouds.jpg';
    }

    // 3. Morning, Activation, Career, Wealth, Focus, Flow, Performance, Executive, Energy
    if (combined.contains('morning') ||
        combined.contains('activation') ||
        combined.contains('career') ||
        combined.contains('wealth') ||
        combined.contains('focus') ||
        combined.contains('flow') ||
        combined.contains('performance') ||
        combined.contains('dopamine') ||
        combined.contains('leader') ||
        combined.contains('student') ||
        combined.contains('habits')) {
      return 'assets/images/onboarding_archway_sun.jpg';
    }

    // 4. Identity, Self-Compassion, Women, Body, Matrescence, Aging, Parenting, Spiritual
    if (combined.contains('identity') ||
        combined.contains('compassion') ||
        combined.contains('body') ||
        combined.contains('parenting') ||
        combined.contains('matrescence') ||
        combined.contains('aging') ||
        combined.contains('spiritual') ||
        combined.contains('lgbtq') ||
        combined.contains('culture')) {
      return 'assets/images/onboarding_girl_profile.jpg';
    }

    // 5. Default / General Mindfulness
    return 'assets/images/featured_meditation.jpg';
  }

  Playlist({
    required this.id,
    required this.title,
    String? duration,
    String? estimatedDuration,
    String? totalDuration,
    String? durationText,
    String? durationString,
    String? category,
    String? imagePath,
    String? coverImageUrl,
    String? thumbnailUrl,
    this.isPremium = false,
    required this.affirmations,
    AmbientSound? defaultAmbientSound,
    AmbientSound? ambientSound,
    this.description,
    String? subtitle,
    List<UserArchetype>? targetArchetypes,
    List<UserArchetype>? primaryArchetypes,
    List<String>? targetSubLevels,
    List<String>? subLevels,
    this.tags,
    this.archetypeId,
  })  : duration = duration ?? estimatedDuration ?? totalDuration ?? durationText ?? durationString ?? '10 min',
        category = category ?? (tags != null && tags.isNotEmpty ? tags.first : 'Personal Growth'),
        imagePath = resolveValidAssetPath(
          rawPath: imagePath ?? coverImageUrl ?? thumbnailUrl,
          category: category ?? (tags != null && tags.isNotEmpty ? tags.first : 'Personal Growth'),
          tags: tags,
          title: title,
        ),
        defaultAmbientSound = defaultAmbientSound ?? ambientSound ?? AmbientSound.solfeggio528,
        targetArchetypes = targetArchetypes ?? primaryArchetypes,
        targetSubLevels = targetSubLevels ?? subLevels,
        subtitle = subtitle ?? description;
}
