import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/app_provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/paywall_modal.dart';
import '../../data/playlists_data.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final personalizedPlaylist = freePlaylists.isNotEmpty ? freePlaylists.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _FadeInSection(
                delay: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF333333), Color(0xFF8B6B5D), Color(0xFF333333)],
                                stops: [0.0, 0.5, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'Good morning, Alex',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _AnimatedWaveEmoji(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take a deep breath and start your day.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary.withOpacity(0.8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.borderSoft.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: AppColors.borderSoft.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 24),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0x66FF6B6B), blurRadius: 4, spreadRadius: 1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Today's Affirmation Hero Card
              _FadeInSection(
                delay: 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4BBA5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF9E8D9), Color(0xFFE2C4A8)],
                          ),
                        ),
                      ),
                      // Decorative orbs
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: 20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4BBA5).withOpacity(0.4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "TODAY'S AFFIRMATION",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: Color(0xFF8B6B5D),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '"${audioProvider.currentAffirmation?.quote ?? 'Every day is a new beginning'}"',
                              style: const TextStyle(
                                fontFamily: 'Georgia', // Elegant serif
                                fontStyle: FontStyle.italic,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: Color(0xFF4A3B32),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      audioProvider.nextAffirmation();
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF4A3B32)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Refresh',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF4A3B32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.eco_rounded, color: Color(0xFF8B6B5D), size: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Your Personalized Playlist Section
              if (personalizedPlaylist != null) ...[
                _FadeInSection(
                  delay: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Your Personalized Playlist'),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFDFD6), Color(0xFFF2C2B5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF2C2B5).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              audioProvider.openPlaylist(personalizedPlaylist, context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.stars_rounded, color: Color(0xFFD67362), size: 32),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const _PulseBadge(text: '24h free access'),
                                        const SizedBox(height: 8),
                                        Text(
                                          personalizedPlaylist.title,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                            color: Color(0xFF4A3B32),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${personalizedPlaylist.duration} • ${personalizedPlaylist.category}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: const Color(0xFF4A3B32).withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const _RingAnimatedPlayButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
              ],

              // Free Playlists Section
              _FadeInSection(
                delay: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Free Playlists'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: freePlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = freePlaylists[index];
                          // Unique gradients based on index
                          final gradients = [
                            const [Color(0xFFE3F0E5), Color(0xFFB5D8C1)],
                            const [Color(0xFFF4E5F7), Color(0xFFD3B6DD)],
                            const [Color(0xFFFFF0D4), Color(0xFFE8CFA6)],
                            const [Color(0xFFE5F1F7), Color(0xFFB1D2E3)],
                          ];
                          final icons = [Icons.spa_rounded, Icons.nightlight_round, Icons.wb_sunny_rounded, Icons.water_drop_rounded];
                          
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    audioProvider.openPlaylist(playlist, context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: gradients[index % gradients.length],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                icons[index % icons.length],
                                                color: Colors.white.withOpacity(0.9),
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          playlist.title,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${playlist.duration} • ${playlist.category}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Premium Playlists Section
              _FadeInSection(
                delay: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Premium Playlists'),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: premiumPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = premiumPlaylists[index];
                        final isLocked = !appProvider.isPremium;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              border: Border.all(
                                color: isLocked ? Colors.transparent : AppColors.goldAccent.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (isLocked) {
                                          PaywallModal.show(context);
                                        } else {
                                          audioProvider.openPlaylist(playlist, context);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isLocked
                                                      ? [const Color(0xFFF0F0F0), const Color(0xFFE0E0E0)]
                                                      : [const Color(0xFFFFF7E6), const Color(0xFFFFE4B5)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                isLocked ? Icons.workspace_premium_rounded : Icons.star_rounded, 
                                                color: isLocked ? const Color(0xFF9E9E9E) : AppColors.goldAccent, 
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    playlist.title,
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16,
                                                      color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${playlist.duration} • ${playlist.category}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isLocked ? const Color(0xFFF5F5F5) : AppColors.buttonDark,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded, 
                                                color: isLocked ? const Color(0xFFBDBDBD) : Colors.white, 
                                                size: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isLocked)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                                            child: Container(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Your Progress
              _FadeInSection(
                delay: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Your Progress'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Streak
                          Column(
                            children: [
                              const _GlowingFireIcon(),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.softBeige,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${appProvider.streakData.currentStreak}',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'Day Streak',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(height: 80, width: 1, color: AppColors.borderSoft.withOpacity(0.5)),
                          // Weekly Progress
                          Column(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: appProvider.streakData.weeklyProgress),
                                      duration: const Duration(milliseconds: 1500),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return CircularProgressIndicator(
                                          value: value,
                                          strokeWidth: 6,
                                          backgroundColor: AppColors.nudeAccent,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B6B5D)),
                                          strokeCap: StrokeCap.round,
                                        );
                                      },
                                    ),
                                    const Icon(Icons.insights_rounded, color: Color(0xFF8B6B5D), size: 24),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.softBeige,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${(appProvider.streakData.weeklyProgress * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'Weekly Goal',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets for Premium UI
// -----------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6B5D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _AnimatedWaveEmoji extends StatefulWidget {
  const _AnimatedWaveEmoji();

  @override
  State<_AnimatedWaveEmoji> createState() => _AnimatedWaveEmojiState();
}

class _AnimatedWaveEmojiState extends State<_AnimatedWaveEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: const Text('👋', style: TextStyle(fontSize: 24)),
        );
      },
    );
  }
}

class _PulseBadge extends StatefulWidget {
  final String text;
  const _PulseBadge({required this.text});

  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD67362).withOpacity(_animation.value * 0.3),
                blurRadius: 8,
                spreadRadius: _animation.value * 2,
              ),
            ],
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFFD67362),
            ),
          ),
        );
      },
    );
  }
}

class _RingAnimatedPlayButton extends StatefulWidget {
  const _RingAnimatedPlayButton();

  @override
  State<_RingAnimatedPlayButton> createState() => _RingAnimatedPlayButtonState();
}

class _RingAnimatedPlayButtonState extends State<_RingAnimatedPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A3B32).withOpacity(1.0 - _controller.value),
                  width: 2,
                ),
              ),
              transform: Matrix4.identity()..scale(1.0 + (_controller.value * 0.5)),
              transformAlignment: Alignment.center,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF4A3B32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            ),
          ],
        );
      },
    );
  }
}

class _GlowingFireIcon extends StatefulWidget {
  const _GlowingFireIcon();

  @override
  State<_GlowingFireIcon> createState() => _GlowingFireIconState();
}

class _GlowingFireIconState extends State<_GlowingFireIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB74D).withOpacity(_animation.value * 0.4),
                blurRadius: 15 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF9800), size: 36),
        );
      },
    );
  }
}

class _FadeInSection extends StatefulWidget {
  final Widget child;
  final int delay;

  const _FadeInSection({required this.child, required this.delay});

  @override
  State<_FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<_FadeInSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _isVisible ? Offset.zero : const Offset(0, 0.1),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
