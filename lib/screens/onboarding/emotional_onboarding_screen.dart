import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_archetype.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/onboarding_animations.dart';
import '../../widgets/liquid_glass_input_field.dart';
import '../../widgets/liquid_glass_chip.dart';
import 'loading_screen.dart';

/// Hyper-Personalized Conversational Onboarding Experience
/// Combines freeform conversational typing, quick-tap smart suggestion chips,
/// frictionless single-tap auto-advancing choice cards, and AVAN's 16D vector synthesis.
///
/// Flow:
/// 1. Sanctuary Welcome & Name Input (Type)
/// 2. Somatic State & Inner Landscape (Single-Tap Choice)
/// 3. Deep Friction & Current Situation (Type + Smart Suggestion Chips)
/// 4. Core Growth & Healing Archetype (Single-Tap Choice)
/// 5. Desired Shift & Daily Aspiration (Type + Smart Suggestion Chips)
/// 6. Believability & Skepticism Calibration (Anti-Toxic Positivity)
/// 7. Delivery Tone & Voice Preference (Single-Tap Choice)
/// -> Transitions to LoadingScreen (Neural & Semantic Synthesis)
class EmotionalOnboardingScreen extends StatefulWidget {
  const EmotionalOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<EmotionalOnboardingScreen> createState() =>
      _EmotionalOnboardingScreenState();
}

