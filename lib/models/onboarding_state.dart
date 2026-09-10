import 'user_archetype.dart';

enum EmotionalTrack {
  restoration, // Mind racing, healing, safe & grounded
  expansion,   // Level up and grow, restless energy
  alignment,   // Deeper purpose, abundance
  adaptive,    // Something else
}

/// Holds all user answers collected across the onboarding flow.
/// Enables dynamic prompt generation by referencing previous answers and sentiment.
class OnboardingState {
  // Phase 1: Identity & Trust
  String userName = '';
  int lifeStageIndex = -1; // 0-3
  int intentIndex = -1; // 0-5 (what brought you here)

  // Phase 2: Emotional Excavation
  int emotionalStateIndex = -1; // 0-4
  int timelineIndex = -1; // 0-3
  String twoAmThought = ''; // The 2AM / late-night typed thought
  int somaticIndex = -1; // 0-5 (where body feels it)
  int previousAttemptsIndex = -1; // 0-5
  int coreWoundIndex = -1; // 0-3 (within intent branch)

  // Phase 3: Aspiration & Vision
  String morningVision = ''; // How they want to wake up feeling
  int bestSelfIndex = -1; // 0-5
  String limitingBelief = ''; // Typed limiting belief
  int archetypeIndex = -1; // 0-10 (primary life dimension)
  int subArchetypeIndex = -1; // 0-3 (drill-down)

  // Phase 4: Cognitive Calibration
  int skepticismIndex = -1; // 0-3
  int innerCriticIndex = -1; // 0-5
  int toneIndex = -1; // 0-4
  int peakNeedTimeIndex = -1; // 0-3
  int dailyCommitmentIndex = -1; // 0-3

  // Phase 5: Synthesis
  int resonanceIndex = -1; // 0=perfect, 1=gentler, 2=bolder

  // --- Life Stage Labels ---
  static const List<String> lifeStageLabels = [
    'Student (16-24)',
    'Early Career (25-34)',
    'Building & Established (35-49)',
    'Experienced & Reflective (50+)',
  ];
  static const List<String> lifeStageEmojis = ['🎓', '💼', '🏠', '🌅'];

  // --- Intent Labels ---
  static const List<String> intentLabels = [
    'My mind won\'t stop racing',
    'I\'m healing from something painful',
    'I want to level up and grow',
    'I need to feel safe and grounded',
    'I\'m searching for deeper purpose',
    'Something else entirely',
  ];
  static const List<String> intentEmojis = ['🌊', '💔', '🔥', '🛡️', '🌌', '🧩'];

  // --- Emotional State Labels ---
  static const List<String> emotionalStateLabels = [
    'Quiet, but seeking something deeper',
    'Anxious — like my chest is tight and mind is loud',
    'Completely drained and empty',
    'Heavy, like I\'m carrying grief or hurt',
    'Restless — I have energy but no direction',
  ];
  static const List<String> emotionalStateEmojis = ['🌿', '⚡', '🪫', '💔', '🔥'];

  // --- Timeline Labels ---
  static const List<String> timelineLabels = [
    'Days — something just happened',
    'Weeks to months — it\'s building up',
    'Months to a year — it\'s become my normal',
    'Years — I don\'t remember feeling different',
  ];
  static const List<String> timelineEmojis = ['⏳', '📅', '📆', '♾️'];

  // --- Somatic Distress Labels ---
  static const List<String> somaticLabels = [
    'Chest — tightness, pressure, racing heart',
    'Head — foggy, spinning, headache',
    'Stomach — knots, nausea, heaviness',
    'Shoulders & neck — tension, clenching',
    'Throat — lump, difficulty speaking or breathing',
    'Everywhere / I\'m not sure',
  ];
  static const List<String> somaticEmojis = ['💓', '🧠', '😰', '💪', '🫁', '🤷'];

  // --- Somatic Expansion Labels (High Agency / Energetic) ---
  static const List<String> somaticExpansionLabels = [
    'Restless electricity — chest full of momentum, ready to move',
    'Buzzing laser focus — mind racing with ideas, hard to unplug',
    'Wired intensity — tension in shoulders and jaw from pushing hard',
    'Physical readiness — primed for action and execution right now',
    'Overstimulated — too much fire, need grounding focus',
    'Everywhere / I\'m not sure',
  ];
  static const List<String> somaticExpansionEmojis = ['⚡', '🧠', '💪', '🔥', '🌀', '🤷'];

