import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AffirmationCard extends StatelessWidget {
  final String quote;
  final String playlistName;
  final String imagePath;
  final int durationMinutes;
  final bool isFavorite;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const AffirmationCard({
    Key? key,
    required this.quote,
    required this.playlistName,
    required this.imagePath,
    required this.durationMinutes,
    required this.isFavorite,
    required this.accentColor,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isFavorite
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x0FFFDDBE),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                    child: SizedBox(
                      height: 100.0,
                      width: double.infinity,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black12,
                          child: const Icon(
                            Icons.self_improvement_rounded,
                            color: Colors.white54,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                '⏱ ${durationMinutes}m',
                                style: AppTextStyles.durationBadge,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: onFavoriteToggle,
                              child: Icon(
                                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFavorite ? accentColor : AppColors.textMuted,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          quote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.affirmationCardQuote,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          playlistName,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
