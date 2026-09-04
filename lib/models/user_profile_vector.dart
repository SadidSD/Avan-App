import 'dart:math' as math;
import 'user_archetype.dart';

class UserProfileVector {
  final List<UserArchetype> primaryArchetypes;
  final List<UserArchetype> secondaryArchetypes;
  final List<String> selectedSubLevels;
  final AffirmationTone preferredTone;
  final List<TherapeuticModality> preferredModalities;
  List<double> vector; // Active 16-dimensional continuous embedding
  List<double> baselineVector; // Permanent trait anchor vector from onboarding
  List<double> stateVector; // Dynamic session/interaction state vector
  final double believabilityPreference; // 0.0 - 1.0 (default 0.8)
  final int completedSessionsCount; // Total full sessions completed
  final int recentSkipCount; // Consecutive or recent rapid skips
  DateTime lastUpdated;
  int interactionCount;

  /// Returns the anchored blended vector: 70% permanent onboarding trait, 30% dynamic interaction state.
  /// Prevents catastrophic forgetting while still allowing daily adaptive learning.
  List<double> get effectiveVector {
    if (baselineVector.isEmpty) return vector;
    if (stateVector.isEmpty) return baselineVector;

    final blended = List<double>.filled(16, 0.0);
    for (int i = 0; i < 16; i++) {
      blended[i] = 0.70 * baselineVector[i] + 0.30 * stateVector[i];
    }

    double sumSq = 0.0;
    for (var v in blended) {
      sumSq += v * v;
    }
    if (sumSq == 0.0) return baselineVector;
    final mag = math.sqrt(sumSq);
    return blended.map((v) => v / mag).toList();
  }

  /// Dynamic Zone of Proximal Development (ZPD) Believability Preference:
  /// Scales the user's believability window over time based on completed listening sessions,
  /// while safely retreating toward gentle grounding if recent skips occur.
  double get effectiveBelievabilityPreference {
    // Growth step: -0.08 * ln(1 + 0.10 * completedSessions)
    final double growth = 0.08 * math.log(1.0 + 0.10 * completedSessionsCount);
    // Retreat step: +0.04 * skips (clamped <= 5)
    final double retreat = 0.04 * math.min(5, recentSkipCount);
    final double target = believabilityPreference - growth + retreat;
    return target.clamp(0.45, 0.95);
  }

  UserProfileVector({
    this.primaryArchetypes = const [UserArchetype.careerProfessional],
    this.secondaryArchetypes = const [],
    this.selectedSubLevels = const [],
    this.preferredTone = AffirmationTone.empowering,
    this.preferredModalities = const [TherapeuticModality.cbtReframe],
    List<double>? vector,
    List<double>? baselineVector,
    List<double>? stateVector,
    this.believabilityPreference = 0.8,
    this.completedSessionsCount = 0,
    this.recentSkipCount = 0,
    DateTime? lastUpdated,
    this.interactionCount = 0,
  })  : vector = vector ?? baselineVector ?? List.filled(16, 0.0),
        baselineVector = baselineVector ?? vector ?? List.filled(16, 0.0),
        stateVector = stateVector ?? vector ?? baselineVector ?? List.filled(16, 0.0),
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'primaryArchetypes': primaryArchetypes.map((a) => a.index).toList(),
      'secondaryArchetypes': secondaryArchetypes.map((a) => a.index).toList(),
      'selectedSubLevels': selectedSubLevels,
      'preferredTone': preferredTone.index,
      'preferredModalities': preferredModalities.map((m) => m.index).toList(),
      'vector': vector,
      'baselineVector': baselineVector,
      'stateVector': stateVector,
      'believabilityPreference': believabilityPreference,
      'completedSessionsCount': completedSessionsCount,
      'recentSkipCount': recentSkipCount,
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
      baselineVector: (json['baselineVector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          (json['vector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      stateVector: (json['stateVector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          (json['vector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      believabilityPreference:
          (json['believabilityPreference'] as num?)?.toDouble() ?? 0.8,
      completedSessionsCount: json['completedSessionsCount'] as int? ?? 0,
      recentSkipCount: json['recentSkipCount'] as int? ?? 0,
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
    List<double>? baselineVector,
    List<double>? stateVector,
    double? believabilityPreference,
    int? completedSessionsCount,
    int? recentSkipCount,
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
      baselineVector: baselineVector ?? List.from(this.baselineVector),
      stateVector: stateVector ?? List.from(this.stateVector),
      believabilityPreference:
          believabilityPreference ?? this.believabilityPreference,
      completedSessionsCount:
          completedSessionsCount ?? this.completedSessionsCount,
      recentSkipCount: recentSkipCount ?? this.recentSkipCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      interactionCount: interactionCount ?? this.interactionCount,
    );
  }
}
