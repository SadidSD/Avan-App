import 'affirmation.dart';

class Playlist {
  final String id;
  final String title;
  final String duration;
  final String category;
  final String imagePath;
  final bool isPremium;
  final List<Affirmation> affirmations;

  Playlist({
    required this.id,
    required this.title,
    required this.duration,
    required this.category,
    required this.imagePath,
    this.isPremium = false,
    required this.affirmations,
  });
}
