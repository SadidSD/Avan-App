import 'user_archetype.dart';

class UserProfileVector {
  final List<UserArchetype> primaryArchetypes;
  final List<UserArchetype> secondaryArchetypes;
  final List<String> selectedSubLevels;
  final AffirmationTone preferredTone;
  final List<TherapeuticModality> preferredModalities;
  List<double> vector; // 16-dimensional continuous embedding
  final double believabilityPreference; // 0.0 - 1.0 (default 0.8)
  DateTime lastUpdated;
  int interactionCount;

  UserProfileVector({
    this.primaryArchetypes = const [UserArchetype.careerProfessional],
    this.secondaryArchetypes = const [],
    this.selectedSubLevels = const [],
    this.preferredTone = AffirmationTone.empowering,
    this.preferredModalities = const [TherapeuticModality.cbtReframe],
    List<double>? vector,
    this.believabilityPreference = 0.8,
    DateTime? lastUpdated,
    this.interactionCount = 0,
  })  : vector = vector ?? List.filled(16, 0.0),
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'primaryArchetypes': primaryArchetypes.map((a) => a.index).toList(),
      'secondaryArchetypes': secondaryArchetypes.map((a) => a.index).toList(),
      'selectedSubLevels': selectedSubLevels,
      'preferredTone': preferredTone.index,
      'preferredModalities': preferredModalities.map((m) => m.index).toList(),
      'vector': vector,
      'believabilityPreference': believabilityPreference,
      'lastUpdated': lastUpdated.toIso8601String(),
      'interactionCount': interactionCount,
    };
  }

  factory UserProfileVector.fromJson(Map<String, dynamic> json) {
    return UserProfileVector(
      primaryArchetypes: (json['primaryArchetypes'] as List<dynamic>?)
              ?.map((e) => UserArchetype.values[e as int])
              .toList() ??
          [UserArchetype.careerProfessional],
      secondaryArchetypes: (json['secondaryArchetypes'] as List<dynamic>?)
              ?.map((e) => UserArchetype.values[e as int])
              .toList() ??
          [],
      selectedSubLevels: (json['selectedSubLevels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredTone: json['preferredTone'] != null
          ? AffirmationTone.values[json['preferredTone'] as int]
          : AffirmationTone.empowering,
      preferredModalities: (json['preferredModalities'] as List<dynamic>?)
              ?.map((e) => TherapeuticModality.values[e as int])
              .toList() ??
          [TherapeuticModality.cbtReframe],
      vector: (json['vector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          List.filled(16, 0.0),
      believabilityPreference:
          (json['believabilityPreference'] as num?)?.toDouble() ?? 0.8,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      interactionCount: json['interactionCount'] as int? ?? 0,
    );
  }

  UserProfileVector copyWith({
    List<UserArchetype>? primaryArchetypes,
    List<UserArchetype>? secondaryArchetypes,
    List<String>? selectedSubLevels,
    AffirmationTone? preferredTone,
    List<TherapeuticModality>? preferredModalities,
    List<double>? vector,
    double? believabilityPreference,
    DateTime? lastUpdated,
    int? interactionCount,
  }) {
    return UserProfileVector(
      primaryArchetypes: primaryArchetypes ?? this.primaryArchetypes,
      secondaryArchetypes: secondaryArchetypes ?? this.secondaryArchetypes,
      selectedSubLevels: selectedSubLevels ?? this.selectedSubLevels,
      preferredTone: preferredTone ?? this.preferredTone,
      preferredModalities: preferredModalities ?? this.preferredModalities,
      vector: vector ?? List.from(this.vector),
      believabilityPreference:
          believabilityPreference ?? this.believabilityPreference,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      interactionCount: interactionCount ?? this.interactionCount,
    );
  }
}
