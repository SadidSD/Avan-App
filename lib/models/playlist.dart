import 'affirmation.dart';
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

  Playlist({
    required this.id,
    required this.title,
    required this.duration,
    required this.category,
    required this.imagePath,
    this.isPremium = false,
    required this.affirmations,
    this.defaultAmbientSound = AmbientSound.solfeggio528,
  });
}
