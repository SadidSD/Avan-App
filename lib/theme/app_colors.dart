import 'package:flutter/material.dart';

class AppColors {
  // === DEEP MOCHA/BROWNISH FOUNDATION ===
  static const Color background = Color(0xFF1A110D);           // Deep mocha-black
  static const Color backgroundGradientTop = Color(0xFF2C1810); // Warm chocolate
  static const Color backgroundGradientBottom = Color(0xFF0F0A07); // Near-black espresso
  static const Color surface = Color(0x0FFFDDBE);              // Warm glass tint 6%
  static const Color surfaceElevated = Color(0x1AFFDDBE);      // Elevated glass 10%
  static const Color surfaceSolid = Color(0xFF251A14);         // Solid dark surface
  static const Color border = Color(0x1FFFDDBE);               // Warm edge 12%
  static const Color borderBright = Color(0x33FFDDBE);         // Brighter edge 20%

  // Typography (Cream & Tan)
  static const Color textPrimary = Color(0xFFF5E6D3);          // Warm cream
  static const Color textSecondary = Color(0xFFB8A089);        // Soft tan
  static const Color textMuted = Color(0xFF7A6650);            // Muted brown

  // Glass effects (Liquid Glass)
  static const Color glassOverlay = Color(0x0DFFFFFF);         // 5% white film
  static const Color glassBorder = Color(0x1AFFFFFF);          // 10% white edge
  static const Color glassBorderBright = Color(0x33FFFFFF);    // 20% white edge
  static const Color glassInnerShadow = Color(0x0D000000);     // Subtle inner depth

  // Premium Gold
  static const Color goldAccent = Color(0xFFCBA167);           // Warm premium gold
  static const Color goldGlow = Color(0x40CBA167);             // Gold glow 25%
  static const Color goldSoft = Color(0x1ACBA167);             // Gold tint 10%

  // Legacy aliases (kept for non-Home widgets compatibility)
  static const Color cardSurface = surfaceSolid;
  static const Color softBeige = surfaceElevated;
  static const Color nudeAccent = Color(0xFF3A2920);
  static const Color tanAccent = Color(0xFFB8A089);
  static const Color borderSoft = border;
  static const Color buttonDark = Color(0xFF0F0A07);
  static const Color iconColor = textPrimary;
  static const Color greenAccent = Color(0xFF52B788);
  static const Color sleepDark = Color(0xFF0A0705);
  static const Color glowAccent = Color(0x40CBA167);

  // === GROWTH MODE — Earthy Forest Green ===
  static const Color growthPrimary = Color(0xFF2D6A4F);         // Deep forest green
  static const Color growthAccent = Color(0xFF52B788);          // Sage / forest green
  static const Color growthAccentSoft = Color(0x2652B788);      // Green at 15%
  static const Color growthGlow = Color(0x4052B788);            // Green glow 25%
  static const Color growthCard = Color(0x0D52B788);            // Green glass tint
  static const Color growthStreak = Color(0xFFCBA167);          // Gold
  static const Color growthTextPrimary = textPrimary;
  static const Color growthTextSecondary = textSecondary;
  static const Color growthBackground = background;
  static const Color growthCardBackground = surfaceSolid;
  static const Color growthSecondary = growthAccent;

  static const LinearGradient growthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A2A1D), // Dark forest overlay
      Color(0xFF1A110D), // Deep mocha
      Color(0xFF0F0A07), // Near-black
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient growthCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A52B788), // Green tint
      Color(0x0DFFDDBE), // Warm tint
    ],
  );

  // === HEALING MODE — Blue-Green Teal ===
  static const Color healingPrimary = Color(0xFF1B7A7D);        // Deep teal
  static const Color healingAccent = Color(0xFF40C9A2);         // Blue-green teal
  static const Color healingAccentSoft = Color(0x2640C9A2);     // Teal at 15%
  static const Color healingGlow = Color(0x4040C9A2);           // Teal glow 25%
  static const Color healingCard = Color(0x0D40C9A2);           // Teal glass tint
  static const Color healingStreak = Color(0xFF40C9A2);         // Teal
  static const Color healingTextPrimary = textPrimary;
  static const Color healingTextSecondary = textSecondary;
  static const Color healingBackground = background;
  static const Color healingCardBackground = surfaceSolid;
  static const Color healingSecondary = healingAccent;

  static const LinearGradient healingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1F1F), // Deep teal overlay
      Color(0xFF1A110D), // Deep mocha
      Color(0xFF0F0A07), // Near-black
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient healingCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A40C9A2), // Teal tint
      Color(0x0DFFDDBE), // Warm tint
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
    colors: [Color(0xFF2C1810), Color(0xFF1A110D)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C1810), Color(0xFF0F0A07)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFCBA167), Color(0xFF52B788)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33CBA167), // Gold tint
      Color(0x1AFFDDBE), // Warm tint
      Color(0x33CBA167), // Gold tint
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
