import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/purchase_service.dart';
import '../screens/paywall/paywall_screen.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

/// Contextual bottom-sheet paywall triggered by in-app feature locks.
class PaywallModal extends StatefulWidget {
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
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  final PurchaseService _purchaseService = PurchaseService();
  String _selectedPlan = 'annual'; // 'annual' or 'monthly'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _purchaseService.initialize((isPremium) {
      if (isPremium && mounted) {
        appProvider.setPremium(true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Welcome to AVAN Unlimited! All features unlocked.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _handlePurchase(AppProvider appProvider) async {
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
      appProvider.setPremium(true);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Welcome to AVAN Unlimited! All features unlocked.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleRestore(AppProvider appProvider) async {
    setState(() => _isLoading = true);
    final restored = await _purchaseService.restorePurchases();
    if (mounted) {
      setState(() => _isLoading = false);
      if (restored) {
        appProvider.setPremium(true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Subscriptions restored successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscription found to restore.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final annualPrice = _purchaseService.annualPrice;
    final monthlyPrice = _purchaseService.monthlyPrice;
    final weeklyPrice = _purchaseService.weeklyPrice;
    final monthlyEquiv = _purchaseService.annualMonthlyEquivalent;
    final savings = _purchaseService.annualSavingsPercentage;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF13131D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 38,
              color: AppColors.goldAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock AVAN Unlimited ✨',
            style: GoogleFonts.inter(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get instant access to all 63 playlists, the complete atmospheric soundscape mixer, and the vision board studio.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.65),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Plan Selector Option 1: Annual (Recommended)
          _buildCompactPlanOption(
            id: 'annual',
            title: 'Annual Membership (7-Day Trial)',
            price: '$annualPrice / yr',
            subtext: '$monthlyEquiv • SAVE $savings',
            badge: 'BEST VALUE',
          ),
          const SizedBox(height: 8),

          // Plan Selector Option 2: Monthly
          _buildCompactPlanOption(
            id: 'monthly',
            title: 'Monthly Membership',
            price: '$monthlyPrice / mo',
            subtext: 'Flexible monthly billing • Cancel anytime',
            badge: null,
          ),
          const SizedBox(height: 8),

          // Plan Selector Option 3: Weekly
          _buildCompactPlanOption(
            id: 'weekly',
            title: 'Weekly Membership',
            price: '$weeklyPrice / wk',
            subtext: 'Short-term access • Billed weekly',
            badge: null,
          ),
          const SizedBox(height: 18),

          // Primary Subscribe Action Button
          CustomButton(
            text: _isLoading
                ? 'Connecting Store...'
                : (_selectedPlan == 'annual'
                    ? 'Start 7-Day Free Trial'
                    : (_selectedPlan == 'monthly'
                        ? 'Unlock Monthly (\$14.99)'
                        : 'Unlock Weekly (\$3.99)')),
            backgroundColor: AppColors.goldAccent,
            textColor: const Color(0xFF16130E),
            onPressed: _isLoading ? () {} : () => _handlePurchase(appProvider),
          ),
          const SizedBox(height: 12),

          // Link to Full Screen Paywall
          GestureDetector(
            onTap: () {
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              Navigator.pop(context);
              rootNavigator.push(
                MaterialPageRoute(
                  builder: (_) => const PaywallScreen(),
                ),
              );
            },
            child: Text(
              'See full feature breakdown & trial timeline →',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.goldAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Footer: Restore Purchases & Free Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => _handleRestore(appProvider),
                child: Text(
                  'Restore Purchases',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(' • ', style: TextStyle(color: Colors.white.withOpacity(0.3))),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue Free',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlanOption({
    required String id,
    required String title,
    required String price,
    required String subtext,
    required String? badge,
  }) {
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldAccent.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.goldAccent
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: isSelected ? AppColors.goldAccent : Colors.white54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16130E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.goldAccent : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