  // --- Previous Attempts Labels (Restoration) ---
  static const List<String> previousAttemptsLabels = [
    'Meditation or mindfulness apps',
    'Journaling or therapy',
    'Medication or supplements',
    'Exercise or physical routines',
    'Other self-help content (podcasts, books)',
    'Nothing yet — this is my first step',
  ];
  static const List<String> previousAttemptsEmojis = ['🧘', '📓', '💊', '🏃', '📱', '🚫'];

  // --- Previous Performance Labels (Expansion / High Agency) ---
  static const List<String> previousPerformanceLabels = [
    'Deep work & productivity apps',
    'Fitness, gym & biohacking routines',
    'Mindfulness or breathwork resets',
    'High-performance books & podcasts',
    'Mentorship, coaching or peer networks',
    'Nothing formal yet — this is my next level',
  ];
  static const List<String> previousPerformanceEmojis = ['🎯', '🏋️', '🧘', '📚', '🤝', '🚀'];

  // --- Core Wound / Friction Labels (dynamic, based on intentIndex) ---
  List<String> getCoreWoundLabels() {
    switch (intentIndex) {
      case 0: // Mind racing
        return [
          'I can\'t trust my own thoughts',
          'I feel like I\'m always bracing for disaster',
          'I can\'t fall asleep because my mind replays everything',
          'I perform fine on the outside but I\'m drowning inside',
        ];
      case 1: // Healing from pain
        return [
          'I keep replaying what happened',
          'I don\'t know who I am without them',
          'I feel angry at myself for still caring',
          'I\'m scared I\'ll never feel normal again',
        ];
      case 2: // Level up
        return [
          'I start strong but never follow through',
          'I know what to do but I can\'t make myself do it',
          'I\'m stuck comparing myself to everyone else',
          'I feel like a fraud despite my achievements',
        ];
      case 3: // Safe and grounded
        return [
          'I feel disconnected from my body',
          'I don\'t feel safe expressing my emotions',
          'I carry other people\'s stress as my own',
          'Everything feels overwhelming, even small tasks',
        ];
      case 4: // Deeper purpose
        return [
          'I feel successful but empty',
          'I don\'t know what I actually want',
          'I feel like I\'m living someone else\'s life',
          'I\'ve lost connection with my intuition',
        ];
      default: // Something else / fallback
        return [
          'I feel stuck but I can\'t explain why',
          'I know something needs to change',
          'I\'m tired of going through the motions',
          'I want to feel like myself again',
        ];
    }
  }

  static const List<String> coreWoundEmojis = ['💭', '🔁', '🪞', '🌑'];

  // --- Best Self Labels ---
  static const List<String> bestSelfLabels = [
    'Speaks up without apologizing',
    'Moves through life with deep calm',
    'Takes action without overthinking',
    'Knows their worth without needing proof',
    'Lets go gracefully and moves forward',
    'Trusts that the universe has their back',
  ];
  static const List<String> bestSelfEmojis = ['🦁', '🕊️', '⚡', '💎', '🌊', '✨'];

  // --- Archetype Labels (Full 11 Registered Archetypes) ---
  static const List<String> archetypeLabels = [
    'Career, ambition & leadership',
    'Love, relationships & emotional healing',
    'Mental health, anxiety & nervous system',
    'Discipline, habits & self-mastery',
    'Purpose, abundance & spiritual alignment',
    'Athletic performance & physical grit',
    'Academic success, exams & learning',
    'Parenting, family & caregiving',
    'Grief, bereavement & deep loss',
    'LGBTQIA+ pride & authentic identity',
    'Sensory calm & accessible affirmations',
  ];
  static const List<String> archetypeEmojis = [
    '💼', '💔', '🧠', '🏛️', '🌌', '🏆', '📚', '🌱', '🕊️', '🌈', '🧩'
  ];

