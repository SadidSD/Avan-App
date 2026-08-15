import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/paywall_modal.dart';

import 'home/home_tab.dart';
import 'profile/profile_tab.dart';
import 'say_after_me/say_after_me_tab.dart';
import 'journal/journal_tab.dart';
import 'vision_board/vision_board_tab.dart';

class MainNavigationScreen extends StatelessWidget {
  MainNavigationScreen({Key? key}) : super(key: key);

  final List<Widget> _tabs = [
    const HomeTab(),
    const SayAfterMeTab(),
    const JournalTab(),
    const VisionBoardTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final int currentIndex = appProvider.currentNavIndex > 4 ? 0 : appProvider.currentNavIndex;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _tabs,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: AudioPlayerBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCustomNavBar(context, currentIndex, appProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context, int currentIndex, AppProvider appProvider) {
    final isGrowth = appProvider.isGrowthMode;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.92),
            border: const Border(
              top: BorderSide(
                color: AppColors.border, 
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    _buildNavItem(context, 0, currentIndex, appProvider, Icons.home_outlined, Icons.home_rounded, 'Playlist', isGrowth),
                    _buildNavItem(context, 1, currentIndex, appProvider, Icons.mic_none_outlined, Icons.mic_rounded, 'Say After', isGrowth),
                    _buildNavItem(context, 2, currentIndex, appProvider, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Journal', isGrowth),
                    _buildNavItem(context, 3, currentIndex, appProvider, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Vision', isGrowth),
                    _buildNavItem(context, 4, currentIndex, appProvider, Icons.person_outline_rounded, Icons.person_rounded, 'Profile', isGrowth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, int currentIndex, AppProvider appProvider, IconData icon, IconData activeIcon, String label, bool isGrowth) {
    final bool isSelected = currentIndex == index;
    final accentColor = AppColors.accentForMode(isGrowth);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if ([1, 3].contains(index) && !appProvider.isPremium) {
            PaywallModal.show(context);
            return;
          }
          appProvider.setNavIndex(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? accentColor : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
                color: isSelected ? accentColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
