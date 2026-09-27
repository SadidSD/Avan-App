import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Standardized horizontal mood selector row widget for emotional state tracking.
class MoodSelectorRow extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;
  final VoidCallback? onClearMood;
  final Color? accentColor;
  final bool showHeader;
  final String title;

  static const List<Map<String, String>> defaultMoods = [
    {'emoji': '🌊', 'label': 'Calm', 'query': 'Calm'},
    {'emoji': '⚡', 'label': 'Anxious', 'query': 'Anxious'},
    {'emoji': '🥀', 'label': 'Exhausted', 'query': 'Exhausted'},
    {'emoji': '🌱', 'label': 'Grounded', 'query': 'Grounded'},
    {'emoji': '🔥', 'label': 'Ambitious', 'query': 'Ambitious'},
    {'emoji': '🕊️', 'label': 'Peaceful', 'query': 'Peaceful'},
  ];

  const MoodSelectorRow({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.onClearMood,
    this.accentColor,
    this.showHeader = true,
    this.title = 'HOW IS YOUR HEART TODAY?',
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.growthAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              if (selectedMood.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (onClearMood != null) {
                      onClearMood!();
                    } else {
                      onMoodSelected('');
                    }
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: defaultMoods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final m = defaultMoods[index];
              final isSelected =
                  selectedMood.toLowerCase() == m['query']!.toLowerCase();
              return GestureDetector(
                onTap: () => onMoodSelected(isSelected ? '' : m['query']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withOpacity(0.18)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accent : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m['emoji']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        m['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? accent : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
