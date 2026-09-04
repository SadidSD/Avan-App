import '../models/affirmation.dart';
import '../models/playlist.dart';
import '../services/audio_engine_service.dart';
import 'affirmation_library.dart';
import 'playlists/free_playlists.dart' as free;
import 'playlists/anxiety_playlists.dart' as anxiety;
import 'playlists/heartbreak_grief_playlists.dart' as heartbreak;
import 'playlists/career_identity_playlists.dart' as career;
import 'playlists/performance_student_playlists.dart' as performance;
import 'playlists/parenting_spiritual_accessible_playlists.dart' as parenting;

/// Master playlist registry — aggregates all 30 scientifically-grounded playlists
/// from 6 category modules into a single ordered list.
///
/// Structure:
///   6 FREE  playlists (Morning Neural, Deep Flow, Sleep Onset, Stress SOS, Gratitude, Self-Worth)
///  24 PREMIUM playlists across Anxiety, Heartbreak/Grief, Career/Identity,
///                       Performance/Student, Parenting/Spiritual/Accessible
///
/// Total: 300 affirmations, each with full 16D embedding vectors,
/// therapeutic modalities, archetype targeting, and believability scores.

final List<Playlist> allPlaylists = [
  ...free.freePlaylists,
  ...anxiety.anxietyPlaylists,
  ...heartbreak.heartbreakGriefPlaylists,
  ...career.careerIdentityPlaylists,
  ...performance.performanceStudentPlaylists,
  ...parenting.parentingSpiritualAccessiblePlaylists,
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