class _EmotionalOnboardingScreenState extends State<EmotionalOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 7;

  // Controllers for typed inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _challengeController = TextEditingController();
  final TextEditingController _aspirationController = TextEditingController();

  // State Selections
  String _selectedMood = 'Quiet & Seeking Peace';
  UserArchetype _selectedArchetype = UserArchetype.careerProfessional;
  final Set<String> _selectedSubLevels = {};
  int _selectedBelievabilityIndex = 1; // Default b* = 0.75
  int _selectedToneIndex = 0; // Gentle & Grounding

  bool _isAutoAdvancing = false;

  // Screen 2 Options: Somatic Mood
  final List<Map<String, String>> _moodOptions = [
    {
      'emoji': '🌿',
      'label': 'Quiet & Seeking Peace',
      'desc': 'Nervous system feels slow; needing gentle grounding.',
    },
    {
      'emoji': '⚡',
      'label': 'Anxious & Racing Mind',
      'desc': 'Overthinking and mental loops taking over.',
    },
    {
      'emoji': '🔥',
      'label': 'Fired Up & Ambitious',
      'desc': 'High energy, ready to conquer goals and push forward.',
    },
    {
      'emoji': '💔',
      'label': 'Heavy-Hearted & Grieving',
      'desc': 'Navigating emotional pain, heartache, or sudden change.',
    },
    {
      'emoji': '🪫',
      'label': 'Exhausted & Drained',
      'desc': 'Burnout from high demands; need deep cognitive rest.',
    },
  ];

  // Screen 3 Suggestion Chips (Friction / Challenge)
  final List<Map<String, String>> _challengeChips = [
    {'emoji': '💼', 'text': 'Imposter syndrome at work'},
    {'emoji': '🌙', 'text': 'Late-night overthinking'},
    {'emoji': '💔', 'text': 'Heartbreak & letting go'},
    {'emoji': '🏃', 'text': 'Procrastination & lack of drive'},
    {'emoji': '⚖️', 'text': 'Comparing myself to others'},
    {'emoji': '🛡️', 'text': 'Fear of failure & judgment'},
    {'emoji': '🔋', 'text': 'Burnout & deep fatigue'},
    {'emoji': '📚', 'text': 'Pressure around exams/performance'},
  ];

  // Screen 4 Options: Core Focus Archetype
  final List<Map<String, dynamic>> _archetypeOptions = [
    {
      'archetype': UserArchetype.careerProfessional,
      'title': 'Career & Leadership',
      'icon': '💼',
      'subtitle': 'Executive presence, imposter syndrome & ambition',
      'subLevel': 'Founder / Corporate High-Performer',
    },
    {
      'archetype': UserArchetype.anxiousOverthinker,
      'title': 'Anxiety Relief & Somatic Calm',
      'icon': '🌊',
      'subtitle': 'Bedtime loops, panic, and racing overthinking',
      'subLevel': 'Panic Attacks & Bedtime Rumination',
    },
    {
      'archetype': UserArchetype.heartbreakSurvivor,
      'title': 'Heartbreak Recovery & Self-Love',
      'icon': '💔',
      'subtitle': 'Rebuilding self-worth after romantic loss or divorce',
      'subLevel': 'Fresh Breakup & Self-Worth Reclaim',
    },
    {
      'archetype': UserArchetype.selfImprovement,
      'title': 'Stoic Discipline & Daily Focus',
      'icon': '🏛️',
      'subtitle': 'Consistent habits, mental toughness & deep work',
      'subLevel': 'Daily Habit & Consistency Optimizer',
    },
    {
      'archetype': UserArchetype.spiritualSeeker,
      'title': 'Abundance & Higher Purpose',
      'icon': '🌌',
      'subtitle': 'Manifestation, energetic alignment & clarity',
      'subLevel': 'Law of Attraction & Manifestation Alignment',
    },
  ];

  // Screen 5 Suggestion Chips (Aspiration / Desired Shift)
  final List<Map<String, String>> _aspirationChips = [
    {'emoji': '🦁', 'text': 'Unshakeable self-worth'},
    {'emoji': '🕊️', 'text': 'Deep calm in my chest'},
    {'emoji': '🎯', 'text': 'Laser focus without resistance'},
    {'emoji': '☀️', 'text': 'Waking up energized and grateful'},
    {'emoji': '⚓', 'text': 'Steady boundary against chaos'},
    {'emoji': '💫', 'text': 'Manifesting financial freedom'},
    {'emoji': '🌱', 'text': 'Total peace with my past'},
  ];

  // Screen 6 Options: Believability Calibration
  final List<Map<String, dynamic>> _believabilityOptions = [
    {
      'preference': 0.92,
      'title': 'Guarded & Realistic',
      'subtitle': 'My inner critic rejects cheesy positivity',
      'desc': 'Ultra-grounding, low-friction affirmations. Zero toxic positivity. Safe somatic reassurance.',
      'icon': '🛡️',
      'badge': 'b* = 0.92 · Anti-Toxic Positivity',
    },
    {
      'preference': 0.75,
      'title': 'Balanced CBT Reframe',
      'subtitle': 'I need realistic cognitive reframing',
      'desc': 'Balanced CBT affirmations that acknowledge difficulty while opening new mental pathways.',
      'icon': '⚖️',
      'badge': 'b* = 0.75 · Balanced CBT',
    },
    {
      'preference': 0.55,
      'title': 'Bold & Aspirational',
      'subtitle': 'I embrace bold, magnetic stretch goals',
      'desc': 'Fast-paced, bold affirmations. You thrive when challenged to step into a bigger reality.',
      'icon': '🚀',
      'badge': 'b* = 0.55 · High Agency',
    },
  ];

  // Screen 7 Options: Affirmation Delivery Tone
  final List<Map<String, dynamic>> _toneOptions = [
    {
      'tone': AffirmationTone.gentleAndGrounding,
      'title': 'Gentle & Grounding',
      'subtitle': 'Compassionate, CBT-aligned, zero pressure',
      'desc': 'Soft, validating words that steady your nervous system without false promises.',
      'icon': '🌿',
    },
    {
      'tone': AffirmationTone.empowering,
      'title': 'Empowering & Confident',
      'subtitle': 'Bold, magnetic & uplifting',
      'desc': 'High-energy affirmations that awaken your inner strength and confidence.',
      'icon': '🔥',
    },
    {
      'tone': AffirmationTone.directAndActionable,
      'title': 'Direct & Action-Driven',
      'subtitle': 'Momentum, discipline & follow-through',
      'desc': 'Straightforward, pragmatic statements focused on execution and agency.',
      'icon': '⚡',
    },
    {
      'tone': AffirmationTone.philosophical,
      'title': 'Philosophical & Stoic',
      'subtitle': 'Perspective, emotional control & poise',
      'desc': 'Timeless reflections on internal locus of control and mental peace.',
      'icon': '🏛️',
    },
    {
      'tone': AffirmationTone.simpleAndClear,
      'title': 'Simple, Sensory & Direct',
      'subtitle': 'Accessible, calming, sensory cues',
      'desc': 'Concrete sensory anchors with low cognitive load and clear clarity.',
      'icon': '🧩',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _challengeController.dispose();
    _aspirationController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _currentPage = page;
      _isAutoAdvancing = false;
    });

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _triggerAutoAdvance(VoidCallback onSelect) {
    if (_isAutoAdvancing) return;
    HapticFeedback.selectionClick();
    onSelect();
    setState(() {
      _isAutoAdvancing = true;
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        if (_currentPage < _totalPages - 1) {
          _goToPage(_currentPage + 1);
        } else {
          _finishOnboarding();
        }
      }
    });
  }

  void _finishOnboarding() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final String name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Alex';

    final String challenge = _challengeController.text.trim();
    final String aspiration = _aspirationController.text.trim();

    final selectedTone = _toneOptions[_selectedToneIndex]['tone'] as AffirmationTone;
    final selectedBelievability =
        _believabilityOptions[_selectedBelievabilityIndex]['preference'] as double;

    List<String> subLevels = _selectedSubLevels.toList();
    if (subLevels.isEmpty) {
      final defaultSub = _archetypeOptions
          .firstWhere((opt) => opt['archetype'] == _selectedArchetype)['subLevel'] as String;
      subLevels.add(defaultSub);
    }

    appProvider.setUserArchetypeProfile(
      primary: [_selectedArchetype],
      secondary: [],
      subLevels: subLevels,
      tone: selectedTone,
      believabilityPreference: selectedBelievability,
      userName: name,
      typedChallenge: challenge,
      typedAspiration: aspiration,
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoadingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildScreen1Name(),
                  _buildScreen2Mood(),
                  _buildScreen3Challenge(),
                  _buildScreen4Archetype(),
                  _buildScreen5Aspiration(),
                  _buildScreen6Believability(),
                  _buildScreen7Tone(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _goToPage(_currentPage - 1),
                )
              : const SizedBox(width: 40),
          Text(
            'AVAN',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              letterSpacing: 2.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x14FFFFFF)),
            ),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.growthAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 1: Welcome & Name Input (Type)
  // ===========================================================================
  Widget _buildScreen1Name() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.growthAccent.withOpacity(0.12),
              border: Border.all(color: AppColors.growthAccent.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.growthAccent.withOpacity(0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.growthAccent,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const TypewriterText(
            text: 'Welcome to AVAN.\nBefore we begin, what should I call you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 12),
          Text(
            'Your daily affirmations and neural calibrations will be personalized around your name.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          BottomPopItem(
            delay: const Duration(milliseconds: 200),
            child: LiquidGlassInputField(
              controller: _nameController,
              hintText: 'Enter your name or nickname',
              labelText: 'Your Identity',
              autofocus: true,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              onSubmitted: () => _goToPage(1),
            ),
          ),
          const SizedBox(height: 48),
          BottomPopItem(
            delay: const Duration(milliseconds: 320),
            child: CustomButton(
              text: 'Begin Sanctuary',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _goToPage(1),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 2: Somatic Check-In & Inner State (Single-Tap Choice)
  // ===========================================================================
  Widget _buildScreen2Mood() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'friend';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypewriterText(
            text: 'Welcome, $name.\nHow is your internal landscape feeling today?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap your current state to tune your nervous system baseline.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._moodOptions.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            final isSelected = _selectedMood == m['label'];

            return BottomPopItem(
              delay: Duration(milliseconds: 140 + idx * 60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () {
                    _triggerAutoAdvance(() {
                      _selectedMood = m['label']!;
                    });
                  },
                  accentColor: AppColors.growthAccent,
                  glowIntensity: isSelected ? 0.7 : 0.0,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.growthAccent.withOpacity(0.18)
                              : AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.growthAccent.withOpacity(0.5)
                                : const Color(0x1AFFFFFF),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            m['emoji']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['label']!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              m['desc']!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.growthAccent,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 3: Deep Friction & Current Situation (Type + Quick Chips)
  // ===========================================================================
  Widget _buildScreen3Challenge() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TypewriterText(
            text: 'What thought or situation has been weighing heaviest on your mind lately?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'Type freely in your own words, or tap common friction points below to autofill.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          BottomPopItem(
            delay: const Duration(milliseconds: 160),
            child: LiquidGlassInputField(
              controller: _challengeController,
              hintText: 'e.g. Stressed about my career promotion, constantly second-guessing myself...',
              labelText: 'Current Friction',
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'OR TAP SUGGESTIONS TO AUTOFILL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          BottomPopItem(
            delay: const Duration(milliseconds: 240),
            child: Wrap(
              children: _challengeChips.map((chip) {
                final isContained = _challengeController.text.contains(chip['text']!);
                return LiquidGlassChip(
                  label: chip['text']!,
                  emoji: chip['emoji'],
                  isSelected: isContained,
                  accentColor: AppColors.growthAccent,
                  onTap: () {
                    setState(() {
                      if (_challengeController.text.trim().isEmpty) {
                        _challengeController.text = chip['text']!;
                      } else if (!isContained) {
                        _challengeController.text =
                            '${_challengeController.text.trim()}, ${chip['text']!}';
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          BottomPopItem(
            delay: const Duration(milliseconds: 320),
            child: CustomButton(
              text: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _goToPage(3),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 4: Core Growth & Healing Archetype (Single-Tap Choice)
  // ===========================================================================
  Widget _buildScreen4Archetype() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TypewriterText(
            text: 'Which dimension of your life feels most urgent to strengthen?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'This anchors your primary 16D psychological vector in the sanctuary.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._archetypeOptions.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            final archetype = opt['archetype'] as UserArchetype;
            final isSelected = _selectedArchetype == archetype;

            return BottomPopItem(
              delay: Duration(milliseconds: 140 + idx * 60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () {
                    _triggerAutoAdvance(() {
                      _selectedArchetype = archetype;
                      _selectedSubLevels.clear();
                      _selectedSubLevels.add(opt['subLevel'] as String);
                    });
                  },
                  accentColor: AppColors.growthAccent,
                  glowIntensity: isSelected ? 0.7 : 0.0,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.growthAccent.withOpacity(0.18)
                              : AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.growthAccent.withOpacity(0.5)
                                : const Color(0x1AFFFFFF),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            opt['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              opt['subtitle'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.growthAccent,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 5: Desired Shift / Dream State (Type + Quick Chips)
  // ===========================================================================
  Widget _buildScreen5Aspiration() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TypewriterText(
            text: 'When you close your eyes and listen, what internal shift do you want to feel most?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'Share how you want to feel when you wake up each day.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          BottomPopItem(
            delay: const Duration(milliseconds: 160),
            child: LiquidGlassInputField(
              controller: _aspirationController,
              hintText: 'e.g. Unshakable confidence without needing validation, feeling deeply at peace...',
              labelText: 'Your Desired Shift',
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'OR TAP OUTCOMES TO AUTOFILL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          BottomPopItem(
            delay: const Duration(milliseconds: 240),
            child: Wrap(
              children: _aspirationChips.map((chip) {
                final isContained = _aspirationController.text.contains(chip['text']!);
                return LiquidGlassChip(
                  label: chip['text']!,
                  emoji: chip['emoji'],
                  isSelected: isContained,
                  accentColor: AppColors.growthAccent,
                  onTap: () {
                    setState(() {
                      if (_aspirationController.text.trim().isEmpty) {
                        _aspirationController.text = chip['text']!;
                      } else if (!isContained) {
                        _aspirationController.text =
                            '${_aspirationController.text.trim()}, ${chip['text']!}';
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          BottomPopItem(
            delay: const Duration(milliseconds: 320),
            child: CustomButton(
              text: 'Calibrate Mindset',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _goToPage(5),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 6: Believability & Skepticism Calibration (Single-Tap Choice)
  // ===========================================================================
  Widget _buildScreen6Believability() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TypewriterText(
            text: 'Affirmations only work if your mind believes them.\nHow does your inner critic react to positive words?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'We calibrate the cognitive believability threshold (b*) to protect against toxic positivity.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._believabilityOptions.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            final isSelected = _selectedBelievabilityIndex == idx;

            return BottomPopItem(
              delay: Duration(milliseconds: 140 + idx * 70),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () {
                    _triggerAutoAdvance(() {
                      _selectedBelievabilityIndex = idx;
                    });
                  },
                  accentColor: AppColors.growthAccent,
                  glowIntensity: isSelected ? 0.7 : 0.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            opt['icon'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['title'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  opt['subtitle'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isSelected
                                        ? AppColors.growthAccent
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected) ...[
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.growthAccent,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        opt['desc'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.growthAccent.withOpacity(0.4)
                                : const Color(0x14FFFFFF),
                          ),
                        ),
                        child: Text(
                          opt['badge'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.growthAccent
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 7: Delivery Tone & Voice Preference (Single-Tap Choice)
  // ===========================================================================
  Widget _buildScreen7Tone() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TypewriterText(
            text: 'How should your daily affirmations be delivered to you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.growthAccent,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the primary voice modality for your audio meditations.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._toneOptions.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            final isSelected = _selectedToneIndex == idx;

            return BottomPopItem(
              delay: Duration(milliseconds: 140 + idx * 50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () {
                    _triggerAutoAdvance(() {
                      _selectedToneIndex = idx;
                    });
                  },
                  accentColor: AppColors.growthAccent,
                  glowIntensity: isSelected ? 0.7 : 0.0,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.growthAccent.withOpacity(0.18)
                              : AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.growthAccent.withOpacity(0.5)
                                : const Color(0x1AFFFFFF),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            opt['icon'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              opt['desc'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.growthAccent,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
