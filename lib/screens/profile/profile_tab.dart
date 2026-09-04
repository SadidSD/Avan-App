import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_archetype.dart';
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_card.dart';
import '../my_voice/my_voice_tab.dart';
import '../onboarding/survey_screen.dart';
import '../widgets_preview/widgets_tab.dart';
import '../affirmations/affirmations_tab.dart';
import '../../widgets/paywall_modal.dart';

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
                child: Center(
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
                            onTap: () => PaywallModal.show(context),
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
                      appProvider.userEmail,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
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
                      MaterialPageRoute(builder: (_) => const SurveyScreen()),
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
  // 2. CONSISTENCY & ANALYTICS CARD
  // ===========================================================================
  Widget _buildConsistencyCard(BuildContext context, AppProvider appProvider, Color accent) {
    final streak = appProvider.streakData;
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final currentDayIndex = (DateTime.now().weekday - 1) % 7;

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
                  color: AppColors.goldAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
                ),
                child: Text(
                  'Consistency High',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Consistency Dots Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == currentDayIndex;
              final isDone = index <= currentDayIndex;

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

          // Milestone Achievement Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMilestoneBadge(Icons.spa_rounded, AppColors.growthAccent, 'Mindful Pioneer'),
              _buildMilestoneBadge(Icons.local_fire_department_rounded, AppColors.goldAccent, '7-Day Spark'),
              _buildMilestoneBadge(Icons.mic_rounded, AppColors.healingAccent, 'Voice Master'),
              _buildMilestoneBadge(Icons.dashboard_rounded, Colors.purpleAccent, 'Visionary'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadge(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
          icon: Icons.cloud_done_outlined,
          title: 'Cloud Sync & Multi-Device Backup ☁️',
          onTap: () => _showCloudSyncDialog(context, appProvider),
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
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isDestructive ? Colors.redAccent : AppColors.textPrimary,
                ),
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

  void _showCloudSyncDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.shield_rounded, color: AppColors.goldAccent),
            SizedBox(width: 8),
            Text('Data Vault & Auto-Backup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appProvider.isCloudSyncEnabled
                  ? 'Your journal entries, streak progress, and vision boards are safely preserved in your encrypted on-device data vault.'
                  : 'Enable automated local backups to ensure your progress, journals, and vision boards are safely preserved on this device. (Multi-device cloud sync coming in v2).',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              appProvider.setCloudSync(!appProvider.isCloudSyncEnabled);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appProvider.isCloudSyncEnabled ? 'Auto-Backup Paused' : 'Local Vault Backup Active! 💾✨'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              appProvider.isCloudSyncEnabled ? 'Pause Backup' : 'Enable Backup',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
