import 'dart:ui';
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: _borderColorAnim.value ?? const Color(0x33CBA167),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
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
              ),
            ),
          );
        },
      ),
    );
  }
}
