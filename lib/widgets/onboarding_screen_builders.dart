import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'onboarding_animations.dart';
import 'glass_card.dart';
import 'liquid_glass_input_field.dart';
import 'custom_button.dart';

class OnboardingOption {
  final String emoji;
  final String label;
  final String? description;

  const OnboardingOption({
    required this.emoji,
    required this.label,
    this.description,
  });
}

class OnboardingTypeScreen extends StatelessWidget {
  final String prompt;
  final String? subtitle;
  final TextEditingController controller;
  final String hintText;
  final String ctaText;
  final VoidCallback onContinue;
  final int maxLines;
  final bool autofocus;
  final List<String>? suggestionChips;

  const OnboardingTypeScreen({
    Key? key,
    required this.prompt,
    this.subtitle,
    required this.controller,
    required this.hintText,
    required this.ctaText,
    required this.onContinue,
    this.maxLines = 1,
    this.autofocus = true,
    this.suggestionChips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TypewriterText(
            text: prompt,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 32),
          BottomPopItem(
            delay: const Duration(milliseconds: 300),
            child: LiquidGlassInputField(
              controller: controller,
              hintText: hintText,
              maxLines: maxLines,
              autofocus: autofocus,
            ),
          ),
          if (suggestionChips != null && suggestionChips!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestionChips!.map((chip) {
                return GestureDetector(
                  onTap: () {
                    final cleanText = chip.replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '').trim();
                    controller.text = cleanText;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          BottomPopItem(
            delay: const Duration(milliseconds: 400),
            child: CustomButton(
              text: ctaText,
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingTapScreen extends StatelessWidget {
  final String prompt;
  final String? subtitle;
  final List<OnboardingOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const OnboardingTapScreen({
    Key? key,
    required this.prompt,
    this.subtitle,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TypewriterText(
            text: prompt,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 28),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final isSelected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: BottomPopItem(
                delay: Duration(milliseconds: 300 + (index * 100)),
                child: GestureDetector(
                  onTap: () => onSelect(index),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    accentColor: AppColors.growthAccent,
                    glowIntensity: isSelected ? 0.7 : 0.0,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.growthAccent.withOpacity(0.18)
                                : AppColors.surfaceElevated,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            option.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: GoogleFonts.inter(
                                  color: isSelected ? AppColors.growthAccent : AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                              if (option.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  option.description!,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.check_circle_rounded, color: AppColors.growthAccent, size: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