  // --- Sub-Archetype Labels (dynamic across all 11 archetypes) ---
  List<String> getSubArchetypeLabels() {
    switch (archetypeIndex) {
      case 0: // Career
        return [
          'Imposter syndrome',
          'Leadership pressure',
          'Job interview anxiety',
          'Burnout & exhaustion',
        ];
      case 1: // Love
        return [
          'Fresh breakup (< 30 days)',
          'Long grieving & no-contact',
          'Divorce or separation',
          'Rebuilding self-worth after betrayal',
        ];
      case 2: // Mental Health
        return [
          'Panic attacks & physical tension',
          'Bedtime rumination loops',
          'Social & performance anxiety',
          'Chronic worry about everything',
        ];
      case 3: // Discipline
        return [
          'Procrastination & phone addiction',
          'Deep work & productivity',
          'Consistency — I start but never finish',
          'Stoic emotional control',
        ];
      case 4: // Spiritual
        return [
          'Law of attraction & manifestation',
          'Connecting with intuition',
          'Gratitude practice & energetic alignment',
          'Finding my calling or dharma',
        ];
      case 5: // Athlete
        return [
          'Endurance, running & fitness',
          'Competitive game prep & clutch mindset',
          'Injury recovery & mental reset',
          'Daily training discipline',
        ];
      case 6: // Student
        return [
          'High school & college exam prep',
          'Grad, medical & professional exams',
          'Study motivation & anti-procrastination',
          'Memory trust & test calm',
        ];
      case 7: // Parenting
        return [
          'Newborn & toddler patience',
          'School-age & teen parenting',
          'Releasing parental guilt',
          'Elder & family caregiver burnout',
        ];
      case 8: // Grief
        return [
          'Loss of parent or sibling',
          'Loss of partner or spouse',
          'Young adult grief (18-24)',
          'Anticipatory grief & family illness',
        ];
      case 9: // LGBTQIA+
        return [
          'Authenticity & coming out journey',
          'Resilience in challenging spaces',
          'Trans & non-binary celebration',
          'Chosen family & belonging',
        ];
      case 10: // Accessible
        return [
          'Sensory calming & grounding',
          'Daily pride & capability',
          'Social belonging & friendship',
          'Direct & simple encouragement',
        ];
      default:
        return [
          'Self-discovery',
          'Emotional regulation',
          'Finding clarity',
          'Building confidence',
        ];
    }
  }

  static const List<String> subArchetypeEmojis = ['🎯', '🌀', '🧭', '🔑'];

  // --- Skepticism Labels ---
  static const List<String> skepticismLabels = [
    'Yes, they feel cheesy and I mentally resist them',
    'Sometimes — depends on the wording',
    'I\'ve never really tried them properly',
    'No, I\'m open and excited to receive them',
  ];
  static const List<String> skepticismEmojis = ['🙄', '😐', '🤷', '💫'];

  // --- Inner Critic Labels ---
  static const List<String> innerCriticLabels = [
    '"You\'re not good enough"',
    '"Everyone is ahead of you"',
    '"You\'re going to fail again"',
    '"You don\'t deserve good things"',
    '"Something bad is about to happen"',
    '"You\'re too much / not enough"',
  ];
  static const List<String> innerCriticEmojis = ['🗣️', '🗣️', '🗣️', '🗣️', '🗣️', '🗣️'];

  // --- Tone Labels ---
  static const List<String> toneLabels = [
    'Gentle, warm & grounding — like a safe hug',
    'Bold, empowering & confident — like a coach in my corner',
    'Direct, clear & action-oriented — no fluff, just truth',
    'Wise, philosophical & stoic — timeless perspective',
    'Simple, sensory & calming — easy to absorb',
  ];
  static const List<String> toneEmojis = ['🌿', '🔥', '⚡', '🏛️', '🧩'];

  // --- Peak Need Time Labels ---
  static const List<String> peakNeedTimeLabels = [
    'Morning — starting the day with clarity',
    'Night — calming down before sleep',
    'Throughout the day — whenever I spiral',
    'Before high-stakes moments (meetings, exams, dates)',
  ];
  static const List<String> peakNeedTimeEmojis = ['🌅', '🌙', '🔄', '🏢'];

  // --- Daily Commitment Labels ---
  static const List<String> dailyCommitmentLabels = [
    '3 minutes — quick reset',
    '5 minutes — focused intention',
    '10 minutes — deeper immersion',
    '15+ minutes — full session',
  ];
  static const List<String> dailyCommitmentEmojis = ['⚡', '🎯', '🧘', '🌊'];

  // --- Resonance Labels ---
  static const List<String> resonanceLabels = [
    'Yes, that hits perfectly',
    'Close, but make it gentler',
    'Close, but make it bolder',
  ];
  static const List<String> resonanceEmojis = ['💯', '🔄', '🔄'];

  /// Returns the user's display name, or 'friend' as fallback
  String get displayName =>
      userName.trim().isNotEmpty ? userName.trim() : 'friend';

