import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class PaywallModal extends StatelessWidget {
  const PaywallModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (context) => const PaywallModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.tanAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.workspace_premium_rounded, size: 56, color: AppColors.goldAccent),
          const SizedBox(height: 16),
          const Text(
            'Unlock AVAN Premium ✨',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock full access to 13 Playlists, Say After Me interactive AI, My Voice Studio recorder, & Vision Board.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Button 1: Demo Premium Unlock
          CustomButton(
            text: 'Try Free for 7 Days (Demo Unlock)',
            onPressed: () {
              if (!appProvider.isPremium) {
                appProvider.togglePremium();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✨ Premium Unlocked! Enjoy all features.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Button 2: Continue with Free Features
          TextButton(
            onPressed: () {
              appProvider.setNavIndex(0); // Switch to Free Playlist / Home Dashboard
              Navigator.pop(context);
            },
            child: const Text(
              'Continue with Free Features',
              style: TextStyle(
                color: AppColors.buttonDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
