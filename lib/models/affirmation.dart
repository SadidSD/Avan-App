import 'user_archetype.dart';

class Affirmation {
  final String id;
  final String title;
  final String quote;
  final String category;
  final String author;
  bool isFavorite;
  
  // Vector and psychological metadata
  final List<UserArchetype> primaryArchetypes;
  final List<String> subLevels;
  final TherapeuticModality modality;
  final AffirmationTone tone;
  final List<double> embeddingVector; // 16-dimensional embedding
  final double believabilityScore; // 0.0 - 1.0 (higher = more gentle/grounding, lower = bold aspirational)
  final List<String> tags;

  Affirmation({
    required this.id,
    this.title = '',
    required this.quote,
    required this.category,
    this.author = 'AVAN',
    this.isFavorite = false,
    this.primaryArchetypes = const [],
    this.subLevels = const [],
    this.modality = TherapeuticModality.cbtReframe,
    this.tone = AffirmationTone.empowering,
    this.embeddingVector = const [],
    this.believabilityScore = 0.8,
    this.tags = const [],
  });

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (tags.length >= 2) {
      final t1 = _toTitleCase(tags[0]);
      final t2 = _toTitleCase(tags[1]);
      return '$t1 • $t2';
    } else if (tags.isNotEmpty) {
      return _toTitleCase(tags[0]);
    }
    if (subLevels.isNotEmpty) {
      return subLevels.first;
    }
    return category;
  }

  static String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text.split('-').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'quote': quote,
      'category': category,
      'author': author,
      'isFavorite': isFavorite,
      'primaryArchetypes': primaryArchetypes.map((a) => a.index).toList(),
      'subLevels': subLevels,
      'modality': modality.index,
      'tone': tone.index,
      'embeddingVector': embeddingVector,
      'believabilityScore': believabilityScore,
      'tags': tags,
    };
  }

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      quote: json['quote'] as String,
      category: json['category'] as String,
      author: json['author'] as String? ?? 'AVAN',
      isFavorite: json['isFavorite'] as bool? ?? false,
      primaryArchetypes: (json['primaryArchetypes'] as List<dynamic>?)
              ?.map((e) => UserArchetype.values[e as int])
              .toList() ??
          [],
      subLevels: (json['subLevels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      modality: json['modality'] != null
          ? TherapeuticModality.values[json['modality'] as int]
          : TherapeuticModality.cbtReframe,
      tone: json['tone'] != null
          ? AffirmationTone.values[json['tone'] as int]
          : AffirmationTone.empowering,
      embeddingVector: (json['embeddingVector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      believabilityScore: (json['believabilityScore'] as num?)?.toDouble() ?? 0.8,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
