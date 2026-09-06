import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../models/user_archetype.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_cosmic_background.dart';
import 'prescription_reveal_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStepIndex = 0;
  List<String> _steps = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSynthesisSteps();
    });
  }

  void _initSynthesisSteps() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final name = appProvider.userName.isNotEmpty ? appProvider.userName : 'Alex';
    final primaryType = appProvider.userProfileVector.primaryArchetypes.isNotEmpty
        ? appProvider.userProfileVector.primaryArchetypes.first
        : UserArchetype.careerProfessional;
    final meta = ArchetypeRegistry.getMetadata(primaryType);

    final challenge = appProvider.userTypedChallenge;
    final aspiration = appProvider.userTypedAspiration;
    final believabilityScore =
        (appProvider.userProfileVector.believabilityPreference * 100).toInt();

    final List<String> computedSteps = [
      'Connecting to $name\'s cognitive baseline...',
    ];

    if (challenge.isNotEmpty) {
      final shortChallenge = challenge.length > 34
          ? '${challenge.substring(0, 34)}...'
          : challenge;
      computedSteps.add('Extracting emotional friction: "$shortChallenge"...');
    } else {
      computedSteps.add('Scanning 16D psychological landscape...');
    }

    computedSteps.add('Calibrating CBT Believability threshold to $believabilityScore%...');

    if (aspiration.isNotEmpty) {
      final shortAspiration = aspiration.length > 34
          ? '${aspiration.substring(0, 34)}...'
          : aspiration;
      computedSteps.add('Encoding target emotional shift: "$shortAspiration"...');
    } else {
      computedSteps.add('Synthesizing resonance vectors for ${meta.title}...');
    }

    computedSteps.add('Assembling $name\'s personalized audio prescription...');
    computedSteps.add('Your Space is Calibrated ✨');

    setState(() {
      _steps = computedSteps;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 520), (timer) {
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const PrescriptionRevealScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final primaryType = appProvider.userProfileVector.primaryArchetypes.isNotEmpty
        ? appProvider.userProfileVector.primaryArchetypes.first
        : UserArchetype.careerProfessional;
    final meta = ArchetypeRegistry.getMetadata(primaryType);

    final progressRatio = _steps.isEmpty
        ? 0.1
        : ((_currentStepIndex + 1) / _steps.length).clamp(0.0, 1.0);
    final percentNumber = (progressRatio * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedCosmicBackground(
        isGrowth: true,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glowing Center Orb with Pulse
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceElevated,
                        border: Border.all(
                          color: AppColors.growthAccent.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.growthAccent.withOpacity(0.30),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          meta.icon,
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Circular Progress & Percentage
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progressRatio,
                          strokeWidth: 3.5,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.growthAccent),
                          backgroundColor: const Color(0x14FFFFFF),
                        ),
                      ),
                      Text(
                        '$percentNumber%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Dynamic Step Text Readout
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _steps.isNotEmpty
                          ? _steps[_currentStepIndex]
                          : 'Synthesizing 16-Dimensional User Profile Vector...',
                      key: ValueKey<int>(_currentStepIndex),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NEURAL FREQUENCY CALIBRATION',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.growthAccent.withOpacity(0.85),
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
