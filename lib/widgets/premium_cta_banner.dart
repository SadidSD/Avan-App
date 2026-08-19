import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PremiumCtaBanner extends StatefulWidget {
  final VoidCallback? onTap;

  const PremiumCtaBanner({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  State<PremiumCtaBanner> createState() => _PremiumCtaBannerState();
}

class _PremiumCtaBannerState extends State<PremiumCtaBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _borderColorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _borderColorAnim = ColorTween(
      begin: AppColors.goldAccent.withOpacity(0.2),
      end: AppColors.goldAccent.withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8F0),
                  Color(0xFFFFF2E5),
                  Color(0xFFFFF8F0),
                ],
              ),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: _borderColorAnim.value ?? const Color(0x33C4956A),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.goldAccent,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unlock All Affirmations',
                        style: AppTextStyles.premiumCta,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Start your free trial →',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: AppColors.goldAccent.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
