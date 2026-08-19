import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

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
            content: Text('✨ Welcome to AVAN Premium! All features unlocked.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase(String productId, AppProvider appProvider) async {
    setState(() => _isLoading = true);
    final success = await _purchaseService.buyProduct(productId);
    if (success && mounted) {
      appProvider.setPremium(true);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Welcome to AVAN Premium! All features unlocked.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.workspace_premium_rounded,
              size: 52, color: AppColors.goldAccent),
          const SizedBox(height: 12),
          Text(
            'Unlock AVAN Premium ✨',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock all 11 psychological archetypes, interactive Say After Me AI, My Voice Studio recorder, & Vision Board generator.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Annual Plan (Best Value with Trial)
          CustomButton(
            text: _isLoading ? 'Connecting Store...' : 'Start 7-Day Free Trial (\$59.99/yr)',
            backgroundColor: AppColors.buttonDark,
            textColor: Colors.white,
            onPressed: _isLoading
                ? () {}
                : () => _handlePurchase(PurchaseService.annualSubscriptionId, appProvider),
          ),
          const SizedBox(height: 10),

          // Option 2: Monthly Plan
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.borderBright),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading
                ? null
                : () => _handlePurchase(PurchaseService.monthlySubscriptionId, appProvider),
            child: Text(
              'Monthly (\$9.99/mo)',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Footer: Restore Purchases & Free Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _purchaseService.restorePurchases(),
                child: Text(
                  'Restore Purchases',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
              TextButton(
                onPressed: () {
                  appProvider.setNavIndex(0);
                  Navigator.pop(context);
                },
                child: Text(
                  'Continue Free',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
}
