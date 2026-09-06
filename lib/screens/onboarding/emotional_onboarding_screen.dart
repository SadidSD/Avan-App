import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_archetype.dart';
import '../../models/onboarding_state.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/onboarding_animations.dart';
import '../../widgets/onboarding_screen_builders.dart';
import 'prescription_reveal_screen.dart';

class EmotionalOnboardingScreen extends StatefulWidget {
  const EmotionalOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<EmotionalOnboardingScreen> createState() => _EmotionalOnboardingScreenState();
}

class _EmotionalOnboardingScreenState extends State<EmotionalOnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final int _totalPages = 23;
  int _currentPage = 0;
  final OnboardingState _state = OnboardingState();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _twoAmController = TextEditingController();
  final TextEditingController _morningVisionController = TextEditingController();
  final TextEditingController _limitingBeliefController = TextEditingController();

  // Screen 0
  Timer? _sanctuaryTimer;

  // Screen 7
  Timer? _validationTimer;

  // Screen 22 (Synthesis)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _synthesisTimer;
  int _synthesisStep = 0;

  @override
  void initState() {
    super.initState();
    _sanctuaryTimer = Timer(const Duration(milliseconds: 2500), () {
      _goToPage(1);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _twoAmController.dispose();
    _morningVisionController.dispose();
    _limitingBeliefController.dispose();
    _sanctuaryTimer?.cancel();
    _validationTimer?.cancel();
    _pulseController.dispose();
    _synthesisTimer?.cancel();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      if (page == 22) {
        _startSynthesis();
      }
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _triggerAutoAdvance(VoidCallback onSelect) {
    HapticFeedback.lightImpact();
    onSelect();
    Future.delayed(const Duration(milliseconds: 220), () {
      _goToPage(_currentPage + 1);
    });
  }

  void _startSynthesis() {
    _synthesisStep = 0;
    _pulseController.repeat(reverse: true);
    _synthesisTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        _synthesisStep++;
      });
      if (_synthesisStep >= 4) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          _finishOnboarding();
        });
      }
    });
  }

  void _finishOnboarding() {
    if (!mounted) return;
    _pulseController.stop();

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    UserArchetype selectedArchetype;
    switch (_state.archetypeIndex) {
      case 0:
        selectedArchetype = UserArchetype.careerProfessional;
        break;
      case 1:
        selectedArchetype = UserArchetype.heartbreakSurvivor;
        break;
      case 2:
        selectedArchetype = UserArchetype.anxiousOverthinker;
        break;
      case 3:
        selectedArchetype = UserArchetype.selfImprovement;
        break;
      case 4:
        selectedArchetype = UserArchetype.spiritualSeeker;
        break;
      default:
        selectedArchetype = UserArchetype.selfImprovement;
    }

    AffirmationTone selectedTone;
    switch (_state.toneIndex) {
      case 0:
        selectedTone = AffirmationTone.gentleAndGrounding;
        break;
      case 1:
        selectedTone = AffirmationTone.empowering;
        break;
      case 2:
        selectedTone = AffirmationTone.directAndActionable;
        break;
      case 3:
        selectedTone = AffirmationTone.philosophical;
        break;
      case 4:
        selectedTone = AffirmationTone.simpleAndClear;
        break;
      default:
        selectedTone = AffirmationTone.simpleAndClear;
    }

    final subLabels = _state.getSubArchetypeLabels();
    String selectedSubLevel = 'General';
    if (_state.subArchetypeIndex >= 0 && _state.subArchetypeIndex < subLabels.length) {
      selectedSubLevel = subLabels[_state.subArchetypeIndex];
    }

    appProvider.setUserArchetypeProfile(
      primary: [selectedArchetype],
      secondary: [],
      subLevels: [selectedSubLevel],
      tone: selectedTone,
      believabilityPreference: _state.believabilityPreference,
      userName: _state.displayName == 'friend' ? 'Alex' : _state.displayName,
      typedChallenge: _state.twoAmThought,
      typedAspiration: _state.morningVision,
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PrescriptionRevealScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showTopBar = _currentPage > 0 && _currentPage < 22;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showTopBar) _buildTopBar(),
            if (showTopBar) _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildScreen0Sanctuary(),
                  _buildScreen1Name(),
                  _buildScreen2LifeStage(),
                  _buildScreen3Intent(),
                  _buildScreen4EmotionalState(),
                  _buildScreen5Timeline(),
                  _buildScreen6TwoAmQuestion(),
                  _buildScreen7Validation(),
                  _buildScreen8Somatic(),
                  _buildScreen9PreviousAttempts(),
                  _buildScreen10CoreWound(),
                  _buildScreen11MorningVision(),
                  _buildScreen12BestSelf(),
                  _buildScreen13LimitingBelief(),
                  _buildScreen14Archetype(),
                  _buildScreen15SubArchetype(),
                  _buildScreen16Skepticism(),
                  _buildScreen17InnerCritic(),
                  _buildScreen18Tone(),
                  _buildScreen19PeakNeedTime(),
                  _buildScreen20DailyCommitment(),
                  _buildScreen21AffirmationPreview(),
                  _buildScreen22NeuralSynthesis(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: () => _goToPage(_currentPage - 1),
                )
              : const SizedBox(width: 40),
          Text(
            'AVAN',
            style: GoogleFonts.cormorantGaramond(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: 2.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.growthAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: GoogleFonts.inter(
                color: AppColors.growthAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: _currentPage / (_totalPages - 1),
      backgroundColor: AppColors.glassBorder,
      color: AppColors.growthAccent,
      minHeight: 2,
    );
  }

  // Screens
  Widget _buildScreen0Sanctuary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: TypewriterText(
          text: 'Welcome. This is your space.\nTake a breath.',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildScreen1Name() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.auto_awesome_rounded, color: AppColors.growthAccent, size: 32),
        const SizedBox(height: 16),
        Expanded(
          child: OnboardingTypeScreen(
            prompt: 'Before we begin, what should I call you?',
            controller: _nameController,
            hintText: 'Your name or nickname',
            ctaText: 'Continue',
            onContinue: () {
              if (_nameController.text.trim().isNotEmpty) {
                _state.userName = _nameController.text.trim();
              }
              _goToPage(2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScreen2LifeStage() {
    return OnboardingTapScreen(
      prompt: 'Nice to meet you, ${_state.displayName}. To understand where you are in life...',
      options: List.generate(OnboardingState.lifeStageLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.lifeStageEmojis[i],
          label: OnboardingState.lifeStageLabels[i],
        );
      }),
      selectedIndex: _state.lifeStageIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.lifeStageIndex = index)),
    );
  }

  Widget _buildScreen3Intent() {
    return OnboardingTapScreen(
      prompt: 'What brought you to AVAN today, ${_state.displayName}?',
      options: List.generate(OnboardingState.intentLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.intentEmojis[i],
          label: OnboardingState.intentLabels[i],
        );
      }),
      selectedIndex: _state.intentIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.intentIndex = index)),
    );
  }

  Widget _buildScreen4EmotionalState() {
    return OnboardingTapScreen(
      prompt: 'Right now, in this exact moment, your inner world feels...',
      options: List.generate(OnboardingState.emotionalStateLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.emotionalStateEmojis[i],
          label: OnboardingState.emotionalStateLabels[i],
        );
      }),
      selectedIndex: _state.emotionalStateIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.emotionalStateIndex = index)),
    );
  }

  Widget _buildScreen5Timeline() {
    return OnboardingTapScreen(
      prompt: 'And this feeling... how long has it been with you?',
      options: List.generate(OnboardingState.timelineLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.timelineEmojis[i],
          label: OnboardingState.timelineLabels[i],
        );
      }),
      selectedIndex: _state.timelineIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.timelineIndex = index)),
    );
  }

  Widget _buildScreen6TwoAmQuestion() {
    return OnboardingTypeScreen(
      prompt: '${_state.displayName}, this is just between us.\nWhat thought keeps you awake at 2 AM?',
      controller: _twoAmController,
      hintText: 'Type freely — no one else will see this.',
      maxLines: 3,
      ctaText: 'Share',
      onContinue: () {
        _state.twoAmThought = _twoAmController.text.trim();
        _goToPage(7);
      },
    );
  }

  Widget _buildScreen7Validation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: TypewriterText(
          text: '${_state.displayName}, that takes courage to say out loud.\n\nWhat you\'re feeling? It\'s more common than you think.\n\nAnd it\'s exactly why this space exists.',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          durationPerChar: const Duration(milliseconds: 30),
          onComplete: () {
            _validationTimer?.cancel();
            _validationTimer = Timer(const Duration(milliseconds: 1500), () {
              if (mounted) _goToPage(8);
            });
          },
        ),
      ),
    );
  }

  Widget _buildScreen8Somatic() {
    return OnboardingTapScreen(
      prompt: 'When that thought hits, where do you feel it most in your body?',
      options: List.generate(OnboardingState.somaticLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.somaticEmojis[i],
          label: OnboardingState.somaticLabels[i],
        );
      }),
      selectedIndex: _state.somaticIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.somaticIndex = index)),
    );
  }

  Widget _buildScreen9PreviousAttempts() {
    return OnboardingTapScreen(
      prompt: 'Have you tried anything before to feel better?',
      options: List.generate(OnboardingState.previousAttemptsLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.previousAttemptsEmojis[i],
          label: OnboardingState.previousAttemptsLabels[i],
        );
      }),
      selectedIndex: _state.previousAttemptsIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.previousAttemptsIndex = index)),
    );
  }

  Widget _buildScreen10CoreWound() {
    final labels = _state.getCoreWoundLabels();
    return OnboardingTapScreen(
      prompt: 'If you had to name the hardest part, ${_state.displayName}, which of these feels closest?',
      options: List.generate(labels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.coreWoundEmojis[i],
          label: labels[i],
        );
      }),
      selectedIndex: _state.coreWoundIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.coreWoundIndex = index)),
    );
  }

  Widget _buildScreen11MorningVision() {
    return OnboardingTypeScreen(
      prompt: 'Now imagine a different morning, ${_state.displayName}.\nYou wake up and feel... what?',
      controller: _morningVisionController,
      hintText: 'Describe in a few words',
      ctaText: 'That\'s what I want',
      onContinue: () {
        _state.morningVision = _morningVisionController.text.trim();
        _goToPage(12);
      },
    );
  }

  Widget _buildScreen12BestSelf() {
    return OnboardingTapScreen(
      prompt: 'When you imagine your best self, you see someone who...',
      options: List.generate(OnboardingState.bestSelfLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.bestSelfEmojis[i],
          label: OnboardingState.bestSelfLabels[i],
        );
      }),
      selectedIndex: _state.bestSelfIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.bestSelfIndex = index)),
    );
  }

  Widget _buildScreen13LimitingBelief() {
    return OnboardingTypeScreen(
      prompt: 'What\'s one belief about yourself you wish you could finally let go of?',
      controller: _limitingBeliefController,
      hintText: 'e.g. I\'m not good enough, I always fail, I don\'t deserve love',
      ctaText: 'Release it',
      onContinue: () {
        _state.limitingBelief = _limitingBeliefController.text.trim();
        _goToPage(14);
      },
    );
  }

  Widget _buildScreen14Archetype() {
    return OnboardingTapScreen(
      prompt: 'The part of your life that needs this the most right now is...',
      options: List.generate(OnboardingState.archetypeLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.archetypeEmojis[i],
          label: OnboardingState.archetypeLabels[i],
        );
      }),
      selectedIndex: _state.archetypeIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.archetypeIndex = index)),
    );
  }

  Widget _buildScreen15SubArchetype() {
    final labels = _state.getSubArchetypeLabels();
    return OnboardingTapScreen(
      prompt: 'Let\'s get more specific, ${_state.displayName}. Within that, what resonates most?',
      options: List.generate(labels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.subArchetypeEmojis[i],
          label: labels[i],
        );
      }),
      selectedIndex: _state.subArchetypeIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.subArchetypeIndex = index)),
    );
  }

  Widget _buildScreen16Skepticism() {
    return OnboardingTapScreen(
      prompt: 'Be honest, ${_state.displayName}.\nHave affirmations ever felt... fake to you?',
      options: List.generate(OnboardingState.skepticismLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.skepticismEmojis[i],
          label: OnboardingState.skepticismLabels[i],
        );
      }),
      selectedIndex: _state.skepticismIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.skepticismIndex = index)),
    );
  }

  Widget _buildScreen17InnerCritic() {
    return OnboardingTapScreen(
      prompt: 'When your inner critic speaks, it usually says something like...',
      options: List.generate(OnboardingState.innerCriticLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.innerCriticEmojis[i],
          label: OnboardingState.innerCriticLabels[i],
        );
      }),
      selectedIndex: _state.innerCriticIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.innerCriticIndex = index)),
    );
  }

  Widget _buildScreen18Tone() {
    return OnboardingTapScreen(
      prompt: 'I respond best to words that feel...',
      options: List.generate(OnboardingState.toneLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.toneEmojis[i],
          label: OnboardingState.toneLabels[i],
        );
      }),
      selectedIndex: _state.toneIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.toneIndex = index)),
    );
  }

  Widget _buildScreen19PeakNeedTime() {
    return OnboardingTapScreen(
      prompt: 'When do you need this the most?',
      options: List.generate(OnboardingState.peakNeedTimeLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.peakNeedTimeEmojis[i],
          label: OnboardingState.peakNeedTimeLabels[i],
        );
      }),
      selectedIndex: _state.peakNeedTimeIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.peakNeedTimeIndex = index)),
    );
  }

  Widget _buildScreen20DailyCommitment() {
    return OnboardingTapScreen(
      prompt: 'How much time feels realistic for your daily practice?',
      options: List.generate(OnboardingState.dailyCommitmentLabels.length, (i) {
        return OnboardingOption(
          emoji: OnboardingState.dailyCommitmentEmojis[i],
          label: OnboardingState.dailyCommitmentLabels[i],
        );
      }),
      selectedIndex: _state.dailyCommitmentIndex,
      onSelect: (index) => _triggerAutoAdvance(() => setState(() => _state.dailyCommitmentIndex = index)),
    );
  }

  Widget _buildScreen21AffirmationPreview() {
    String affirmationText;
    switch (_state.toneIndex) {
      case 0:
        affirmationText = '${_state.displayName}, you are safe. You are held. Every breath is proof that you belong here.';
        break;
      case 1:
        affirmationText = '${_state.displayName}, you are magnetic. Unstoppable. Every room changes when you walk in.';
        break;
      case 2:
        affirmationText = '${_state.displayName}, you have the power to act. Right now. No permission needed.';
        break;
      case 3:
        affirmationText = '${_state.displayName}, the obstacle is the way. Your struggle is forging something unbreakable.';
        break;
      default:
        affirmationText = '${_state.displayName}, you are exactly where you need to be. Trust the process.';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TypewriterText(
            text: '${_state.displayName}, based on everything you\'ve shared, here\'s a thought crafted just for you:',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),
          BottomPopItem(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.growthAccent.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.growthAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                affirmationText,
                style: GoogleFonts.cormorantGaramond(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Does this feel right?',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...List.generate(OnboardingState.resonanceLabels.length, (i) {
            final isSelected = _state.resonanceIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: BottomPopItem(
                delay: Duration(milliseconds: 400 + (i * 100)),
                child: GestureDetector(
                  onTap: () => _triggerAutoAdvance(() => setState(() => _state.resonanceIndex = i)),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    accentColor: AppColors.growthAccent,
                    glowIntensity: isSelected ? 0.7 : 0.0,
                    child: Row(
                      children: [
                        Text(OnboardingState.resonanceEmojis[i], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 16),
                        Text(
                          OnboardingState.resonanceLabels[i],
                          style: GoogleFonts.inter(
                            color: isSelected ? AppColors.growthAccent : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScreen22NeuralSynthesis() {
    final steps = [
      'Connecting to ${_state.displayName}\'s cognitive baseline...',
      _state.shortTwoAmThought.isEmpty ? 'Scanning 16D psychological landscape...' : 'Analyzing core friction: "${_state.shortTwoAmThought}"...',
      'Mapping resonance vector...',
      'Calibrating believability to ${(_state.believabilityPreference * 100).toInt()}%...',
      'Synthesizing ${_state.displayName}\'s personalized audio prescription...',
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.growthAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.growthAccent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.growthAccent,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.growthAccent),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            '${(((_synthesisStep + 1) / steps.length) * 100).toInt()}%',
            style: GoogleFonts.inter(
              color: AppColors.growthAccent,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              steps[_synthesisStep.clamp(0, steps.length - 1)],
              key: ValueKey<int>(_synthesisStep),
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NEURAL FREQUENCY CALIBRATION',
            style: GoogleFonts.inter(
              color: AppColors.growthAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
