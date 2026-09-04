import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../models/user_archetype.dart';
import '../../theme/app_colors.dart';
import 'prescription_reveal_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentStepIndex = 0;
  final List<String> _steps = [
    'Synthesizing 16-Dimensional User Profile Vector...',
    'Calibrating CBT & Believability Thresholds...',
    'Mapping Primary Archetype & Sub-Level Nodes...',
    'Aligning Growth & Healing Circadian Circulators...',
    'Generating Your Personalized Affirmation Matrix...',
    'Your Space is Ready ✨',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        _timer?.cancel();
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

  @override
  void dispose() {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Archetype Icon Glow Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.goldAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      meta.icon,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Animated Circular Progress Indicator
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: (_currentStepIndex + 1) / _steps.length,
                    strokeWidth: 3.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldAccent),
                    backgroundColor: AppColors.border,
                  ),
                ),
                const SizedBox(height: 32),

                // Step Status Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _steps[_currentStepIndex],
                    key: ValueKey<int>(_currentStepIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tailoring affirmations for ${meta.title}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
