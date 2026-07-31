class Affirmation {
  final String id;
  final String quote;
  final String category;
  final String author;
  bool isFavorite;

  Affirmation({
    required this.id,
    required this.quote,
    required this.category,
    this.author = 'AVAN',
    this.isFavorite = false,
  });
}
