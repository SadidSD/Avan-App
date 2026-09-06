/// Holds all user answers collected across the 25-screen onboarding flow.
/// Enables dynamic prompt generation by referencing previous answers.
class OnboardingState {
  // Phase 1: Identity & Trust
  String userName = '';
  int lifeStageIndex = -1; // 0-3
  int intentIndex = -1; // 0-5 (what brought you here)

  // Phase 2: Emotional Excavation
  int emotionalStateIndex = -1; // 0-4
  int timelineIndex = -1; // 0-3
  String twoAmThought = ''; // The 2AM typed thought
  int somaticIndex = -1; // 0-5 (where body feels it)
  int previousAttemptsIndex = -1; // 0-5
  int coreWoundIndex = -1; // 0-3 (within intent branch)

  // Phase 3: Aspiration & Vision
  String morningVision = ''; // How they want to wake up feeling
  int bestSelfIndex = -1; // 0-5
  String limitingBelief = ''; // Typed limiting belief
  int archetypeIndex = -1; // 0-4 (primary life dimension)
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

  // --- Somatic Labels ---
  static const List<String> somaticLabels = [
    'Chest — tightness, pressure, racing heart',
    'Head — foggy, spinning, headache',
    'Stomach — knots, nausea, heaviness',
    'Shoulders & neck — tension, clenching',
    'Throat — lump, difficulty speaking or breathing',
    'Everywhere / I\'m not sure',
  ];
  static const List<String> somaticEmojis = ['💓', '🧠', '😰', '💪', '🫁', '🤷'];

  // --- Previous Attempts Labels ---
  static const List<String> previousAttemptsLabels = [
    'Meditation or mindfulness apps',
    'Journaling or therapy',
    'Medication or supplements',
    'Exercise or physical routines',
    'Other self-help content (podcasts, books)',
    'Nothing yet — this is my first step',
  ];
  static const List<String> previousAttemptsEmojis = ['🧘', '📓', '💊', '🏃', '📱', '🚫'];

  // --- Core Wound Labels (dynamic, based on intentIndex) ---
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

  // --- Archetype Labels (Primary Life Dimension) ---
  static const List<String> archetypeLabels = [
    'Career, ambition & professional identity',
    'Love, relationships & emotional healing',
    'Mental health, anxiety & inner peace',
    'Discipline, habits & self-mastery',
    'Purpose, abundance & spiritual alignment',
  ];
  static const List<String> archetypeEmojis = ['💼', '💔', '🧠', '🏛️', '🌌'];

  // --- Sub-Archetype Labels (dynamic, based on archetypeIndex) ---
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
