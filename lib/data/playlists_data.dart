import '../models/affirmation.dart';
import '../models/playlist.dart';
import 'affirmation_library.dart';
import 'playlists/free_playlists.dart' as free;
import 'playlists/anxiety_playlists.dart' as anxiety;
import 'playlists/heartbreak_grief_playlists.dart' as heartbreak;
import 'playlists/career_identity_playlists.dart' as career;
import 'playlists/performance_student_playlists.dart' as performance;
import 'playlists/parenting_spiritual_accessible_playlists.dart' as parenting;
import 'playlists/neurodiversity_focus_playlists.dart' as neurodiversity;
import 'playlists/trauma_somatic_playlists.dart' as trauma;
import 'playlists/wealth_career_pivot_playlists.dart' as wealth;
import 'playlists/relationships_loneliness_playlists.dart' as relationships;
import 'playlists/body_mind_sleep_playlists.dart' as body_mind;
import 'playlists/advanced_habits_flow_playlists.dart' as advanced_habits;
import 'playlists/high_agency_mastery_playlists.dart' as high_agency;

/// Master playlist registry — aggregates all 63 scientifically-grounded playlists
/// from 13 category modules into a single ordered list.
///
/// Structure:
///    6 FREE  playlists (Morning Neural, Deep Flow, Sleep Onset, Stress SOS, Gratitude, Self-Worth)
///   57 PREMIUM playlists across Anxiety, Heartbreak/Grief, Career/Identity,
///                        Performance/Student, Parenting/Spiritual/Accessible,
///                        Neurodiversity/ADHD, Trauma/Somatics, Wealth/Career Pivot,
///                        Relationships/Loneliness, Body/Mind/Transitions, Advanced Habits/Flow,
///                        High-Agency Mastery (b in [0.45, 0.65])
///
/// Total: 630 affirmations across 63 playlists + 57 scientific library affirmations = 687 affirmations.
/// Every single affirmation includes a full 16D embedding vector, therapeutic modalities,
/// archetype targeting, and believability scores spanning the complete 0.45 - 1.00 ZPD range.

final List<Playlist> allPlaylists = [
  ...free.freePlaylists,
  ...anxiety.anxietyPlaylists,
  ...heartbreak.heartbreakGriefPlaylists,
  ...career.careerIdentityPlaylists,
  ...performance.performanceStudentPlaylists,
  ...parenting.parentingSpiritualAccessiblePlaylists,
  ...neurodiversity.neurodiversityFocusPlaylists,
  ...trauma.traumaSomaticPlaylists,
  ...wealth.wealthCareerPivotPlaylists,
  ...relationships.relationshipsLonelinessPlaylists,
  ...body_mind.bodyMindSleepPlaylists,
  ...advanced_habits.advancedHabitsFlowPlaylists,
  ...high_agency.highAgencyMasteryPlaylists,
];

List<Playlist> get freePlaylists =>
    allPlaylists.where((playlist) => !playlist.isPremium).toList();

List<Playlist> get premiumPlaylists =>
    allPlaylists.where((playlist) => playlist.isPremium).toList();

/// Aggregates all affirmations from both predefined playlists and the expanded scientific library.
/// Uses a Map to deduplicate by ID (scientific library vectors take priority).
List<Affirmation> getAllGlobalAffirmations() {
  final Map<String, Affirmation> map = {};
  // Scientific library affirmations (with hand-tuned vectors) take priority
  for (var aff in comprehensiveAffirmationLibrary) {
    map[aff.id] = aff;
  }
  // Playlist affirmations fill in the rest
  for (var pl in allPlaylists) {
    for (var aff in pl.affirmations) {
      map.putIfAbsent(aff.id, () => aff);
    }
  }
  return map.values.toList();
}
