class JournalEntry {
  final String id;
  final String title;
  final String body;
  final String mood;
  final DateTime date;
  bool isFavorite;

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.date,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'mood': mood,
      'date': date.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      mood: json['mood'] as String,
      date: DateTime.parse(json['date'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
