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
  late Animation<double> _typeCurved;
  late AnimationController _cursorBlinkController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _initialDelayTimer;
  Timer? _lingerTimer;

  int _visibleChars = 0;
  bool _isTypingComplete = false;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();

    // Match status bar and nav bar to warm espresso brown background during splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1D1410),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 1. Typewriter Animation (140ms per letter = ~560ms total)
    _typeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );

    _typeCurved = CurvedAnimation(
      parent: _typeController,
      curve: Curves.easeInOutCubic,
    );

    _typeCurved.addListener(() {
      final chars =
          (_typeCurved.value * _brandWord.length).round().clamp(0, _brandWord.length);
      if (chars != _visibleChars) {
        setState(() {
          _visibleChars = chars;
        });
      }
    });

    _typeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTypingComplete();
      }
    });

    // 2. Cursor subtle pulse / blink
    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // 3. Fade Out Animation
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeOutCubic,
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
      _visibleChars = _brandWord.length;
    });

    // Stop cursor blinking and let the pristine word linger
    _cursorBlinkController.stop();

    _lingerTimer = Timer(const Duration(milliseconds: 450), () {
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
    setState(() {
      _visibleChars = _brandWord.length;
      _isTypingComplete = true;
    });
    _startFadeOut();
  }

  @override
  void dispose() {
    _initialDelayTimer?.cancel();
    _lingerTimer?.cancel();
    _typeController.dispose();
    _cursorBlinkController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = _brandWord.substring(0, _visibleChars);

    return Scaffold(
      backgroundColor: const Color(0xFF1D1410), // Deep espresso brown
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
                Color(0xFF2E2019), // Warm mocha coffee center
                Color(0xFF1D1410), // Deep rich espresso cocoa edges
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _fadeOutController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    visibleText,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 52,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 12.0,
                      color: const Color(0xFFFFF7ED), // Luminous serene warm ivory / cream
                      shadows: const [
                        Shadow(
                          color: Color(0x66D4A373), // Subtle warm golden halo
                          blurRadius: 18,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (!_isTypingComplete)
                    FadeTransition(
                      opacity: _cursorBlinkController,
                      child: Container(
                        width: 2.5,
                        height: 36,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A373),
                          borderRadius: BorderRadius.circular(1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80D4A373),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
