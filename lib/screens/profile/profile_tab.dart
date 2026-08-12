import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/paywall_modal.dart';
import '../widgets_preview/widgets_tab.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

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
                children: const [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 24),
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
                      decoration: const BoxDecoration(
                        color: AppColors.softBeige,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline_rounded, size: 44, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Alex',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'alex@email.com',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonDark,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.transparent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      onPressed: () {},
                      child: const Text('Edit Profile', style: TextStyle(fontSize: 13, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Streak & Rewards Card
              const Text(
                'Streak & Rewards',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CustomCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 26),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${appProvider.streakData.currentStreak}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                ),
                                const Text('Day Streak', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Container(height: 32, width: 1, color: AppColors.borderSoft),
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded, color: AppColors.greenAccent, size: 26),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${(appProvider.streakData.weeklyProgress * 100).toInt()}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                ),
                                const Text('Weekly Goal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: appProvider.streakData.weeklyProgress,
                      backgroundColor: AppColors.nudeAccent,
                      color: AppColors.buttonDark,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge(Icons.star_rounded, AppColors.goldAccent, 'Starter'),
                        const SizedBox(width: 16),
                        _buildBadge(Icons.shield_rounded, AppColors.tanAccent, '7 Days'),
                        const SizedBox(width: 16),
                        _buildBadge(Icons.diamond_rounded, Colors.grey.shade400, '30 Days'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demo Subscription Switcher
              CustomCard(
                backgroundColor: AppColors.softBeige,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appProvider.isPremium ? 'Plan: Premium Tier Unlocked' : 'Plan: Free Trial Mode',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        const Text('Toggle for testing locked features', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Switch(
                      value: appProvider.isPremium,
                      activeColor: AppColors.buttonDark,
                      onChanged: (val) => appProvider.togglePremium(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // App Mode Selector Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'App Experience Mode',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        Icon(Icons.palette_outlined, color: AppColors.tanAccent, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Switch between Growth and Healing modes', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => appProvider.setAppMode(AppMode.growth),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appProvider.appModeSetting == AppMode.growth ? AppColors.growthPrimary : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.growth ? AppColors.growthPrimary : AppColors.borderSoft),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              '🚀 Growth',
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
                              backgroundColor: appProvider.appModeSetting == AppMode.healing ? AppColors.healingPrimary : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.healing ? AppColors.healingPrimary : AppColors.borderSoft),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              '💔 Healing',
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
                              backgroundColor: appProvider.appModeSetting == AppMode.auto ? AppColors.buttonDark : Colors.transparent,
                              side: BorderSide(color: appProvider.appModeSetting == AppMode.auto ? AppColors.buttonDark : AppColors.borderSoft),
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
              _buildMenuItem(context, Icons.notifications_none_rounded, 'Reminders'),
              _buildMenuItem(context, Icons.menu_book_rounded, 'Journal', onTap: () => appProvider.setNavIndex(2)),
              _buildMenuItem(context, Icons.favorite_border_rounded, 'Favorites', onTap: () => appProvider.setNavIndex(0)),
              _buildMenuItem(context, Icons.download_outlined, 'Downloads'),
              _buildMenuItem(
                context,
                Icons.widgets_outlined,
                'Widgets Studio',
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
              _buildMenuItem(context, Icons.help_outline_rounded, 'Help & Support'),
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
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title configured & active ✨'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.tanAccent),
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
