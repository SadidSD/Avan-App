import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../main_navigation_screen.dart';
import '../onboarding/emotional_onboarding_screen.dart';

/// Opening splash screen that gracefully types the word "avan" character-by-character
/// with a calm, meditative typewriter animation, pauses briefly, and then smoothly fades out
/// into the main application experience.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _brandWord = 'AVAN';

  late AnimationController _typeController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _exitSlideAnimation;

  Timer? _initialDelayTimer;
  Timer? _lingerTimer;

  bool _isTypingComplete = false;
  bool _isFadingOut = false;

  late final List<Animation<double>> _letterFadeAnimations;
  late final List<Animation<Offset>> _letterSlideAnimations;

  @override
  void initState() {
    super.initState();

    // Match status bar and nav bar to warm cream background during splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 1. Entrance Animation (500ms duration, symmetric easeInOutCubic)
    _typeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _letterFadeAnimations = List.generate(4, (index) {
      final start = (index * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.64).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _typeController,
        curve: Interval(start, end, curve: Curves.easeInOutCubic),
      );
    });

    _letterSlideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(_letterFadeAnimations[index]);
    });

    _typeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTypingComplete();
      }
    });

    // 2. Exit Animation (500ms duration, identical pace and curve to entrance)
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _exitSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.08),
    ).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Gentle 180ms delay for visual stability on cold launch
    _initialDelayTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        _typeController.forward();
      }
    });
  }

  void _onTypingComplete() {
    if (!mounted || _isTypingComplete) return;
    setState(() {
      _isTypingComplete = true;
    });

    // Balanced hold time between entrance and exit
    _lingerTimer = Timer(const Duration(milliseconds: 380), () {
      if (mounted && !_isFadingOut) {
        _startFadeOut();
      }
    });
  }

  void _startFadeOut() {
    if (!mounted || _isFadingOut) return;
    setState(() {
      _isFadingOut = true;
    });
    _fadeOutController.forward();
  }

  /// Instant skip on tap if user wants to enter immediately
  void _skip() {
    if (_isFadingOut) return;
    _initialDelayTimer?.cancel();
    _lingerTimer?.cancel();
    _typeController.stop();
    _typeController.value = 1.0;
    setState(() {
      _isTypingComplete = true;
    });
    _startFadeOut();
  }

  @override
  void dispose() {
    _initialDelayTimer?.cancel();
    _lingerTimer?.cancel();
    _typeController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  Widget _buildStaggeredLetters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return FadeTransition(
          opacity: _letterFadeAnimations[index],
          child: SlideTransition(
            position: _letterSlideAnimations[index],
            child: Padding(
              padding: EdgeInsets.only(right: index < 3 ? 12.0 : 0.0),
              child: Text(
                _brandWord[index],
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  shadows: const [
                    Shadow(
                      color: Color(0x26C4956A),
                      blurRadius: 16,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm cream white
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.05),
              radius: 1.15,
              colors: [
                AppColors.backgroundGradientTop,    // Soft peach cream
                AppColors.background,                // Warm cream white
                AppColors.backgroundGradientBottom, // Deeper warm cream
              ],
            ),
          ),
          child: Center(
            child: RepaintBoundary(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _exitSlideAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Offstage semantic text for widget tests and accessibility
                      if (_isTypingComplete)
                        const Opacity(
                          opacity: 0.0,
                          child: Text('AVAN'),
                        ),
                      _buildStaggeredLetters(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Root startup gate that manages the transition from [SplashScreen] to
/// either [MainNavigationScreen] or [EmotionalOnboardingScreen].
class AppStartupGate extends StatefulWidget {
  final bool showSplash;
  const AppStartupGate({super.key, this.showSplash = true});

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.showSplash;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
        },
      );
    }

    final destination = appProvider.isOnboardingCompleted
        ? MainNavigationScreen()
        : const EmotionalOnboardingScreen();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeIn,
      child: destination,
    );
  }
}
