import 'package:flutter/material.dart';

class AppColors {
  // === SHARED WARM LIGHT FOUNDATION (Original AVAN palette + Stella structure) ===
  static const Color background = Color(0xFFF9F6F0);       // Warm paper off-white
  static const Color surface = Color(0xFFFFFFFF);          // Pure white card background
  static const Color surfaceElevated = Color(0xFFEFE9E2);  // Soft warm beige
  static const Color border = Color(0x33C4B0A0);           // Subtle warm tan border
  static const Color borderBright = Color(0x66C4B0A0);     // Clearer tan border

  // Typography (Warm Espresso & Taupe)
  static const Color textPrimary = Color(0xFF4A3E37);      // Rich deep espresso brown
  static const Color textSecondary = Color(0xFF8C7F77);    // Sophisticated warm taupe
  static const Color textMuted = Color(0xFFA89B92);        // Soft muted taupe

  // Glass effects (Light frosted glass)
  static const Color glassOverlay = Color(0xD8FFFFFF);     // 85% white frosted overlay
  static const Color glassBorder = Color(0x66C4B0A0);      // Soft tan edge
  static const Color glassBorderBright = Color(0xB3C4B0A0);

  // Legacy aliases
  static const Color cardSurface = surface;
  static const Color softBeige = surfaceElevated;
  static const Color nudeAccent = Color(0xFFE2D6CC);
  static const Color tanAccent = Color(0xFFC4B0A0);
  static const Color borderSoft = border;
  static const Color buttonDark = Color(0xFF322822);
  static const Color iconColor = textPrimary;
  static const Color goldAccent = Color(0xFFCBA167);
  static const Color greenAccent = Color(0xFF319795);
  static const Color sleepDark = Color(0xFF151C26);
  static const Color glowAccent = Color(0x33CBA167);

  // === GROWTH MODE — Warm Off-white to Teal Mist ===
  static const Color growthPrimary = Color(0xFF1A365D);        // Sapphire header text accent
  static const Color growthAccent = Color(0xFF319795);         // Deep Teal accent
  static const Color growthAccentSoft = Color(0x26319795);     // Teal at 15% opacity
  static const Color growthGlow = Color(0x20319795);           // Soft teal glow
  static const Color growthCard = Color(0xFFFFFFFF);           // Clean white card
  static const Color growthStreak = Color(0xFFD69E2E);         // Warm Gold
  static const Color growthTextPrimary = textPrimary;
  static const Color growthTextSecondary = textSecondary;
  static const Color growthBackground = background;
  static const Color growthCardBackground = surface;
  static const Color growthSecondary = growthAccent;

  static const LinearGradient growthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF9F6F0), // Warm off-white
      Color(0xFFE6F4F1), // Soft teal mist
    ],
  );

  static const LinearGradient growthCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F9F8),
    ],
  );

  // === HEALING MODE — Warm Off-white to Rose Quartz Mist ===
  static const Color healingPrimary = Color(0xFF6B46C1);       // Soft Violet header accent
  static const Color healingAccent = Color(0xFFED64A6);        // Rose Quartz accent
  static const Color healingAccentSoft = Color(0x26ED64A6);    // Rose at 15% opacity
  static const Color healingGlow = Color(0x20ED64A6);          // Soft rose glow
  static const Color healingCard = Color(0xFFFFFFFF);          // Clean white card
  static const Color healingStreak = Color(0xFF9F7AEA);        // Lavender
  static const Color healingTextPrimary = textPrimary;
  static const Color healingTextSecondary = textSecondary;
  static const Color healingBackground = Color(0xFFFDF7F0);    // Warm gentle off-white
  static const Color healingCardBackground = surface;
  static const Color healingSecondary = healingAccent;

  static const LinearGradient healingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFDF7F0), // Gentle warm off-white
      Color(0xFFFDF0F5), // Soft rose mist
    ],
  );

  static const LinearGradient healingCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFCF2F6),
    ],
  );

  // === SHARED GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A3E37), Color(0xFF322822)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9F6F0), Color(0xFFEFE9E2)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFCBA167), Color(0xFFE2D6CC)],
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
