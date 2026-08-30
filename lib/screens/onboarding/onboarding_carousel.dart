import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'survey_screen.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({Key? key}) : super(key: key);

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/onboarding_girl_profile.jpg',
      'icon': '✨',
      'title': 'Your space to\nbecome your best self',
      'subtitle': 'Daily personalized affirmations, voice repetition, and vision boards to elevate your subconscious mind.',
    },
    {
      'image': 'assets/images/onboarding_archway_sun.jpg',
      'icon': '🌿',
      'title': 'Affirm your mind',
      'subtitle': 'Positive words shape your neural pathways. Start each day with high-resonance mindset playlists.',
    },
    {
      'image': 'assets/images/onboarding_moon_clouds.jpg',
      'icon': '🎙️',
      'title': 'Say After Me & Voice Studio',
      'subtitle': 'Practice interactive voice repetition, record affirmations in your own voice, and manifest your vision.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SurveyScreen()),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tanAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Artwork Container
                            Container(
                              height: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A5A4B44),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32.0),
                            child: Image.asset(
                              slide['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.softBeige,
                                  child: Center(
                                    child: Text(
                                      slide['icon']!,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Logo / Icon
                        if (index == 0) ...[
                          const Text(
                            'AVAN',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.softBeige,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              slide['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Title
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          slide['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
                },
              ),
            ),
            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.textPrimary : AppColors.nudeAccent,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  CustomButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SurveyScreen()),
                        );
                      }
                    },
                  ),
                  if (_currentPage == _slides.length - 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SurveyScreen()),
                            );
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
