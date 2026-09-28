import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_archetype.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_card.dart';
import '../my_voice/my_voice_tab.dart';
import '../onboarding/emotional_onboarding_screen.dart';
import '../widgets_preview/widgets_tab.dart';
import '../affirmations/affirmations_tab.dart';
import '../paywall/paywall_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);

    // Determine Archetype Display Label
    String archetypeLabel = 'Mindset Explorer';
    String archetypeSubLabel = 'Daily Neuroplastic Growth';
    if (appProvider.userProfileVector.primaryArchetypes.isNotEmpty) {
      final meta = ArchetypeRegistry.getMetadata(appProvider.userProfileVector.primaryArchetypes.first);
      archetypeLabel = meta.title;
      if (appProvider.userProfileVector.selectedSubLevels.isNotEmpty) {
        archetypeSubLabel = appProvider.userProfileVector.selectedSubLevels.first;
      } else {
        archetypeSubLabel = meta.shortDescription;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile & Growth Hub',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 22),
                    tooltip: 'Help & FAQ',
                    onPressed: () => _showHelpSupportModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Identity & Mindset Archetype Card
              _buildIdentityCard(context, appProvider, accent, archetypeLabel, archetypeSubLabel),
              if (!appProvider.isSignedIn) ...[
                const SizedBox(height: 14),
                _buildGoogleSignInCard(context, appProvider, accent),
              ],
              const SizedBox(height: 20),

              // 3. Neuroplastic Consistency & Analytics Card
              _buildConsistencyCard(context, appProvider, accent),
              const SizedBox(height: 20),

              // 4. Manifestation Vault (2x2 Quick-Access Grid)
              Text(
                'MANIFESTATION VAULT',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              _buildManifestationVault(context, appProvider, accent),
              const SizedBox(height: 24),

              // 5. Atmosphere & Theme Mode
              Text(
                'THEME & ATMOSPHERE',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              _buildThemeCard(context, appProvider, accent),
              const SizedBox(height: 24),

              // 6. Preferences & Settings List
              Text(
                'PREFERENCES & SYSTEM',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              _buildSettingsList(context, appProvider, accent),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. IDENTITY & ARCHETYPE CARD
  // ===========================================================================
  Widget _buildIdentityCard(
    BuildContext context,
    AppProvider appProvider,
    Color accent,
    String archetypeLabel,
    String archetypeSubLabel,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (appProvider.userPhotoUrl != null && appProvider.userPhotoUrl!.isNotEmpty)
                      ? Image.network(
                          appProvider.userPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              appProvider.userName.isNotEmpty ? appProvider.userName[0].toUpperCase() : 'A',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            appProvider.userName.isNotEmpty ? appProvider.userName[0].toUpperCase() : 'A',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appProvider.userName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (appProvider.isSignedIn) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF4285F4)),
                        ],
                        const SizedBox(width: 6),
                        if (appProvider.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.goldAccent.withOpacity(0.35)),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => PaywallScreen.open(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: accent.withOpacity(0.3)),
                              ),
                              child: Text(
                                'UPGRADE',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appProvider.userEmail.isNotEmpty
                          ? appProvider.userEmail
                          : 'Tap to add email address',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: appProvider.userEmail.isNotEmpty
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Edit Profile Button
                    InkWell(
                      onTap: () => _showEditProfileDialog(context, appProvider),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 12, color: accent),
                          const SizedBox(width: 4),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Active Archetype & Recalibrate Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology_rounded, size: 24, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        archetypeLabel,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        archetypeSubLabel,
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmotionalOnboardingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Recalibrate ✨', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GOOGLE SIGN-IN & CLOUD BACKUP CARD
  // ===========================================================================
  Widget _buildGoogleSignInCard(BuildContext context, AppProvider appProvider, Color accent) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4285F4).withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: Color(0xFF4285F4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account & Cloud Backup',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Protect your streaks, journals & sync across devices',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: appProvider.isSyncing
                      ? null
                      : () => _handleGoogleSignIn(context, appProvider),
                  icon: appProvider.isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.login_rounded, size: 16),
                  label: Text(
                    appProvider.isSyncing ? 'Signing In...' : 'Sign in with Google',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _showCloudVaultModal(context, appProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                child: Text(
                  'Details',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, AppProvider appProvider) async {
    final result = await appProvider.signInWithGoogle();
    if (!context.mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected with Google! Cloud Vault is active ☁️✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In cancelled.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _showAuthDiagnosticsDialog(context, result);
    }
  }

  void _showAuthDiagnosticsDialog(BuildContext context, AuthSignInResult result) {
    showDialog(
      context: context,
      builder: (diagCtx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: Colors.amberAccent, size: 22),
            SizedBox(width: 8),
            Text('Sign-In Diagnostics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.errorMessage ?? 'Google Sign-In was unable to complete.',
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase Project SHA-1 Fingerprints:',
                style: TextStyle(color: AppColors.goldAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildShaCopyRow(diagCtx, 'Release SHA-1', AuthService.releaseSha1),
              const SizedBox(height: 6),
              _buildShaCopyRow(diagCtx, 'Debug SHA-1', AuthService.debugSha1),
              if (result.rawError != null) ...[
                const SizedBox(height: 14),
                const Text('Raw Exception Details:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    result.rawError!,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'AVAN Auth Diagnostics:\nError: ${result.errorMessage}\nRaw: ${result.rawError}\nRelease SHA-1: ${AuthService.releaseSha1}\nDebug SHA-1: ${AuthService.debugSha1}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnostics copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Copy Info', style: TextStyle(color: AppColors.goldAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(diagCtx),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShaCopyRow(BuildContext context, String label, String sha1) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(sha1, style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace')),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.goldAccent),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: sha1));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. CONSISTENCY & ANALYTICS CARD
  // ===========================================================================
  Widget _buildConsistencyCard(BuildContext context, AppProvider appProvider, Color accent) {
    final streak = appProvider.streakData;
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final currentDayIndex = (now.weekday - 1) % 7;

    final isTodayActive = streak.lastActiveDate != null &&
        streak.lastActiveDate!.year == now.year &&
        streak.lastActiveDate!.month == now.month &&
        streak.lastActiveDate!.day == now.day;

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streak.currentStreak} Day Streak',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Best Record: ${streak.longestStreak} days 🏆',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (streak.currentStreak > 0 ? AppColors.goldAccent : AppColors.textMuted).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (streak.currentStreak > 0 ? AppColors.goldAccent : AppColors.textMuted).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  streak.currentStreak >= 7
                      ? 'Streak Unstoppable 🔥'
                      : (streak.currentStreak > 0 ? 'Consistency Active ✨' : 'Start Today 🌱'),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: streak.currentStreak > 0 ? AppColors.goldAccent : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Consistency Dots Row (Real Activity Tracking)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == currentDayIndex;
              final bool isDone;
              if (index > currentDayIndex) {
                isDone = false; // Future days in current week cannot be completed yet
              } else if (isToday) {
                isDone = isTodayActive;
              } else {
                final daysAgo = currentDayIndex - index;
                final requiredStreak = isTodayActive ? (daysAgo + 1) : daysAgo;
                isDone = streak.currentStreak >= requiredStreak && streak.currentStreak > 0;
              }

              return Column(
                children: [
                  Text(
                    weekdays[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? accent : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? accent.withOpacity(0.2) : AppColors.surfaceElevated,
                      border: Border.all(
                        color: isToday ? accent : (isDone ? accent.withOpacity(0.5) : AppColors.border),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isDone ? Icons.check_rounded : Icons.circle,
                        size: isDone ? 16 : 6,
                        color: isDone ? accent : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Milestone Achievement Badges (Real Unlocked Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMilestoneBadge(
                icon: Icons.spa_rounded,
                color: AppColors.growthAccent,
                label: 'Pioneer',
                isUnlocked: streak.totalListeningDays >= 1,
              ),
              _buildMilestoneBadge(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.goldAccent,
                label: '7-Day Spark',
                isUnlocked: streak.longestStreak >= 7,
              ),
              _buildMilestoneBadge(
                icon: Icons.mic_rounded,
                color: AppColors.healingAccent,
                label: 'Voice Master',
                isUnlocked: appProvider.userRecordings.isNotEmpty,
              ),
              _buildMilestoneBadge(
                icon: Icons.dashboard_rounded,
                color: Colors.purpleAccent,
                label: 'Visionary',
                isUnlocked: appProvider.activeVisionBoard.blocks.isNotEmpty,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadge({
    required IconData icon,
    required Color color,
    required String label,
    required bool isUnlocked,
  }) {
    final effectiveColor = isUnlocked ? color : AppColors.textMuted;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked ? color.withOpacity(0.14) : AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? color.withOpacity(0.5) : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: effectiveColor, size: 20),
              if (!isUnlocked)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, size: 8, color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isUnlocked ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. MANIFESTATION VAULT (2X2 GRID)
  // ===========================================================================
  Widget _buildManifestationVault(BuildContext context, AppProvider appProvider, Color accent) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVaultCard(
                icon: Icons.favorite_rounded,
                iconColor: Colors.pinkAccent,
                title: 'Favorites',
                subtitle: '${appProvider.favoriteAffirmations.length} Saved Quotes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AffirmationsTab(initialTab: 'Favorites'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVaultCard(
                icon: Icons.mic_rounded,
                iconColor: accent,
                title: 'My Voice',
                subtitle: '${appProvider.userRecordings.length} Studio Tracks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyVoiceTab()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildVaultCard(
                icon: Icons.dashboard_customize_rounded,
                iconColor: AppColors.goldAccent,
                title: 'Vision Boards',
                subtitle: '${appProvider.savedVisionBoards.length + 1} Board Designs',
                onTap: () => appProvider.setNavIndex(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVaultCard(
                icon: Icons.menu_book_rounded,
                iconColor: Colors.tealAccent,
                title: 'Reflections',
                subtitle: '${appProvider.journalEntries.length} Journal Entries',
                onTap: () => appProvider.setNavIndex(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVaultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. THEME & ATMOSPHERE CARD
  // ===========================================================================
  Widget _buildThemeCard(BuildContext context, AppProvider appProvider, Color accent) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atmospheric Mode',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Growth (Earthy Forest Green) for energizing action, or Healing (Blue-Green Teal) for calming somatic recovery.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildModeOption(
                label: '⚡ Growth',
                isSelected: appProvider.appModeSetting == AppMode.growth,
                color: AppColors.growthAccent,
                onTap: () => appProvider.setAppMode(AppMode.growth),
              ),
              const SizedBox(width: 8),
              _buildModeOption(
                label: '🌸 Healing',
                isSelected: appProvider.appModeSetting == AppMode.healing,
                color: AppColors.healingAccent,
                onTap: () => appProvider.setAppMode(AppMode.healing),
              ),
              const SizedBox(width: 8),
              _buildModeOption(
                label: '🔄 Auto',
                isSelected: appProvider.appModeSetting == AppMode.auto,
                color: accent,
                onTap: () => appProvider.setAppMode(AppMode.auto),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.transparent,
          side: BorderSide(color: isSelected ? color : AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. SETTINGS LIST
  // ===========================================================================
  Widget _buildSettingsList(BuildContext context, AppProvider appProvider, Color accent) {
    return Column(
      children: [
        _buildSettingTile(
          icon: Icons.psychology_rounded,
          title: 'Recalibrate Personalization Engine 🌌',
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                title: Text(
                  'Recalibrate Mindset Engine',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  'This will guide you through the personalization journey to update your emotional baseline, archetype vectors, and custom tone. Would you like to proceed?',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmotionalOnboardingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Recalibrate', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
        _buildSettingTile(
          icon: Icons.workspace_premium_rounded,
          title: appProvider.isPremium
              ? 'AVAN Unlimited Status: Active ✨'
              : 'Unlock AVAN Unlimited (7-Day Trial) 💎',
          onTap: () => PaywallScreen.open(context),
        ),
        _buildSettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Daily Reminders & Notifications ⏰',
          onTap: () => _showRemindersModal(context),
        ),
        _buildSettingTile(
          icon: Icons.graphic_eq_rounded,
          title: 'Audio Engine & Pacing Preferences 🎵',
          onTap: () => _showAudioSettingsModal(context),
        ),
        _buildSettingTile(
          icon: appProvider.isSignedIn ? Icons.cloud_done_rounded : Icons.cloud_outlined,
          title: appProvider.isSignedIn
              ? 'Cloud Vault & Sync Active ☁️'
              : 'Sign in with Google / Cloud Sync ☁️',
          subtitle: appProvider.isSignedIn
              ? (appProvider.lastSyncTime != null
                  ? 'Last backup saved • Tap to manage'
                  : 'Secured with ${appProvider.userEmail.isNotEmpty ? appProvider.userEmail : "Google"}')
              : 'Tap to connect Google & secure streak',
          onTap: () => _showCloudVaultModal(context, appProvider),
        ),
        _buildSettingTile(
          icon: Icons.widgets_outlined,
          title: 'Lock Screen & Home Widgets 🎨',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WidgetsTab()),
            );
          },
        ),
        _buildSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy 🛡️',
          onTap: () => _showPrivacyPolicyModal(context),
        ),
        _buildSettingTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service 📜',
          onTap: () => _showTermsOfServiceModal(context),
        ),
        if (appProvider.isSignedIn)
          _buildSettingTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account & Wipe Cloud Vault ⚠️',
            subtitle: 'Permanently remove cloud vault and linked Google account',
            isDestructive: true,
            onTap: () => _showDeleteAccountDialog(context, appProvider),
          ),
        _buildSettingTile(
          icon: Icons.restart_alt_rounded,
          title: 'Reset App & Clear All Memory 🔄',
          isDestructive: true,
          onTap: () => _showResetDataDialog(context, appProvider),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? Colors.redAccent : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isDestructive ? Colors.redAccent : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDestructive ? Colors.redAccent.withOpacity(0.8) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MODALS & DIALOGS
  // ===========================================================================
  void _showEditProfileDialog(BuildContext context, AppProvider appProvider) {
    final nameCtrl = TextEditingController(text: appProvider.userName);
    final emailCtrl = TextEditingController(text: appProvider.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Profile 👤', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Your Name',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appProvider.updateProfile(name: nameCtrl.text, email: emailCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully! ✨'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCloudVaultModal(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isSyncing = appProvider.isSyncing;
          final isSignedIn = appProvider.isSignedIn;
          final lastSync = appProvider.lastSyncTime;
          final accent = AppColors.accentForMode(appProvider.isGrowthMode);

          String lastSyncStr = 'Not synced yet';
          if (lastSync != null) {
            final now = DateTime.now();
            final diff = now.difference(lastSync);
            if (diff.inMinutes < 1) {
              lastSyncStr = 'Just now';
            } else if (diff.inHours < 1) {
              lastSyncStr = '${diff.inMinutes}m ago';
            } else if (diff.inDays < 1) {
              lastSyncStr = '${diff.inHours}h ago';
            } else {
              lastSyncStr = '${lastSync.month}/${lastSync.day} at ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}';
            }
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppColors.goldAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cloud Vault & Sync',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isSignedIn ? 'Linked & Protected ☁️' : 'Optional Multi-Device Backup',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Privacy Assurance Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2429),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Zero Voice-Leak Guarantee: Your audio recordings from "Say After Me" remain 100% on this device. We only secure your streak count, journals, vision boards, and favorites.',
                            style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!isSignedIn) ...[
                    // Benefits list
                    _buildSyncBenefitRow(
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orangeAccent,
                      title: 'Protect Your Streak & Badges',
                      desc: 'Switch phones or reinstall without resetting your consistency.',
                    ),
                    const SizedBox(height: 12),
                    _buildSyncBenefitRow(
                      icon: Icons.menu_book_rounded,
                      color: Colors.cyanAccent,
                      title: 'Private Journal Backup',
                      desc: 'Save your daily mindful reflections and emotional insights.',
                    ),
                    const SizedBox(height: 12),
                    _buildSyncBenefitRow(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.goldAccent,
                      title: 'Vision Boards & Intentions',
                      desc: 'Preserve your dream boards, goals, and personalized vectors.',
                    ),
                    const SizedBox(height: 24),

                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSyncing
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                await _handleGoogleSignIn(context, appProvider);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_circle_rounded, color: Color(0xFF4285F4), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'No password needed. AVAN will never post or share your data.',
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ),
                  ] else ...[
                    // Signed In Account Details
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: accent.withOpacity(0.2),
                                backgroundImage: (appProvider.userPhotoUrl != null && appProvider.userPhotoUrl!.isNotEmpty)
                                    ? NetworkImage(appProvider.userPhotoUrl!)
                                    : null,
                                child: (appProvider.userPhotoUrl == null || appProvider.userPhotoUrl!.isEmpty)
                                    ? Text(
                                        appProvider.userName.isNotEmpty ? appProvider.userName[0].toUpperCase() : 'G',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: accent),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appProvider.userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      appProvider.userEmail,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Last Synced', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(lastSyncStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sync & Restore Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    final ok = await appProvider.syncToCloud();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok ? 'Cloud Vault updated successfully! ☁️✨' : 'Sync failed. Please check connection.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                            icon: isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (alertCtx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text('Restore from Cloud?'),
                                        content: const Text(
                                          'This will replace your current on-device streak, journals, and vision boards with the version saved in your Cloud Vault.',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(alertCtx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.buttonDark,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            onPressed: () => Navigator.pop(alertCtx, true),
                                            child: const Text('Restore Now', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      final ok = await appProvider.restoreFromCloud();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              ok ? 'Data restored from Cloud Vault! 🚀' : 'Restore failed.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.cloud_download_outlined, size: 18),
                            label: const Text('Restore'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sign Out Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          await appProvider.signOut();
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signed out of Google. Switched back to guest mode.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.textSecondary),
                        label: const Text('Sign Out & Return to Guest Mode', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSyncBenefitRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('Delete Account Forever?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'This will permanently delete your AVAN account and wipe all cloud-saved records (streaks, journals, vision boards) from Firestore.\n\nThis action is irreversible and compliant with Google Play data safety regulations.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await appProvider.deleteAccount();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Account and Cloud Vault permanently deleted.'
                          : 'Failed to delete account. Please try again or re-login.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete Everything', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemindersModal(BuildContext context) {
    var settings = _notificationService.settings;
    bool morningEnabled = settings.isMorningEnabled;
    bool eveningEnabled = settings.isEveningEnabled;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: AppColors.goldAccent),
                    SizedBox(width: 8),
                    Text('Daily Mindset Reminders ⏰', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Configure gentle reminder notifications to build consistent daily neural rewiring habits.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(Icons.wb_sunny_rounded, color: AppColors.goldAccent),
                  title: Text('Morning Affirmation (${settings.morningTime.formatTimeOfDay()})', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  trailing: Switch(
                    value: morningEnabled,
                    activeColor: AppColors.goldAccent,
                    onChanged: (val) {
                      setModalState(() {
                        morningEnabled = val;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight_round, color: Colors.purpleAccent),
                  title: Text('Evening Reflection (${settings.eveningTime.formatTimeOfDay()})', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  trailing: Switch(
                    value: eveningEnabled,
                    activeColor: AppColors.goldAccent,
                    onChanged: (val) {
                      setModalState(() {
                        eveningEnabled = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final updated = ReminderSettings(
                      isMorningEnabled: morningEnabled,
                      isEveningEnabled: eveningEnabled,
                      morningTime: settings.morningTime,
                      eveningTime: settings.eveningTime,
                      frequency: settings.frequency,
                    );
                    await _notificationService.updateSettings(updated);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder schedule saved successfully! ⏰✨'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonDark,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Reminder Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAudioSettingsModal(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.graphic_eq_rounded, color: AppColors.goldAccent),
                SizedBox(width: 8),
                Text('Audio Engine & Pacing 🎵', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Customize default voice speed and reflection silence between affirmations.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text('Reflection Pause Duration: ${audioProvider.gapBetweenAffirmations}s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Slider(
              value: audioProvider.gapBetweenAffirmations.toDouble(),
              min: 1.0,
              max: 6.0,
              divisions: 5,
              activeColor: AppColors.goldAccent,
              onChanged: (val) {
                audioProvider.setGapBetweenAffirmations(val.round());
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(22),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                children: const [
                  Icon(Icons.help_center_rounded, color: AppColors.goldAccent),
                  SizedBox(width: 8),
                  Text('Help & Support 💡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildFaqItem('How does the personalization algorithm work?', 'AVAN uses a 16-dimensional neuroplastic vector matching your survey identity (Career, Anxiety, Heartbreak, Grief, etc.) with science-backed affirmations and frequencies.'),
              _buildFaqItem('What is the difference between Growth and Healing modes?', 'Growth mode uses Earthy Forest Green with action-oriented neuroplastic affirmations and cognitive momentum. Healing mode uses Blue-Green Teal with somatic grounding and nervous system regulation.'),
              _buildFaqItem('How do I upload photos to my Vision Board?', 'Tap any goal card in the Vision Board tab, then tap the photo icon or "+ Upload" card to pick pictures directly from your camera roll.'),
              const SizedBox(height: 14),
              const Text('Need additional assistance? Contact support at support@avanapp.com', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13131D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Icon(Icons.privacy_tip_rounded, color: AppColors.goldAccent, size: 24),
                  SizedBox(width: 10),
                  Text('Privacy Policy 🛡️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 14),
              _buildPolicySection(
                title: '1. On-Device Voice & Audio Privacy',
                content: 'All personal voice recordings created in My Voice Studio and microphone data used during Say After Me speech practice remain 100% on your local device. AVAN does not upload, stream, analyze on remote servers, or sell your audio recordings or biometric voiceprints to any third parties.',
              ),
              _buildPolicySection(
                title: '2. Personalization & Vector Storage',
                content: 'Your archetype preferences, emotional baseline inputs, custom vision boards, reflections, and streak statistics are stored securely in local app sandbox storage. If you enable Cloud Sync, data is encrypted in transit and at rest.',
              ),
              _buildPolicySection(
                title: '3. In-App Purchases & Subscriptions',
                content: 'All financial transactions and subscription lifecycles are processed directly by Google Play Store (Google Play Billing) or Apple App Store (StoreKit). AVAN never sees, processes, or stores your credit card or banking details. Subscriptions can be managed or canceled anytime in your device store settings.',
              ),
              _buildPolicySection(
                title: '4. Permissions Explained',
                content: '• Microphone (RECORD_AUDIO): Requested only when you intentionally record affirmations or practice speech pronunciation.\n• Audio Settings (MODIFY_AUDIO_SETTINGS): Used to optimize background ambient Solfeggio soundscape mixing during playback.',
              ),
              _buildPolicySection(
                title: '5. Contact & Data Rights',
                content: 'You can erase all stored data anytime using the "Reset App & Clear All Memory" button in Settings. For privacy inquiries or data requests, contact privacy@avanapp.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsOfServiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13131D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Icon(Icons.description_rounded, color: AppColors.goldAccent, size: 24),
                  SizedBox(width: 10),
                  Text('Terms of Service 📜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 14),
              _buildPolicySection(
                title: '1. Mindset & Wellness Sanctuary',
                content: 'AVAN is an affirmation, mindfulness, and neuroplastic mindset tool designed for personal wellness and habit formation. It does not provide medical diagnosis, clinical psychiatric care, or psychotherapy.',
              ),
              _buildPolicySection(
                title: '2. Subscriptions & 7-Day Free Trial',
                content: 'The AVAN Annual Membership includes a 7-day free trial. If not canceled at least 24 hours before the trial ends, your Google Play / Apple ID account will be billed for the annual subscription. Monthly subscriptions renew automatically each month until canceled.',
              ),
              _buildPolicySection(
                title: '3. Intellectual Property',
                content: 'Curated playlists, Solfeggio soundscape synthesis algorithms, and visual designs are the proprietary assets of AVAN. You retain full ownership of any original personal affirmations, vision board images, and voice recordings you create.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.goldAccent)),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45)),
          ],
        ),
      ),
    );
  }

  void _showResetDataDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset App & Clear Memory?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will wipe all saved journal entries, user recordings, survey choices, and streak data, restarting AVAN back to onboarding.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              appProvider.resetAppData();
            },
            child: const Text('Reset Everything', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
