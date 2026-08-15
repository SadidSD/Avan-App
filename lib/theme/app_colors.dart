import 'package:flutter/material.dart';

class AppColors {
  // === SHARED FOUNDATION (Stella-inspired dark cosmic base) ===
  static const Color background = Color(0xFF0A0A12);       // Near-black cosmic dark
  static const Color surface = Color(0xFF12121F);           // Slightly lighter dark surface
  static const Color surfaceElevated = Color(0xFF1A1A2E);   // Cards, modals
  static const Color border = Color(0x14FFFFFF);            // rgba(255,255,255,0.08)
  static const Color borderBright = Color(0x26FFFFFF);      // rgba(255,255,255,0.15)

  // Typography
  static const Color textPrimary = Color(0xFFF0EDFF);       // Soft warm white
  static const Color textSecondary = Color(0xFF8A85A0);     // Muted lavender-grey
  static const Color textMuted = Color(0xFF5A5570);         // Very muted

  // Glass effects
  static const Color glassOverlay = Color(0x1AFFFFFF);      // 10% white overlay
  static const Color glassBorder = Color(0x14FFFFFF);       // 8% white border
  static const Color glassBorderBright = Color(0x40FFFFFF); // 25% white border

  // Legacy aliases (keep for compatibility with existing widgets)
  static const Color cardSurface = surface;
  static const Color softBeige = surfaceElevated;
  static const Color nudeAccent = Color(0xFF2A2A3E);
  static const Color tanAccent = Color(0xFF8A85A0);
  static const Color borderSoft = border;
  static const Color buttonDark = Color(0xFF1A1A2E);
  static const Color iconColor = textPrimary;
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color greenAccent = Color(0xFF00E5CC);
  static const Color sleepDark = Color(0xFF060D2E);
  static const Color glowAccent = Color(0x4000E5CC);

  // === GROWTH MODE — Deep Sapphire + Electric Teal ===
  static const Color growthPrimary = Color(0xFF0F1B4C);        // Deep sapphire
  static const Color growthAccent = Color(0xFF00E5CC);         // Electric teal
  static const Color growthAccentSoft = Color(0x4000E5CC);     // Teal at 25% opacity
  static const Color growthGlow = Color(0x2600E5CC);           // Teal glow 15%
  static const Color growthCard = Color(0x990F1B4C);           // Dark navy glass 60%
  static const Color growthStreak = Color(0xFFFFD700);         // Gold
  static const Color growthTextPrimary = Color(0xFFF0EDFF);    // Shared soft white
  static const Color growthTextSecondary = Color(0xFF8A85A0);  // Shared muted
  static const Color growthBackground = background;            // Same cosmic dark
  static const Color growthCardBackground = surfaceElevated;   // Same elevated surface
  // Legacy
  static const Color growthSecondary = growthAccent;

  static const LinearGradient growthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF060D2E), // Midnight blue
      Color(0xFF0A0A12), // Cosmic dark
    ],
  );

  static const LinearGradient growthCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x260F1B4C),
      Color(0x1A00E5CC),
    ],
  );

  // === HEALING MODE — Deep Violet + Rose Quartz ===
  static const Color healingPrimary = Color(0xFF1A0A2E);       // Deep violet
  static const Color healingAccent = Color(0xFFFF7BAC);        // Rose quartz
  static const Color healingAccentSoft = Color(0x40FF7BAC);    // Rose at 25% opacity
  static const Color healingGlow = Color(0x26FF7BAC);          // Rose glow 15%
  static const Color healingCard = Color(0x991A0A2E);          // Dark plum glass 60%
  static const Color healingStreak = Color(0xFFC9B8FF);        // Lavender
  static const Color healingTextPrimary = Color(0xFFF0EDFF);   // Shared soft white
  static const Color healingTextSecondary = Color(0xFF8A85A0); // Shared muted
  static const Color healingBackground = background;           // Same cosmic dark
  static const Color healingCardBackground = surfaceElevated;  // Same elevated surface
  // Legacy
  static const Color healingSecondary = healingAccent;

  static const LinearGradient healingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0618), // Dark plum
      Color(0xFF0A0A12), // Cosmic dark
    ],
  );

  static const LinearGradient healingCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x261A0A2E),
      Color(0x1AFF7BAC),
    ],
  );

  // === SHARED GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F1B4C), Color(0xFF1A0A2E)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A12), Color(0xFF12121F)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00E5CC), Color(0xFF0F1B4C)],
  );

  // === HELPERS ===
  static Color accentForMode(bool isGrowth) =>
      isGrowth ? growthAccent : healingAccent;

  static Color glowForMode(bool isGrowth) =>
      isGrowth ? growthGlow : healingGlow;

  static Color accentSoftForMode(bool isGrowth) =>
      isGrowth ? growthAccentSoft : healingAccentSoft;

  static LinearGradient gradientForMode(bool isGrowth) =>
      isGrowth ? growthGradient : healingGradient;

  static LinearGradient cardGradientForMode(bool isGrowth) =>
      isGrowth ? growthCardGradient : healingCardGradient;

  static Color streakColorForMode(bool isGrowth) =>
      isGrowth ? growthStreak : healingStreak;
}
