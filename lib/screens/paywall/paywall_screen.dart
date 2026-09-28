import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/purchase_service.dart';
import '../../services/adapty_service.dart';
import '../../theme/app_colors.dart';
import '../main_navigation_screen.dart';

/// Fullscreen, high-converting subscription paywall experience for AVAN.
/// Incorporates modern trial transparency, localized store pricing,
/// value comparison matrix, and developer sandbox fallback.
class PaywallScreen extends StatefulWidget {
  final bool isOnboarding;

  const PaywallScreen({
    super.key,
    this.isOnboarding = false,
  });

  static void open(BuildContext context, {bool isOnboarding = false}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(isOnboarding: isOnboarding),
      ),
    );
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  String _selectedPlan = 'annual'; // 'annual' or 'monthly'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _purchaseService.initialize((isPremium) {
      if (isPremium && mounted) {
        _onPurchaseSuccessful();
      }
    });
  }

  void _onPurchaseSuccessful() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setPremium(true);

    if (widget.isOnboarding) {
      appProvider.completeOnboarding();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        (route) => false,
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.goldAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✨ Welcome to AVAN Unlimited! All features unlocked.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);

    final String productId;
    if (_selectedPlan == 'annual') {
      productId = PurchaseService.annualSubscriptionId;
    } else if (_selectedPlan == 'monthly') {
      productId = PurchaseService.monthlySubscriptionId;
    } else {
      productId = PurchaseService.weeklySubscriptionId;
    }

    final success = await _purchaseService.buyProduct(productId);
    if (success && mounted) {
      _onPurchaseSuccessful();
    } else if (mounted) {
      setState(() => _isLoading = false);
      _showPurchaseDiagnosticsDialog(context, productId);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final restored = await _purchaseService.restorePurchases();
    if (mounted) {
      setState(() => _isLoading = false);
      if (restored) {
        appProvider.setPremium(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Subscriptions restored successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscriptions found to restore.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDismiss() {
    if (widget.isOnboarding) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.completeOnboarding();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        (route) => false,
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final annualPrice = _purchaseService.annualPrice;
    final monthlyPrice = _purchaseService.monthlyPrice;
    final weeklyPrice = _purchaseService.weeklyPrice;
    final monthlyEquiv = _purchaseService.annualMonthlyEquivalent;
    final savings = _purchaseService.annualSavingsPercentage;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Stack(
        children: [
          // Background ambient gradient aura
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldAccent.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.healingAccent.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar with Close / Skip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                        onPressed: _handleDismiss,
                        tooltip: 'Close',
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 20),
                            onPressed: () => _showDiagnosticsDialog(context),
                            tooltip: 'Store Diagnostics',
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _handleDismiss,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.isOnboarding ? 'Skip for Now' : 'Continue Free',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),

                        // Gold Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.goldAccent.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.goldAccent),
                              const SizedBox(width: 6),
                              Text(
                                'AVAN UNLIMITED ACCESS',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Main Hero Title
                        Text(
                          'Awaken Your Highest Potential',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Step into trauma-informed psychological rewiring, binaural frequencies, and customized manifestation canvases.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Value Grid / Highlights Matrix
                        _buildFeatureCard(
                          icon: Icons.headphones_rounded,
                          title: 'All 63 Mindset Playlists',
                          subtitle: 'Unlock deep sessions across career, anxiety, sleep, grief & ADHD.',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.graphic_eq_rounded,
                          title: 'Atmospheric Soundscape Mixer',
                          subtitle: '528Hz Miracle, Rain, Wind, Theta waves, and custom voice pitch.',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.dashboard_customize_rounded,
                          title: 'Unlimited Vision Board Studio',
                          subtitle: 'Multi-board canvas, 66+ preset packs, and 9:16 Retina wallpaper export.',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          icon: Icons.widgets_rounded,
                          title: 'Full Widget Customization Suite',
                          subtitle: 'Lock Screen pills, 2x2, 4x2, 4x4, custom typography & auto-refresh.',
                        ),
                        const SizedBox(height: 24),

                        // 3-Step Trial Roadmap (Visual Timeline)
                        _buildTrialTimeline(),
                        const SizedBox(height: 24),

                        // Plan Selector: Annual vs. Monthly vs. Weekly
                        _buildPlanCard(
                          id: 'annual',
                          title: 'Annual Membership',
                          priceDisplay: annualPrice,
                          pricePeriod: '/ year',
                          subtext: '$monthlyEquiv • 7-day free trial included',
                          badgeText: 'SAVE $savings • BEST VALUE',
                          isHero: true,
                        ),
                        const SizedBox(height: 12),
                        _buildPlanCard(
                          id: 'monthly',
                          title: 'Monthly Membership',
                          priceDisplay: monthlyPrice,
                          pricePeriod: '/ month',
                          subtext: 'Flexible monthly billing • Cancel anytime',
                          badgeText: null,
                          isHero: false,
                        ),
                        const SizedBox(height: 12),
                        _buildPlanCard(
                          id: 'weekly',
                          title: 'Weekly Membership',
                          priceDisplay: weeklyPrice,
                          pricePeriod: '/ week',
                          subtext: 'Short-term access • Billed weekly',
                          badgeText: null,
                          isHero: false,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Area
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D14),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Big CTA Button
                      GestureDetector(
                        onTap: _isLoading ? null : _handlePurchase,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE2B778), Color(0xFFC49552)],
                            ),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE2B778).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedPlan == 'annual'
                                            ? 'Start 7-Day Free Trial'
                                            : (_selectedPlan == 'monthly'
                                                ? 'Unlock AVAN Monthly'
                                                : 'Unlock AVAN Weekly'),
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF16130E),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Color(0xFF16130E),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Footer: Trust & Restore
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : _handleRestore,
                            child: Text(
                              'Restore Purchases',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                          GestureDetector(
                            onTap: () => _showLegalDialog(
                              context,
                              'Terms of Service',
                              'Subscriptions renew automatically unless canceled at least 24 hours before the end of the trial or current period in your Google Play Store / Apple ID account settings. Family sharing and cross-device sync are included.',
                            ),
                            child: Text(
                              'Terms',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                          GestureDetector(
                            onTap: () => _showLegalDialog(
                              context,
                              'Privacy Policy',
                              'AVAN does not sell your personal reflections or biometrics. All affirmations, vision board goals, and habit vectors remain encrypted on your device and private storage.',
                            ),
                            child: Text(
                              'Privacy',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                              ),
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
        ],
      ),
    );
  }

  // ===========================================================================
  // SUB-COMPONENTS
  // ===========================================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.goldAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.goldAccent, size: 16),
              const SizedBox(width: 8),
              Text(
                'NO COMMITMENT • CANCEL ANYTIME',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.goldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTimelineStep(
            dotIcon: Icons.lock_open_rounded,
            title: 'Today: Instant VIP Access',
            subtitle: 'Begin your 7-day free trial. All features unlocked.',
            isLast: false,
          ),
          _buildTimelineStep(
            dotIcon: Icons.notifications_none_rounded,
            title: 'Day 5: Friendly Reminder',
            subtitle: 'We notify you before your trial converts.',
            isLast: false,
          ),
          _buildTimelineStep(
            dotIcon: Icons.check_circle_outline_rounded,
            title: 'Day 7: First Billing Cycle',
            subtitle: 'Billed yearly. Cancel anytime in Google Play Store.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData dotIcon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.goldAccent.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldAccent.withOpacity(0.6), width: 1.2),
              ),
              child: Icon(dotIcon, size: 12, color: AppColors.goldAccent),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 24,
                color: AppColors.goldAccent.withOpacity(0.25),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String priceDisplay,
    required String pricePeriod,
    required String subtext,
    required String? badgeText,
    required bool isHero,
  }) {
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldAccent.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.goldAccent
                : Colors.white.withOpacity(0.12),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldAccent.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16130E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      priceDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.goldAccent : Colors.white,
                      ),
                    ),
                    Text(
                      pricePeriod,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(body, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticsDialog(BuildContext context) {
    final logs = PurchaseService.diagnosticLogs.join('\n');
    final products = _purchaseService.products.map((p) => '${p.id}: ${p.price}').join('\n');
    final isAvailable = _purchaseService.isAvailable;
    final lastError = PurchaseService.lastError ?? 'None';
    final adaptyInit = AdaptyService().isInitialized;

    final summary = '=== AVAN STORE DIAGNOSTICS ===\n'
        '• Store Available: $isAvailable\n'
        '• Adapty Ready: $adaptyInit\n'
        '• Store Products Count: ${_purchaseService.products.length}\n'
        '• Loaded Products:\n${products.isNotEmpty ? products : "None loaded from Google Play"}\n'
        '• Last Error: $lastError\n\n'
        '=== RECENT EVENT LOGS ===\n${logs.isNotEmpty ? logs : "No events recorded"}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.terminal_rounded, color: AppColors.goldAccent, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Store & Billing Diagnostics',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    summary,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: summary));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diagnostics copied to clipboard! Paste it to developer.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Diagnostics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: const Color(0xFF16130E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onPurchaseSuccessful();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldAccent,
                      side: const BorderSide(color: AppColors.goldAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Test Unlock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDiagnosticsDialog(BuildContext context, String productId) {
    final error = PurchaseService.lastError ?? 'Purchase flow returned without completion.';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.info_outline_rounded, color: AppColors.goldAccent, size: 24),
            SizedBox(width: 8),
            Text('Billing Update', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$error\n\nIf you are a License Tester and Google Play has not fully synced your subscription SKUs yet, you can tap "Activate Test Pro" to continue testing all features.',
          style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Purchase Failure for $productId: $error'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error copied to clipboard!'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Copy Error', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onPurchaseSuccessful();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldAccent,
              foregroundColor: const Color(0xFF16130E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Activate Test Pro'),
          ),
        ],
      ),
    );
  }
}
