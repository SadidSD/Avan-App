import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // === CORMORANT GARAMOND — Elegant serif for quotes & hero text ===
  static TextStyle get heroTitle => GoogleFonts.cormorantGaramond(
        fontSize: 38,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get heroSubtitle => GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get quote => GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get quoteLarge => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // === INTER — Clean sans-serif for UI ===
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      );

  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  static TextStyle get greeting => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get streakText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  // === ACCENT-COLORED HELPERS ===
  static TextStyle accentTitle(Color accent) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: accent,
      );

  static TextStyle modeLabel(Color accent) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: accent,
        letterSpacing: 0.5,
      );
}
