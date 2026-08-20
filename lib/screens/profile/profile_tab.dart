import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/notification_service.dart';

import '../../widgets/custom_card.dart';
import '../../widgets/paywall_modal.dart';
import '../widgets_preview/widgets_tab.dart';
import '../my_voice/my_voice_tab.dart';

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
    final appProvider = Provider.of<AppProvider>(context);
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 24),
                    onPressed: () => _showHelpSupportModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // User Info Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline_rounded, size: 44, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appProvider.userName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appProvider.userEmail,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.transparent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      ),
                      onPressed: () => _showEditProfileDialog(context, appProvider),
                      icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                      label: const Text('Edit Profile', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cloud Sync & Multi-Device Backup Card
              CustomCard(
                backgroundColor: AppColors.surfaceElevated,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        appProvider.isCloudSyncEnabled ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appProvider.isCloudSyncEnabled ? 'Cloud Sync Active ✨' : 'Backup & Multi-Device Sync',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appProvider.isCloudSyncEnabled
                                ? 'Your journal reflections & streaks are backed up'
                                : 'Sign in to save your journey across all devices',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appProvider.isCloudSyncEnabled ? AppColors.surface : accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!appProvider.isCloudSyncEnabled) {
                          _showCloudSyncDialog(context, appProvider);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cloud backup is up-to-date! ☁️')),
                          );
                        }
                      },
                      child: Text(
                        appProvider.isCloudSyncEnabled ? 'Synced' : 'Connect',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: appProvider.isCloudSyncEnabled ? AppColors.textSecondary : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Streak & Rewards Card
              Text(
                'STREAK & REWARDS',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              CustomCard(
                backgroundColor: AppColors.surfaceElevated,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${appProvider.streakData.currentStreak} Day Streak',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Best: ${appProvider.streakData.longestStreak} days',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.goldAccent.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded, size: 16, color: AppColors.goldAccent),
                              SizedBox(width: 4),
                              Text(
                                'Level 2',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadge(Icons.spa_rounded, AppColors.growthAccent, 'Mindful'),
                        _buildBadge(Icons.electric_bolt_rounded, AppColors.goldAccent, 'Consistent'),
                        _buildBadge(Icons.auto_awesome_rounded, AppColors.healingAccent, 'Reflective'),
                        _buildBadge(Icons.favorite_rounded, Colors.pinkAccent, 'Resilient'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme Mode Selector
              Text(
                'THEME & ATMOSPHERE',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              CustomCard(
                backgroundColor: AppColors.surfaceElevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atmospheric Mode',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Growth (Deep Sapphire/Teal) for energizing action, or Healing (Deep Violet/Rose) for calming somatic recovery.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => appProvider.setAppMode(AppMode.growth),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appProvider.appModeSetting == AppMode.growth ? AppColors.growthAccent : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.growth ? AppColors.growthAccent : AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              '⚡ Growth',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appProvider.appModeSetting == AppMode.growth ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => appProvider.setAppMode(AppMode.healing),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appProvider.appModeSetting == AppMode.healing ? AppColors.healingAccent : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.healing ? AppColors.healingAccent : AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              '🌸 Healing',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appProvider.appModeSetting == AppMode.healing ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => appProvider.setAppMode(AppMode.auto),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appProvider.appModeSetting == AppMode.auto ? accent : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.auto ? accent : AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              '🔄 Auto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appProvider.appModeSetting == AppMode.auto ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Settings List
              _buildMenuItem(
                context,
                Icons.notifications_none_rounded,
                'Daily Reminders & Notifications ⏰',
                onTap: () => _showRemindersModal(context),
              ),
              _buildMenuItem(
                context,
                Icons.mic_none_rounded,
                'My Voice Studio 🎙️',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyVoiceTab()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                Icons.menu_book_rounded,
                'Reflections Journal 📖',
                onTap: () => appProvider.setNavIndex(2),
              ),
              _buildMenuItem(
                context,
                Icons.favorite_border_rounded,
                'Favorite Affirmations ❤️',
                onTap: () => appProvider.setNavIndex(0),
              ),
              _buildMenuItem(
                context,
                Icons.widgets_outlined,
                'Widgets Studio 🎨',
                onTap: () {
                  if (!appProvider.isPremium) {
                    PaywallModal.show(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WidgetsTab()),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context,
                Icons.help_outline_rounded,
                'Help, FAQ & Support 💡',
                onTap: () => _showHelpSupportModal(context),
              ),
              const SizedBox(height: 12),

              // Reset App Data Button
              _buildMenuItem(
                context,
                Icons.restart_alt_rounded,
                'Reset App & Clear All Memory 🔄',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text('Reset App & Clear Memory?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
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
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomCard(
        backgroundColor: AppColors.surfaceElevated,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // --- 1. Edit Profile Dialog ---
  void _showEditProfileDialog(BuildContext context, AppProvider appProvider) {
    final nameCtrl = TextEditingController(text: appProvider.userName);
    final emailCtrl = TextEditingController(text: appProvider.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Your Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentForMode(appProvider.isGrowthMode),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              appProvider.updateProfile(name: nameCtrl.text, email: emailCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully! ✨')),
              );
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 2. Reminders & Notifications Modal ---
  void _showRemindersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final s = _notificationService.settings;
            final isGrowth = Provider.of<AppProvider>(context, listen: false).isGrowthMode;
            final accent = AppColors.accentForMode(isGrowth);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    'Affirmation Reminders ⏰',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get gentle, scientifically-timed mindset prompts throughout your day.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Morning Reminder Row
                  CustomCard(
                    backgroundColor: AppColors.surfaceElevated,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('☀️ Morning Energizer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(s.morningTime.formatTimeOfDay(), style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.textSecondary),
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: s.morningTime);
                                if (picked != null) {
                                  final updated = s.copyWith(morningTime: picked);
                                  await _notificationService.updateSettings(updated);
                                  setModalState(() {});
                                }
                              },
                            ),
                            Switch(
                              value: s.isMorningEnabled,
                              activeColor: accent,
                              onChanged: (val) async {
                                final updated = s.copyWith(isMorningEnabled: val);
                                await _notificationService.updateSettings(updated);
                                setModalState(() {});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Evening Reminder Row
                  CustomCard(
                    backgroundColor: AppColors.surfaceElevated,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🌙 Evening Wind-Down', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(s.eveningTime.formatTimeOfDay(), style: TextStyle(color: AppColors.healingAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.textSecondary),
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: s.eveningTime);
                                if (picked != null) {
                                  final updated = s.copyWith(eveningTime: picked);
                                  await _notificationService.updateSettings(updated);
                                  setModalState(() {});
                                }
                              },
                            ),
                            Switch(
                              value: s.isEveningEnabled,
                              activeColor: AppColors.healingAccent,
                              onChanged: (val) async {
                                final updated = s.copyWith(isEveningEnabled: val);
                                await _notificationService.updateSettings(updated);
                                setModalState(() {});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminders scheduled! ⏰✨')),
                        );
                      },
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. Cloud Sync & Multi-Device Modal ---
  void _showCloudSyncDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: AppColors.growthAccent, size: 28),
            SizedBox(width: 10),
            Text(
              'Cloud Backup',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connect your account to synchronize your journal reflections, custom vision boards, recorded voices, and streak data across your phone, tablet, and web.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.growthAccent, size: 20),
              title: const Text('Automatic daily backup', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.growthAccent, size: 20),
              title: const Text('End-to-end privacy encryption', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay Guest', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentForMode(appProvider.isGrowthMode),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              appProvider.setCloudSync(true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cloud sync enabled! Reflections backed up ☁️')),
              );
            },
            icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white),
            label: const Text('Enable Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 4. Help & Support / FAQ Modal ---
  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (sheetCtx, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    'Frequently Asked Questions 💡',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem('How does the AI audio pacing work?', 'AVAN uses a calibrated 18-second affirmation cycle (6 seconds of crystal-clear speech followed by 12 seconds of peaceful reflection silence) to allow psychological reframing to deeply integrate into your subconscious.'),
                  _buildFaqItem('How does the 16D personalization vector adapt to me?', 'Every time you favorite an affirmation, complete a journal entry, or select a mood, AVAN runs an Exponential Moving Average (EMA) shift on your on-device vector to prioritize statements that resonate with your archetype.'),
                  _buildFaqItem('How do I restore my Play Store purchase?', 'If you switch devices or reinstall AVAN, open any premium locked playlist and tap "Restore Purchases" at the bottom of the paywall modal to immediately recover your subscription.'),
                  _buildFaqItem('Does AVAN work offline?', 'Yes! AVAN includes procedural in-memory binaural and Solfeggio soundscapes as well as local speech synthesis that function 100% offline without requiring internet.'),
                  const SizedBox(height: 24),
                  const Text('Need direct help?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  CustomCard(
                    backgroundColor: AppColors.surfaceElevated,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Icon(Icons.email_outlined, color: AppColors.growthAccent, size: 24),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Developer Support', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 2),
                              Text('support@avanapp.com', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: CustomCard(
        backgroundColor: AppColors.surfaceElevated,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45)),
          ],
        ),
      ),
    );
  }
}