  /// Returns the active emotional track based on user's initial intent
  EmotionalTrack get activeTrack {
    if (intentIndex == 2 || emotionalStateIndex == 4) {
      return EmotionalTrack.expansion;
    }
    if (intentIndex == 4) {
      return EmotionalTrack.alignment;
    }
    if (intentIndex == 0 || intentIndex == 1 || intentIndex == 3 || emotionalStateIndex == 1 || emotionalStateIndex == 3) {
      return EmotionalTrack.restoration;
    }
    return EmotionalTrack.adaptive;
  }

  /// Evaluates the typed 2AM/late-night thought for high-agency/ambition polarity vs distress
  bool get isHighAgencyThought {
    final text = twoAmThought.toLowerCase().trim();
    if (text.isEmpty) {
      return activeTrack == EmotionalTrack.expansion;
    }

    final highAgencyKeywords = [
      'excite', 'excited', 'build', 'startup', 'scale', 'scaling', 'money', 'business', 
      'goal', 'goals', 'win', 'winning', 'project', 'launch', 'workout', 'pr', 'gym',
      'code', 'app', 'feature', 'create', 'creative', 'future', 'idea', 'ideas',
      'achieve', 'ambition', 'career', 'revenue', 'invest', 'investing', 'finish',
      'solve', 'solving', 'energy', 'pumped', 'ready', 'driven', 'drive', 'hustle',
      'company', 'growth', 'grow', 'progress', 'train', 'training'
    ];

    final distressKeywords = [
      'sad', 'depressed', 'crying', 'cry', 'hurt', 'pain', 'broken', 'heartbreak',
      'ex', 'divorce', 'panic', 'terror', 'terrified', 'scared', 'afraid', 'grief',
      'loss', 'died', 'death', 'lonely', 'alone', 'empty', 'hopeless', 'anxious',
      'worry', 'worried', 'fail', 'failing', 'drown', 'drowning', 'regret'
    ];

    int agencyScore = 0;
    int distressScore = 0;

    for (final kw in highAgencyKeywords) {
      if (text.contains(kw)) agencyScore++;
    }
    for (final kw in distressKeywords) {
      if (text.contains(kw)) distressScore++;
    }

    if (agencyScore > distressScore) return true;
    if (distressScore > agencyScore) return false;
    return activeTrack == EmotionalTrack.expansion;
  }

  /// Dynamic prompt for Screen 6 (2 AM question)
  String getTwoAmPrompt() {
    if (isHighAgencyThought || activeTrack == EmotionalTrack.expansion) {
      return '$displayName, this is just between us.\nWhat big project, ambition, or vision has you wired late at night?';
    }
    if (activeTrack == EmotionalTrack.alignment) {
      return '$displayName, this is just between us.\nWhat deep question or calling comes to you when the world goes quiet?';
    }
    return '$displayName, this is just between us.\nWhat thought keeps you awake at 2 AM?';
  }

  /// Dynamic validation text for Screen 7
  String getValidationText() {
    if (isHighAgencyThought) {
      return '$displayName, that level of drive is rare.\n\nChanneling intense energy into clear, calm execution is why AVAN exists.\n\nLet\'s harness your momentum.';
    }
    if (activeTrack == EmotionalTrack.alignment) {
      return '$displayName, listening to that deeper inner voice takes stillness.\n\nTrusting your intuition and aligning your purpose is why this space exists.\n\nLet\'s tune your frequency.';
    }
    return '$displayName, that takes courage to say out loud.\n\nWhat you\'re feeling? It\'s more common than you think.\n\nAnd it\'s exactly why this sanctuary exists.';
  }

  /// Dynamic somatic prompt for Screen 8
  String getSomaticPrompt() {
    if (isHighAgencyThought) {
      return 'When that drive hits, how does your energy express itself physically in your body?';
    }
    return 'When that thought hits, where do you feel it most in your body?';
  }

  /// Dynamic somatic option labels for Screen 8
  List<String> getSomaticLabels() {
    if (isHighAgencyThought) {
      return somaticExpansionLabels;
    }
    return somaticLabels;
  }

  /// Dynamic somatic emojis for Screen 8
  List<String> getSomaticEmojis() {
    if (isHighAgencyThought) {
      return somaticExpansionEmojis;
    }
    return somaticEmojis;
  }

  /// Dynamic previous attempts prompt for Screen 9
  String getPreviousAttemptsPrompt() {
    if (isHighAgencyThought) {
      return 'What routines or tools have you tried to maintain your edge?';
    }
    return 'Have you tried anything before to feel better?';
  }

