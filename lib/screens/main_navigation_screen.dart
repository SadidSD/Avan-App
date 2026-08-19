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
    final int currentIndex =
        appProvider.currentNavIndex > 4 ? 0 : appProvider.currentNavIndex;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _tabs,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 85 + bottomPadding,
            child: const AudioPlayerBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCustomNavBar(context, currentIndex, appProvider, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar(
      BuildContext context, int currentIndex, AppProvider appProvider, double bottomPadding) {
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: accent.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.06),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      currentIndex: currentIndex,
                      appProvider: appProvider,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      isGrowth: isGrowth,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 1,
                      currentIndex: currentIndex,
                      appProvider: appProvider,
                      icon: Icons.headphones_outlined,
                      activeIcon: Icons.headphones_rounded,
                      isGrowth: isGrowth,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 2,
                      currentIndex: currentIndex,
                      appProvider: appProvider,
                      icon: Icons.favorite_border_rounded,
                      activeIcon: Icons.favorite_rounded,
                      isGrowth: isGrowth,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      currentIndex: currentIndex,
                      appProvider: appProvider,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      isGrowth: isGrowth,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      currentIndex: currentIndex,
                      appProvider: appProvider,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      isGrowth: isGrowth,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required AppProvider appProvider,
    required IconData icon,
    required IconData activeIcon,
    required bool isGrowth,
  }) {
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
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? Border.all(
                      color: accentColor.withOpacity(0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? accentColor : AppColors.textMuted,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
