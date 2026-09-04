import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_archetype.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'loading_screen.dart';

/// 8-Screen Emotional Onboarding Experience & Flow
/// Rooted in the AVAN UX Strategy: "The onboarding is a journey, not a form."
///
/// Flow:
/// 1. Welcome (Curious)
/// 2. Commitment (Participating)
/// 3. Vision (Imagining)
/// 4. Transformation (Possibility)
/// 5. Creator's Journey (Trust Bridge)
/// 6. Connection (Comfort & Handoff)
/// 7. Choice Style (Control & Tone)
/// 8. Honesty Focus (Vulnerability & 16D Personalization)
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

  // Typewriter state for screens 2 & 3
  Timer? _welcomeHoldTimer;
  Timer? _typewriterTimer;
  String _typedText = '';
  bool _isTypingComplete = false;

  // Screen 7 selection: Communication Style
  // 0 = Personal, 1 = Conversational, 2 = Formal
  int _selectedStyleIndex = 0;
  AffirmationTone get _selectedTone {
    switch (_selectedStyleIndex) {
      case 0:
        return AffirmationTone.gentleAndGrounding;
      case 1:
        return AffirmationTone.empowering;
      case 2:
      default:
        return AffirmationTone.philosophical;
    }
  }

  // Screen 8 selection: Focus Archetypes (Multi-select 1-3)
  final Set<UserArchetype> _selectedArchetypes = {
    UserArchetype.careerProfessional,
  };

  @override
  void initState() {
    super.initState();
    // Screen 1: Hold for 2.8 seconds, then advance to Screen 2
    _welcomeHoldTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted && _currentPage == 0) {
        _goToPage(1);
      }
    });
  }

  @override
  void dispose() {
    _welcomeHoldTimer?.cancel();
    _typewriterTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page > 7) return;
    _welcomeHoldTimer?.cancel();
    _typewriterTimer?.cancel();

    setState(() {
      _currentPage = page;
      _typedText = '';
      _isTypingComplete = false;
    });

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );

    // Initialize screen-specific typewriter animations
    if (page == 1) {
      _startTypewriter("Step into the reality you choose", speedMs: 45);
    } else if (page == 2) {
      _startTypewriter(
        "Hi, welcome to Avan.\n\nThe life you dream of begins here.\n\nManifest your reality with Avan.",
        speedMs: 38,
      );
    }
  }

  void _startTypewriter(String fullText, {int speedMs = 40}) {
    _typewriterTimer?.cancel();
    _typedText = '';
    _isTypingComplete = false;
    int index = 0;

    _typewriterTimer = Timer.periodic(Duration(milliseconds: speedMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index < fullText.length) {
        setState(() {
          _typedText = fullText.substring(0, index + 1);
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          _isTypingComplete = true;
        });
      }
    });
  }

  void _completeTypewriterInstantly(String fullText) {
    _typewriterTimer?.cancel();
    if (!_isTypingComplete) {
      setState(() {
        _typedText = fullText;
        _isTypingComplete = true;
      });
    }
  }

  void _finishOnboarding() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final archetypeList = _selectedArchetypes.toList();
    final primary = archetypeList.isNotEmpty
        ? archetypeList.first
        : UserArchetype.careerProfessional;
    final secondary =
        archetypeList.length > 1 ? archetypeList.sublist(1) : <UserArchetype>[];

    // Collect default sub-levels for primary archetype
    final meta = ArchetypeRegistry.getMetadata(primary);
    final subLevels = meta.subLevels.isNotEmpty ? [meta.subLevels.first] : <String>[];

    appProvider.setUserArchetypeProfile(
      primary: [primary],
      secondary: secondary,
      subLevels: subLevels,
      tone: _selectedTone,
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
            // Top Navigation Bar (Hidden on Screen 1)
            _buildTopBar(),

            // Screen Content PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Programmatic only
                children: [
                  _buildScreen01Welcome(),
                  _buildScreen02Commitment(),
                  _buildScreen03Vision(),
                  _buildScreen04Transformation(),
                  _buildScreen05CreatorJourney(),
                  _buildScreen06Connection(),
                  _buildScreen07ChoiceStyle(),
                  _buildScreen08FocusHonesty(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === TOP BAR ===
  Widget _buildTopBar() {
    if (_currentPage == 0) {
      return const SizedBox(height: 24);
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
            onPressed: () => _goToPage(_currentPage - 1),
          ),
          // Quiet, elegant brand mark
          Text(
            'AVAN',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppColors.textSecondary,
            ),
          ),
          // Step Counter (Screen 2 to 8)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              '${_currentPage + 1} / 8',
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

  // === SCREEN 01: WELCOME (Curiosity) ===
  Widget _buildScreen01Welcome() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goToPage(1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.growthAccent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                'AVAN',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 6.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Onboarding Experience & Emotional Flow',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === SCREEN 02: COMMITMENT (Agency) ===
  Widget _buildScreen02Commitment() {
    const fullText = "Step into the reality you choose";
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _completeTypewriterInstantly(fullText),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'AVAN',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  _typedText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isTypingComplete ? 1.0 : 0.0,
              child: CustomButton(
                text: 'Continue',
                onPressed: () => _goToPage(2),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === SCREEN 03: VISION (Aspiration) ===
  Widget _buildScreen03Vision() {
    const fullText =
        "Hi, welcome to Avan.\n\nThe life you dream of begins here.\n\nManifest your reality with Avan.";
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _completeTypewriterInstantly(fullText),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  _typedText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isTypingComplete ? 1.0 : 0.0,
              child: CustomButton(
                text: 'Continue',
                onPressed: () => _goToPage(3),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === SCREEN 04: TRANSFORMATION (Identity) ===
  Widget _buildScreen04Transformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Become who you want\nto be with AVAN.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          _buildTransformationBullet('Shift your mindset.'),
          const SizedBox(height: 14),
          _buildTransformationBullet('Feel more confident.'),
          const SizedBox(height: 14),
          _buildTransformationBullet('Move toward the life you want.'),
          const Spacer(),
          CustomButton(
            text: 'Continue',
            onPressed: () => _goToPage(4),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTransformationBullet(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.goldAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // === SCREEN 05: CREATOR'S JOURNEY (Trust Bridge) ===
  Widget _buildScreen05CreatorJourney() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "CREATOR'S NOTE",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.goldAccent,
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable note container
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“A few months ago, I was lost in a dilemma about where my life was going.\n\n'
                      'Then I found manifestation and spirituality, and my life took a complete turn. I began connecting the dots between the things I had once dreamed about and the way they were unfolding in my life.\n\n'
                      'I found more clarity, started achieving things I once thought were far away, built my businesses, and eventually created AVAN.\n\n'
                      'I built AVAN from that journey — so you can start believing in what’s possible for you, become the person you want to be, and create a reality that feels like your own.”',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— Alex, Founder of AVAN',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: 'Continue',
            onPressed: () => _goToPage(5),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // === SCREEN 06: CONNECTION (Conversational Handoff) ===
  Widget _buildScreen06Connection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Before we begin,\nlet’s get to know each other a little.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'I’ll ask you a few things about you — what you want, what you’re going through, and where you want to be.\n\nThe more honest you are, the more personal your journey can become.',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          CustomButton(
            text: "I'm Ready",
            onPressed: () => _goToPage(6),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // === SCREEN 07: CHOOSE YOUR STYLE (Agency & Tone) ===
  Widget _buildScreen07ChoiceStyle() {
    final styles = [
      {
        'title': 'Personal',
        'subtitle': 'Warm, gentle & introspective',
        'desc': 'A supportive, calming presence that listens and grounds you.',
        'icon': '🕊️',
      },
      {
        'title': 'Conversational',
        'subtitle': 'Direct, encouraging & actionable',
        'desc': 'Like a trusted mentor who challenges you and pushes you forward.',
        'icon': '⚡',
      },
      {
        'title': 'Formal',
        'subtitle': 'Philosophical, stoic & structured',
        'desc': 'Deep principles, mindfulness clarity, and timeless discipline.',
        'icon': '🏛️',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like\nAVAN to talk to you?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don’t have to adapt to AVAN. AVAN adapts to you.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: styles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = styles[index];
                final isSelected = _selectedStyleIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStyleIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldAccent
                            : AppColors.border,
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
                        Text(
                          item['icon']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle']!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['desc']!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? AppColors.goldAccent
                              : AppColors.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Continue',
            onPressed: () => _goToPage(7),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // === SCREEN 08: WHAT SHOULD WE FOCUS ON? (Honesty & Personalization) ===
  Widget _buildScreen08FocusHonesty() {
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
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell me what matters most to you right now (choose 1 to 3).',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldAccent
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.goldAccent.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(
                          meta.icon,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meta.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
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
                          color: isSelected
                              ? AppColors.goldAccent
                              : AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Personalize My Experience ✨',
            onPressed: _finishOnboarding,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
