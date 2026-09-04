import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_archetype.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import 'loading_screen.dart';

/// 6-Screen High-Efficacy Emotional Onboarding Experience
/// Clinically aligned, psychologically grounded, and fully integrated with the 16D vector engine.
///
/// Flow:
/// 1. Welcome & Somatic Center (Presence)
/// 2. Neuro-Adaptive Commitment (Science-backed Agency)
/// 3. Creator's Trust Bridge (Dignified Vulnerability)
/// 4. Communication Tone (All 5 Modalities)
/// 5. Believability & Skepticism Calibration (b* in [0.55, 0.92])
/// 6. Focus Archetypes & Life Context (16D Profile Synthesis)
/// -> Transitions to LoadingScreen -> PrescriptionRevealScreen
class EmotionalOnboardingScreen extends StatefulWidget {
  const EmotionalOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<EmotionalOnboardingScreen> createState() =>
      _EmotionalOnboardingScreenState();
}

class _EmotionalOnboardingScreenState extends State<EmotionalOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

  Timer? _welcomeHoldTimer;

  // Screen 4: Tone (All 5 Affirmation Tones)
  int _selectedToneIndex = 0;
  final List<Map<String, dynamic>> _toneOptions = [
    {
      'tone': AffirmationTone.gentleAndGrounding,
      'title': 'Gentle & Grounding',
      'subtitle': 'Process-oriented, CBT/compassion, zero toxic positivity',
      'desc': 'Soft, validating words that steady your nervous system without false promises.',
      'icon': '🌿',
    },
    {
      'tone': AffirmationTone.empowering,
      'title': 'Empowering & Confident',
      'subtitle': 'Bold, courageous & uplifting',
      'desc': 'High-energy affirmations that awaken your inner strength and confidence.',
      'icon': '🔥',
    },
    {
      'tone': AffirmationTone.directAndActionable,
      'title': 'Direct & Action-Driven',
      'subtitle': 'Momentum, discipline & clear execution',
      'desc': 'Straightforward, pragmatic statements focused on follow-through and agency.',
      'icon': '⚡',
    },
    {
      'tone': AffirmationTone.philosophical,
      'title': 'Philosophical & Stoic',
      'subtitle': 'Perspective, emotional control & deep wisdom',
      'desc': 'Timeless reflections on internal locus of control and mental poise.',
      'icon': '🏛️',
    },
    {
      'tone': AffirmationTone.simpleAndClear,
      'title': 'Simple, Sensory & Direct',
      'subtitle': 'Accessible, neurodiversity-friendly calming',
      'desc': 'Concrete sensory cues and direct, low-cognitive-load affirmations.',
      'icon': '🧩',
    },
  ];

  AffirmationTone get _selectedTone =>
      _toneOptions[_selectedToneIndex]['tone'] as AffirmationTone;

  // Screen 5: Believability & Skepticism Calibration (b* preference)
  int _selectedBelievabilityIndex = 1; // Default to balanced 0.75
  final List<Map<String, dynamic>> _believabilityOptions = [
    {
      'preference': 0.55,
      'title': 'Energized & Ambitious',
      'subtitle': 'I embrace aspirational stretch goals',
      'desc': 'Fast-paced, bold affirmations. You thrive when challenged to step into a bigger reality.',
      'icon': '🚀',
      'badge': 'b* = 0.55 · High Agency',
    },
    {
      'preference': 0.75,
      'title': 'Cautiously Open',
      'subtitle': 'I need realistic cognitive reframing',
      'desc': 'Balanced CBT affirmations that acknowledge difficulty while opening new mental pathways.',
      'icon': '⚖️',
      'badge': 'b* = 0.75 · Balanced CBT',
    },
    {
      'preference': 0.92,
      'title': 'Guarded & Sensitive',
      'subtitle': 'My inner critic rejects cheesy positivity',
      'desc': 'Ultra-grounding, low-friction affirmations. Zero toxic positivity. Safe somatic reassurance.',
      'icon': '🛡️',
      'badge': 'b* = 0.92 · Anti-Toxic Positivity',
    },
  ];

  double get _selectedBelievability =>
      _believabilityOptions[_selectedBelievabilityIndex]['preference'] as double;

  // Screen 6: Focus Archetypes (Multi-select 1-3) & Sub-Levels
  final Set<UserArchetype> _selectedArchetypes = {
    UserArchetype.careerProfessional,
  };
  int _focusStage = 0; // 0 = Archetype Selection, 1 = Sub-Levels
  final Set<String> _selectedSubLevels = {};

  @override
  void initState() {
    super.initState();
    _welcomeHoldTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && _currentPage == 0) {
        _goToPage(1);
      }
    });
  }

  @override
  void dispose() {
    _welcomeHoldTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    _welcomeHoldTimer?.cancel();

    setState(() {
      _currentPage = page;
      _focusStage = 0;
    });

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finishOnboarding() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final archetypeList = _selectedArchetypes.toList();
    final primary = archetypeList.isNotEmpty
        ? archetypeList.first
        : UserArchetype.careerProfessional;
    final secondary =
        archetypeList.length > 1 ? archetypeList.sublist(1) : <UserArchetype>[];

    List<String> subLevels = _selectedSubLevels.toList();
    if (subLevels.isEmpty) {
      for (var a in archetypeList) {
        final meta = ArchetypeRegistry.getMetadata(a);
        if (meta.subLevels.isNotEmpty) {
          subLevels.add(meta.subLevels.first);
        }
      }
    }

    appProvider.setUserArchetypeProfile(
      primary: [primary],
      secondary: secondary,
      subLevels: subLevels,
      tone: _selectedTone,
      believabilityPreference: _selectedBelievability,
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
                  _buildScreen01Welcome(),
                  _buildScreen02Commitment(),
                  _buildScreen03CreatorTrust(),
                  _buildScreen04ToneSelection(),
                  _buildScreen05BelievabilityCalibration(),
                  _buildScreen06FocusAndContext(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    if (_currentPage == 0) {
      return const SizedBox(height: 20);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              if (_currentPage == 5 && _focusStage == 1) {
                setState(() {
                  _focusStage = 0;
                });
              } else {
                _goToPage(_currentPage - 1);
              }
            },
          ),
          Text(
            'AVAN',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppColors.textSecondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              _currentPage == 5 && _focusStage == 1
                  ? '6 / 6 · Context'
                  : '${_currentPage + 1} / $_totalPages',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === SCREEN 01: WELCOME & SOMATIC CENTER ===
  Widget _buildScreen01Welcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.goldAccent.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
            child: Text(
              'AVAN',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: 6.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Onboarding Experience & Emotional Flow',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌬️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Take a gentle breath in... and exhale.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          CustomButton(
            text: 'Begin Your Journey',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () => _goToPage(1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // === SCREEN 02: NEURO-ADAPTIVE COMMITMENT ===
  Widget _buildScreen02Commitment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Step into the reality\nyou choose.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your brain physically rewires itself according to the words you repeat. AVAN adapts to your exact emotional state to create permanent subconscious shifts.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          _buildFeatureRow('🧠', '16D Neuro-Adaptive Vector',
              'Personalized to your unique psychological profile.'),
          const SizedBox(height: 16),
          _buildFeatureRow('🛡️', 'Zero Toxic Positivity',
              'Grounded in clinical CBT, ACT, and self-compassion.'),
          const SizedBox(height: 16),
          _buildFeatureRow('🎙️', 'Spoken Neural Resonance',
              'Interactive voice repetition designed to bypass self-doubt.'),
          const Spacer(),
          CustomButton(
            text: 'Continue',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () => _goToPage(2),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // === SCREEN 03: CREATOR'S TRUST BRIDGE ===
  Widget _buildScreen03CreatorTrust() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CREATOR'S NOTE",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.goldAccent,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: GlassCard(
                accentColor: AppColors.goldAccent,
                glowIntensity: 0.3,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 48,
                        height: 0.7,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldAccent.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'I built AVAN from a season of intense uncertainty.\n\n'
                      'I learned firsthand that when life feels overwhelming, high-flown positive slogans don’t work. What works is intentional, believable language that calms your nervous system and reminds you of your inner agency.\n\n'
                      'AVAN is your private space to rebuild trust in yourself—step by step, one thought at a time.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.55,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— Alex, Founder of AVAN',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.goldAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "I'm Ready",
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () => _goToPage(3),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // === SCREEN 04: COMMUNICATION TONE (ALL 5 TONES) ===
  Widget _buildScreen04ToneSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like\nAVAN to speak to you?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AVAN adapts its language to what your mind is ready to receive.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _toneOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _toneOptions[index];
                final isSelected = _selectedToneIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedToneIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.goldAccent : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.goldAccent.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['icon'] as String, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Continue',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () => _goToPage(4),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // === SCREEN 05: BELIEVABILITY & SKEPTICISM CALIBRATION (NEW!) ===
  Widget _buildScreen05BelievabilityCalibration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How does your mind react\nto positive affirmations?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Affirmations must feel believable to rewire neural pathways. We tune AVAN to match your current skepticism.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _believabilityOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final opt = _believabilityOptions[index];
                final isSelected = _selectedBelievabilityIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedBelievabilityIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.goldAccent : AppColors.border,
                        width: isSelected ? 1.6 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.goldAccent.withOpacity(0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt['icon'] as String, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['subtitle'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                opt['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.goldAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  opt['badge'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Continue to Focus Area →',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () => _goToPage(5),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // === SCREEN 06: FOCUS ARCHETYPES & SITUATIONAL CONTEXT ===
  Widget _buildScreen06FocusAndContext() {
    if (_focusStage == 1) {
      return _buildSituationalSubLevels();
    }
    return _buildArchetypeSelection();
  }

  Widget _buildArchetypeSelection() {
    final archetypes = ArchetypeRegistry.allArchetypes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What should we focus\non together?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 1 to 3 focus areas that define your current chapter.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: archetypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final meta = archetypes[index];
                final isSelected = _selectedArchetypes.contains(meta.archetype);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        if (_selectedArchetypes.length > 1) {
                          _selectedArchetypes.remove(meta.archetype);
                        }
                      } else {
                        if (_selectedArchetypes.length < 3) {
                          _selectedArchetypes.add(meta.archetype);
                        }
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.goldAccent : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.goldAccent.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(meta.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meta.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meta.shortDescription,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Next: Specify Situation →',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: () {
              if (_selectedSubLevels.isEmpty) {
                for (var a in _selectedArchetypes) {
                  final meta = ArchetypeRegistry.getMetadata(a);
                  if (meta.subLevels.isNotEmpty) {
                    _selectedSubLevels.add(meta.subLevels.first);
                  }
                }
              }
              setState(() {
                _focusStage = 1;
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSituationalSubLevels() {
    final selectedMetas =
        _selectedArchetypes.map((a) => ArchetypeRegistry.getMetadata(a)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What best describes\nyour current situation?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your exact life context so AVAN can calibrate your playlists.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: selectedMetas.length,
              itemBuilder: (context, index) {
                final meta = selectedMetas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(meta.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            meta.title.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...meta.subLevels.map((subLevel) {
                        final isSubSelected = _selectedSubLevels.contains(subLevel);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSubSelected) {
                                  if (_selectedSubLevels.length > 1) {
                                    _selectedSubLevels.remove(subLevel);
                                  }
                                } else {
                                  _selectedSubLevels.add(subLevel);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSubSelected
                                    ? AppColors.goldAccent.withOpacity(0.12)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSubSelected
                                      ? AppColors.goldAccent
                                      : AppColors.border,
                                  width: isSubSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSubSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 18,
                                    color: isSubSelected
                                        ? AppColors.goldAccent
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      subLevel,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: isSubSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: AppColors.textPrimary,
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
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _focusStage = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Synthesize My Matrix ✨',
                  backgroundColor: AppColors.buttonDark,
                  textColor: Colors.white,
                  onPressed: _finishOnboarding,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
