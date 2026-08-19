import 'package:flutter/material.dart';

class AppColors {
  // === WARM LIGHT BEIGE/CREAM FOUNDATION ===
  static const Color background = Color(0xFFFFF8F2);             // Warm cream white
  static const Color backgroundGradientTop = Color(0xFFFFF4EB);  // Soft peach cream
  static const Color backgroundGradientBottom = Color(0xFFFBF0E6); // Deeper warm cream
  static const Color surface = Color(0xFFFFFFFF);                // White card surface
  static const Color surfaceElevated = Color(0xFFFFF6EF);       // Slightly warm white
  static const Color surfaceSolid = Color(0xFFFFF3EB);          // Solid warm surface
  static const Color border = Color(0x1A6B4C3B);                // Soft brown border 10%
  static const Color borderBright = Color(0x266B4C3B);          // Slightly visible border

  // Typography (Dark Brown)
  static const Color textPrimary = Color(0xFF3D2C1E);            // Rich dark brown
  static const Color textSecondary = Color(0xFF8B7355);          // Medium warm brown
  static const Color textMuted = Color(0xFFB5A08A);              // Light muted brown

  // Glass effects (Light Glassmorphism)
  static const Color glassOverlay = Color(0x0D6B4C3B);          // 5% brown film
  static const Color glassBorder = Color(0x126B4C3B);           // 7% brown edge
  static const Color glassBorderBright = Color(0x1A6B4C3B);     // 10% brown edge
  static const Color glassInnerShadow = Color(0x08000000);      // Subtle shadow

  // Premium Gold
  static const Color goldAccent = Color(0xFFC4956A);             // Warm gold-brown
  static const Color goldGlow = Color(0x33C4956A);               // Gold glow 20%
  static const Color goldSoft = Color(0x1AC4956A);               // Gold tint 10%

  // Legacy aliases (kept for non-Home widgets compatibility)
  static const Color cardSurface = surface;
  static const Color softBeige = surfaceElevated;
  static const Color nudeAccent = Color(0xFFE8D5C4);
  static const Color tanAccent = Color(0xFF8B7355);
  static const Color borderSoft = border;
  static const Color buttonDark = Color(0xFF3D2C1E);
  static const Color iconColor = textPrimary;
  static const Color greenAccent = Color(0xFF52B788);
  static const Color sleepDark = Color(0xFF3D2C1E);
  static const Color glowAccent = Color(0x33C4956A);

  // === GROWTH MODE — Earthy Forest Green ===
  static const Color growthPrimary = Color(0xFF2D6A4F);          // Deep forest green
  static const Color growthAccent = Color(0xFF52B788);           // Sage / forest green
  static const Color growthAccentSoft = Color(0x2652B788);       // Green at 15%
  static const Color growthGlow = Color(0x3352B788);             // Green glow 20%
  static const Color growthCard = Color(0x0D52B788);             // Green glass tint
  static const Color growthStreak = Color(0xFFC4956A);           // Gold
  static const Color growthTextPrimary = textPrimary;
  static const Color growthTextSecondary = textSecondary;
  static const Color growthBackground = background;
  static const Color growthCardBackground = surface;
  static const Color growthSecondary = growthAccent;

  static const LinearGradient growthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF2FFF6),  // Very light minty cream
      Color(0xFFFFF8F2),  // Warm cream
      Color(0xFFFBF0E6),  // Deeper cream
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient growthCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1452B788),  // Green tint
      Color(0x0AFFF8F2),  // Warm tint
    ],
  );

  // === HEALING MODE — Blue-Green Teal ===
  static const Color healingPrimary = Color(0xFF1B7A7D);         // Deep teal
  static const Color healingAccent = Color(0xFF40C9A2);          // Blue-green teal
  static const Color healingAccentSoft = Color(0x2640C9A2);      // Teal at 15%
  static const Color healingGlow = Color(0x3340C9A2);            // Teal glow 20%
  static const Color healingCard = Color(0x0D40C9A2);            // Teal glass tint
  static const Color healingStreak = Color(0xFF40C9A2);          // Teal
  static const Color healingTextPrimary = textPrimary;
  static const Color healingTextSecondary = textSecondary;
  static const Color healingBackground = background;
  static const Color healingCardBackground = surface;
  static const Color healingSecondary = healingAccent;

  static const LinearGradient healingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0FFFE),  // Very light teal cream
      Color(0xFFFFF8F2),  // Warm cream
      Color(0xFFFBF0E6),  // Deeper cream
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient healingCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1440C9A2),  // Teal tint
      Color(0x0AFFF8F2),  // Warm tint
    ],
  );

  // === SHARED GRADIENTS ===
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundGradientTop, background, backgroundGradientBottom],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF4EB), Color(0xFFFFF8F2)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4EB), Color(0xFFFBF0E6)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC4956A), Color(0xFF52B788)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26C4956A),  // Gold tint
      Color(0x0DFFF8F2),  // Warm tint
      Color(0x26C4956A),  // Gold tint
    ],
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

  static Color cardTintForMode(bool isGrowth) =>
      isGrowth ? growthCard : healingCard;
}
