import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../models/user_archetype.dart';
import '../../models/affirmation.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_cosmic_background.dart';
import '../../widgets/custom_button.dart';
import '../main_navigation_screen.dart';

class PrescriptionRevealScreen extends StatefulWidget {
  const PrescriptionRevealScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionRevealScreen> createState() =>
      _PrescriptionRevealScreenState();
}

class _PrescriptionRevealScreenState extends State<PrescriptionRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getBelievabilityLabel(double b) {
    if (b <= 0.60) {
      return '🚀 High-Agency Aspiration (Dynamic Stretch)';
    } else if (b <= 0.80) {
      return '⚖️ Balanced CBT Cognitive Reframe';
    } else {
      return '🛡️ Gentle Grounding (Anti-Toxic Positivity)';
    }
  }

  void _playFirstAffirmation(BuildContext context, Affirmation heroAffirmation) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final situationalPlaylist = appProvider.getSituationalPlaylist();

    setState(() {
      _isPlayingPreview = true;
    });

    audioProvider.openPlaylist(situationalPlaylist, context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Playing your calibrated session ✨',
          style: GoogleFonts.inter(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _enterSanctuary(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.completeOnboarding();

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainNavigationScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isGrowth = appProvider.isGrowthMode;
    final accent = isGrowth ? AppColors.growthAccent : AppColors.healingAccent;

    final primaryType = appProvider.userProfileVector.primaryArchetypes.isNotEmpty
        ? appProvider.userProfileVector.primaryArchetypes.first
        : UserArchetype.careerProfessional;
    final primaryMeta = ArchetypeRegistry.getMetadata(primaryType);

    final heroAffirmation = appProvider.getHeroAffirmation();
    final subLevelText = appProvider.userProfileVector.selectedSubLevels.isNotEmpty
        ? appProvider.userProfileVector.selectedSubLevels.first
        : primaryMeta.shortDescription;

    final believabilityScore = appProvider.userProfileVector.believabilityPreference;
    final believabilityLabel = _getBelievabilityLabel(believabilityScore);

    return AnimatedCosmicBackground(
      mode: appProvider.appModeSetting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Climax Header Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldAccent.withOpacity(0.35),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            'NEURAL SANCTUARY CALIBRATED',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.goldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Your First Affirmation',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Synthesized specifically for your mind and current chapter',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Archetype Resonance & Believability Pill Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(primaryMeta.icon, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${primaryMeta.title} · 98% Match',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subLevelText,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  believabilityLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hero Affirmation Glass Card
                    Expanded(
                      child: GlassCard(
                        accentColor: AppColors.goldAccent,
                        glowIntensity: 0.5,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '“',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 48,
                                height: 0.8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldAccent.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              heroAffirmation.quote,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                height: 1.45,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              heroAffirmation.displayTitle.isNotEmpty
                                  ? heroAffirmation.displayTitle
                                  : heroAffirmation.category,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppColors.goldAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Audio Listen Action
                    GestureDetector(
                      onTap: () => _playFirstAffirmation(context, heroAffirmation),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPlayingPreview ? accent : AppColors.border,
                          ),
                          boxShadow: _isPlayingPreview
                              ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 10)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPlayingPreview
                                  ? Icons.volume_up_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: accent,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isPlayingPreview
                                  ? 'Audio Playing · Calibrated Session'
                                  : 'Listen to Your First Affirmation',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enter Sanctuary Primary CTA
                    CustomButton(
                      text: 'Enter My Sanctuary ✨',
                      backgroundColor: AppColors.buttonDark,
                      textColor: Colors.white,
                      onPressed: () => _enterSanctuary(context),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
