enum UserArchetype {
  careerProfessional,
  anxiousOverthinker,
  heartbreakSurvivor,
  grievingIndividual,
  selfImprovement,
  spiritualSeeker,
  parentCaregiver,
  athlete,
  personWithIDD,
  student,
  lgbtqia,
}

enum TherapeuticModality {
  cbtReframe,
  actValues,
  selfCompassion,
  growthMindset,
  traumaInformed,
  sportsPsychology,
  spiritualAlignment,
  accessibleDirect,
}

enum AffirmationTone {
  empowering,
  gentleAndGrounding,
  philosophical,
  directAndActionable,
  simpleAndClear,
}

class ArchetypeMetadata {
  final UserArchetype archetype;
  final String title;
  final String shortDescription;
  final String icon;
  final List<String> subLevels;
  final List<TherapeuticModality> primaryModalities;

  const ArchetypeMetadata({
    required this.archetype,
    required this.title,
    required this.shortDescription,
    required this.icon,
    required this.subLevels,
    required this.primaryModalities,
  });
}

class ArchetypeRegistry {
  static const List<ArchetypeMetadata> allArchetypes = [
    ArchetypeMetadata(
      archetype: UserArchetype.careerProfessional,
      title: 'Career-Driven Professional',
      shortDescription: 'Confidence, workplace calm, high performance & imposter relief',
      icon: '💼',
      subLevels: [
        'Founder / Solopreneur',
        'Corporate Executive / Leader',
        'Individual Contributor / Climber',
        'Sales & Client Relations',
      ],
      primaryModalities: [
        TherapeuticModality.cbtReframe,
        TherapeuticModality.growthMindset,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.anxiousOverthinker,
      title: 'Anxious Overthinker',
      shortDescription: 'Breaking thought spirals, somatic grounding & inner stillness',
      icon: '🌊',
      subLevels: [
        'Chronic Panic & Physical Tension',
        'Social & Performance Anxiety',
        'Bedtime & Late-Night Rumination',
      ],
      primaryModalities: [
        TherapeuticModality.traumaInformed,
        TherapeuticModality.actValues,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.heartbreakSurvivor,
      title: 'Heartbreak Survivor',
      shortDescription: 'Healing from breakups, divorce, self-worth rebuild without toxic positivity',
      icon: '❤️‍🩹',
      subLevels: [
        'Fresh Breakup / Shock Phase (Day 0-30)',
        'Grief & Yearning / No-Contact Phase',
        'Self-Worth & Rediscovery Phase',
        'Divorce & Long-term Separation',
      ],
      primaryModalities: [
        TherapeuticModality.selfCompassion,
        TherapeuticModality.actValues,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.grievingIndividual,
      title: 'Grieving Individual',
      shortDescription: 'Bereavement support, validating loss & gentle comfort',
      icon: '🕊️',
      subLevels: [
        'Loss of Parent or Sibling',
        'Loss of Partner / Spouse',
        'Young Adult Grief (18-24)',
        'Anticipatory Grief / Family Illness',
      ],
      primaryModalities: [
        TherapeuticModality.actValues,
        TherapeuticModality.selfCompassion,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.selfImprovement,
      title: 'Self-Improvement Enthusiast',
      shortDescription: 'Habit mastery, discipline, stoic reflection & peak potential',
      icon: '⚡',
      subLevels: [
        'Daily Habit & Consistency Builder',
        'Deep Work & Focus Optimizer',
        'Stoic Mindset & Philosophy Explorer',
      ],
      primaryModalities: [
        TherapeuticModality.growthMindset,
        TherapeuticModality.cbtReframe,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.spiritualSeeker,
      title: 'Spiritual Seeker',
      shortDescription: 'Abundance, universal alignment, manifestation & intuition',
      icon: '✨',
      subLevels: [
        'Law of Attraction & Abundance',
        'Intuition & Inner Wisdom',
        'Gratitude & Higher Alignment',
      ],
      primaryModalities: [
        TherapeuticModality.spiritualAlignment,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.parentCaregiver,
      title: 'Parent & Caregiver',
      shortDescription: 'Patience, releasing parental guilt & caregiver calm',
      icon: '🌱',
      subLevels: [
        'Newborn & Toddler Parent',
        'School-Age & Teen Parent',
        'Elder & Family Caregiver',
      ],
      primaryModalities: [
        TherapeuticModality.selfCompassion,
        TherapeuticModality.cbtReframe,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.athlete,
      title: 'Athlete & Competitor',
      shortDescription: 'Mental grit, pre-game poise, comeback endurance & injury rehab',
      icon: '🏆',
      subLevels: [
        'Endurance, Running & Fitness',
        'Competitive Game Prep & Clutch Mindset',
        'Injury Recovery & Mental Reset',
      ],
      primaryModalities: [
        TherapeuticModality.sportsPsychology,
        TherapeuticModality.growthMindset,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.personWithIDD,
      title: 'Accessible & Sensory Friendly',
      shortDescription: 'Simple, direct, sensory-calming & confidence-building words',
      icon: '🧩',
      subLevels: [
        'Sensory Calming & Grounding',
        'Daily Pride & Capability',
        'Social Belonging & Friendship',
      ],
      primaryModalities: [
        TherapeuticModality.accessibleDirect,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.student,
      title: 'Student & Academic',
      shortDescription: 'Exam focus, study motivation, memory trust & stress reduction',
      icon: '📚',
      subLevels: [
        'High School & College Exam Prep',
        'Grad / Medical / Professional Exams',
        'Study Motivation & Anti-Procrastination',
      ],
      primaryModalities: [
        TherapeuticModality.cbtReframe,
        TherapeuticModality.growthMindset,
      ],
    ),
    ArchetypeMetadata(
      archetype: UserArchetype.lgbtqia,
      title: 'LGBTQIA+ Individual',
      shortDescription: 'Authentic pride, resilience against prejudice & community self-love',
      icon: '🌈',
      subLevels: [
        'Authenticity & Coming Out Journey',
        'Resilience in Challenging Spaces',
        'Trans & Non-Binary Identity Celebration',
      ],
      primaryModalities: [
        TherapeuticModality.selfCompassion,
        TherapeuticModality.actValues,
      ],
    ),
  ];

  static ArchetypeMetadata getMetadata(UserArchetype type) {
    return allArchetypes.firstWhere(
      (m) => m.archetype == type,
      orElse: () => allArchetypes.first,
    );
  }
}