  /// Dynamic previous attempts labels for Screen 9
  List<String> getPreviousAttemptsLabels() {
    if (isHighAgencyThought) {
      return previousPerformanceLabels;
    }
    return previousAttemptsLabels;
  }

  /// Dynamic previous attempts emojis for Screen 9
  List<String> getPreviousAttemptsEmojis() {
    if (isHighAgencyThought) {
      return previousPerformanceEmojis;
    }
    return previousAttemptsEmojis;
  }

  /// Resolves the primary UserArchetype enum from archetypeIndex
  UserArchetype getPrimaryArchetype() {
    switch (archetypeIndex) {
      case 0: return UserArchetype.careerProfessional;
      case 1: return UserArchetype.heartbreakSurvivor;
      case 2: return UserArchetype.anxiousOverthinker;
      case 3: return UserArchetype.selfImprovement;
      case 4: return UserArchetype.spiritualSeeker;
      case 5: return UserArchetype.athlete;
      case 6: return UserArchetype.student;
      case 7: return UserArchetype.parentCaregiver;
      case 8: return UserArchetype.grievingIndividual;
      case 9: return UserArchetype.lgbtqia;
      case 10: return UserArchetype.personWithIDD;
      default: return UserArchetype.selfImprovement;
    }
  }

  /// Derives an intelligent Secondary Archetype to activate 75/25 multi-archetype convex blending
  UserArchetype? deriveSecondaryArchetype(UserArchetype primary) {
    if (intentIndex == 0 || emotionalStateIndex == 1) { // Racing mind / anxious
      if (primary != UserArchetype.anxiousOverthinker) return UserArchetype.anxiousOverthinker;
    }
    if (intentIndex == 1 || emotionalStateIndex == 3) { // Healing / grief / heartbreak
      if (primary != UserArchetype.heartbreakSurvivor && primary != UserArchetype.grievingIndividual) {
        return UserArchetype.heartbreakSurvivor;
      }
    }
    if (intentIndex == 2 || emotionalStateIndex == 4) { // Level up / restless
      if (primary != UserArchetype.selfImprovement) return UserArchetype.selfImprovement;
    }
    if (intentIndex == 4) { // Purpose & Abundance
      if (primary != UserArchetype.spiritualSeeker) return UserArchetype.spiritualSeeker;
    }
    if (lifeStageIndex == 0) { // Student life stage
      if (primary != UserArchetype.student) return UserArchetype.student;
    }
    if (lifeStageIndex == 1) { // Early career
      if (primary != UserArchetype.careerProfessional) return UserArchetype.careerProfessional;
    }
    if (bestSelfIndex == 0) { // Speaks up without apologizing
      if (primary != UserArchetype.careerProfessional) return UserArchetype.careerProfessional;
    }
    if (bestSelfIndex == 2) { // Takes action without overthinking
      if (primary != UserArchetype.selfImprovement) return UserArchetype.selfImprovement;
    }
    return null;
  }

  /// Resolves the AffirmationTone enum from toneIndex
  AffirmationTone getAffirmationTone() {
    switch (toneIndex) {
      case 0: return AffirmationTone.gentleAndGrounding;
      case 1: return AffirmationTone.empowering;
      case 2: return AffirmationTone.directAndActionable;
      case 3: return AffirmationTone.philosophical;
      case 4: return AffirmationTone.simpleAndClear;
      default: return AffirmationTone.empowering;
    }
  }

  /// Returns selected sub-level label
  String getSelectedSubLevel() {
    final subLabels = getSubArchetypeLabels();
    if (subArchetypeIndex >= 0 && subArchetypeIndex < subLabels.length) {
      return subLabels[subArchetypeIndex];
    }
    return 'General';
  }

  /// Returns the believability preference based on skepticism
  double get believabilityPreference {
    switch (skepticismIndex) {
      case 0: return 0.92; // Guarded - ultra-realistic
      case 1: return 0.80; // Sometimes
      case 2: return 0.70; // Never tried
      case 3: return 0.55; // Open & excited - bold
      default: return 0.75;
    }
  }

  /// Returns the short version of the 2AM thought for synthesis display
  String get shortTwoAmThought {
    if (twoAmThought.isEmpty) return '';
    return twoAmThought.length > 34
        ? '${twoAmThought.substring(0, 34)}...'
        : twoAmThought;
  }

  /// Returns the short version of the limiting belief
  String get shortLimitingBelief {
    if (limitingBelief.isEmpty) return '';
    return limitingBelief.length > 34
        ? '${limitingBelief.substring(0, 34)}...'
        : limitingBelief;
  }
}
