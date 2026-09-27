import '../models/playlist.dart';
import '../services/personalization_engine.dart';
import 'playlists_data.dart';

/// Clinical and lifestyle thematic category grouping for playlists.
class PlaylistGroup {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<String> playlistIds;

  const PlaylistGroup({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.playlistIds,
  });

  /// Resolves the concrete Playlist objects in this group from [allPlaylists].
  List<Playlist> get playlists {
    final Map<String, Playlist> lookup = {
      for (final p in allPlaylists) p.id: p,
    };
    return playlistIds
        .map((id) => lookup[id])
        .whereType<Playlist>()
        .toList();
  }

  /// Returns playlists sorted dynamically by user/mode resonance score in descending order.
  List<Playlist> getSortedPlaylists(Map<String, PlaylistMatch> matchMap) {
    final list = [...playlists];
    list.sort((a, b) {
      final scoreA = matchMap[a.id]?.matchScore ?? 0.0;
      final scoreB = matchMap[b.id]?.matchScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });
    return list;
  }
}

/// The 9 master thematic groups covering all 63 playlists in AVAN.
final List<PlaylistGroup> masterPlaylistGroups = [
  const PlaylistGroup(
    id: 'group_daily_essentials',
    title: 'Daily Essentials',
    emoji: '🌿',
    description: 'Foundational morning, flow, gratitude, and deep sleep routines.',
    playlistIds: [
      'pl_morning_neural',
      'pl_deep_flow',
      'pl_sleep_onset',
      'pl_stress_sos',
      'pl_gratitude_neuro',
      'pl_self_worth',
    ],
  ),
  const PlaylistGroup(
    id: 'group_anxiety_calm',
    title: 'Anxiety & Nervous System',
    emoji: '🌊',
    description: 'Somatic panic reset, social ease, rumination detox & crisis soothing.',
    playlistIds: [
      'pl_panic_release',
      'pl_social_anxiety',
      'pl_bedtime_rumination',
      'pl_emotional_flood',
    ],
  ),
  const PlaylistGroup(
    id: 'group_career_agency',
    title: 'Career & High Agency',
    emoji: '⚡',
    description: 'Founder resilience, executive poise, high standards, negotiation & crisis composure.',
    playlistIds: [
      'pl_founder_resilience',
      'pl_exec_presence',
      'pl_imposter',
      'pl_ruthless_execution',
      'pl_audacious_power',
      'pl_relentless_tenacity',
      'pl_scarcity_trauma',
      'pl_negotiation_poise',
      'pl_stage_composure',
      'pl_career_pivot',
      'pl_workplace_toxicity',
    ],
  ),
  const PlaylistGroup(
    id: 'group_focus_neurodiversity',
    title: 'Focus & Neurodiversity',
    emoji: '🎯',
    description: 'ADHD sensory calming, dopamine resets, task initiation & anti-procrastination.',
    playlistIds: [
      'pl_adhd_reset',
      'pl_rsd_relief',
      'pl_task_switching',
      'pl_sensory_overload',
      'pl_dopamine_detox',
      'pl_cold_start_dopamine',
      'pl_anti_procrastination',
      'pl_exam_confidence',
    ],
  ),
  const PlaylistGroup(
    id: 'group_heartbreak_grief',
    title: 'Heartbreak & Grief',
    emoji: '❤️‍🩹',
    description: 'Breakup shock stabilization, no-contact resolve, self-worth rebuild & bereavement.',
    playlistIds: [
      'pl_breakup_shock',
      'pl_no_contact',
      'pl_worth_rebuild',
      'pl_bereavement',
      'pl_divorce_healing',
    ],
  ),
  const PlaylistGroup(
    id: 'group_somatic_healing',
    title: 'Somatic Healing & Inner Work',
    emoji: '🕊️',
    description: 'Polyvagal freeze thawing, inner child reparenting, somatic pain relief & healthy boundaries.',
    playlistIds: [
      'pl_freeze_to_flow',
      'pl_inner_child',
      'pl_anger_discharge',
      'pl_boundaries_guilt',
      'pl_chronic_pain',
      'pl_body_neutrality',
    ],
  ),
  const PlaylistGroup(
    id: 'group_sleep_rest',
    title: 'Deep Sleep & Wind Down',
    emoji: '🌙',
    description: 'Evening deceleration, insomnia mitigation, body scan & midnight soothing.',
    playlistIds: [
      'pl_sleep_onset',
      'pl_midnight_awakening',
      'pl_evening_shutdown',
      'pl_bedtime_rumination',
    ],
  ),
  const PlaylistGroup(
    id: 'group_relationships_trust',
    title: 'Relationships & Solitude',
    emoji: '🤝',
    description: 'Anxious & avoidant attachment soothing, social trust, solitude mastery & authenticity.',
    playlistIds: [
      'pl_solitude_alchemy',
      'pl_anxious_attachment',
      'pl_avoidant_softening',
      'pl_social_trust',
      'pl_lgbtq_acceptance',
      'pl_trans_celebration',
      'pl_cultural_belonging',
    ],
  ),
  const PlaylistGroup(
    id: 'group_purpose_wealth_life',
    title: 'Purpose, Wealth & Life Stages',
    emoji: '🏛️',
    description: 'Financial abundance, stoic composure, creative breakthrough, parenting & transitions.',
    playlistIds: [
      'pl_abundance_align',
      'pl_scarcity_trauma',
      'pl_intuition_wisdom',
      'pl_stoic_poise',
      'pl_creative_block',
      'pl_crisis_composure',
      'pl_patient_parenting',
      'pl_caregiver_burnout',
      'pl_matrescence',
      'pl_hormonal_transition',
      'pl_aging_dignity',
      'pl_proud_simple',
      'pl_pregame',
      'pl_endurance',
      'pl_injury_recovery',
    ],
  ),
];

/// Helper to find the group a given playlist belongs to.
PlaylistGroup? findGroupByPlaylistId(String playlistId) {
  for (final group in masterPlaylistGroups) {
    if (group.playlistIds.contains(playlistId)) {
      return group;
    }
  }
  return null;
}

/// Returns master playlist groups dynamically ordered by relevance to the active mode.
List<PlaylistGroup> getOrderedPlaylistGroups({required bool isGrowthMode}) {
  final List<String> order;
  if (isGrowthMode) {
    // Growth mode: prioritize daily essentials, anxiety composure, high agency, and focus
    order = const [
      'group_daily_essentials',
      'group_anxiety_calm',
      'group_career_agency',
      'group_focus_neurodiversity',
      'group_purpose_wealth_life',
      'group_relationships_trust',
      'group_somatic_healing',
      'group_heartbreak_grief',
      'group_sleep_rest',
    ];
  } else {
    // Healing mode: prioritize nervous system soothing, deep sleep, somatic healing, and heartbreak/grief
    order = const [
      'group_anxiety_calm',
      'group_sleep_rest',
      'group_somatic_healing',
      'group_heartbreak_grief',
      'group_daily_essentials',
      'group_relationships_trust',
      'group_focus_neurodiversity',
      'group_purpose_wealth_life',
      'group_career_agency',
    ];
  }

  final list = [...masterPlaylistGroups];
  list.sort((a, b) {
    final idxA = order.indexOf(a.id);
    final idxB = order.indexOf(b.id);
    return (idxA == -1 ? 99 : idxA).compareTo(idxB == -1 ? 99 : idxB);
  });
  return list;
}

