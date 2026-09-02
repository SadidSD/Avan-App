class UserRecording {
  final String id;
  final String title;
  final int durationSeconds;
  final DateTime date;
  final bool isFavorite;
  final String audioPath;

  UserRecording({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.date,
    this.isFavorite = false,
    required this.audioPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationSeconds': durationSeconds,
      'date': date.toIso8601String(),
      'isFavorite': isFavorite,
      'audioPath': audioPath,
    };
  }

  factory UserRecording.fromJson(Map<String, dynamic> json) {
    return UserRecording(
      id: json['id'],
      title: json['title'],
      durationSeconds: json['durationSeconds'],
      date: DateTime.parse(json['date']),
      isFavorite: json['isFavorite'] ?? false,
      audioPath: json['audioPath'],
    );
  }

  UserRecording copyWith({
    String? title,
    bool? isFavorite,
  }) {
    return UserRecording(
      id: id,
      title: title ?? this.title,
      durationSeconds: durationSeconds,
      date: date,
      isFavorite: isFavorite ?? this.isFavorite,
      audioPath: audioPath,
    );
  }
}
