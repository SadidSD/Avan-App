import 'package:flutter/material.dart';

class AppColors {
  // Warm, Calm, Minimal Color Palette
  static const Color background = Color(0xFFF9F6F0);      // Warmer, premium paper off-white
  static const Color cardSurface = Color(0xFFFFFFFF);     // Pure white card background
  static const Color softBeige = Color(0xFFEFE9E2);       // Warm soft beige, slightly richer
  static const Color nudeAccent = Color(0xFFE2D6CC);      // Deeper muted nude tone
  static const Color tanAccent = Color(0xFFC4B0A0);       // Warm tan detail accent
  static const Color borderSoft = Color(0x33C4B0A0);      // Subtle border tone with opacity

  // Typography & Dark Controls
  static const Color textPrimary = Color(0xFF4A3E37);     // Rich deep espresso brown
  static const Color textSecondary = Color(0xFF8C7F77);   // Sophisticated warm taupe
  static const Color buttonDark = Color(0xFF322822);      // Dark espresso pill button
  static const Color iconColor = Color(0xFF4A3E37);       // Primary icon color

  // Accents
  static const Color goldAccent = Color(0xFFCBA167);
  static const Color greenAccent = Color(0xFF7A8C76);
  static const Color sleepDark = Color(0xFF151C26);

  // --- Premium Additions ---
  
  // Shimmer / Glow
  static const Color glowAccent = Color(0x40CBA167);      // Soft gold glow

  // Glassmorphism Overlays
  static const Color glassOverlay = Color(0xB3FFFFFF);    // Frosted white overlay (70%)
  static const Color glassBorder = Color(0x4DFFFFFF);     // Light edge highlight for glass

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A3E37),
      Color(0xFF322822),
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF9F6F0),
      Color(0xFFEFE9E2),
    ],
  );
  
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFCBA167),
      Color(0xFFE2D6CC),
    ],
  );

  // --- Growth Mode Colors ---
  static const Color growthPrimary = Color(0xFF1A365D);
  static const Color growthSecondary = Color(0xFF319795);
  static const Color growthAccent = Color(0xFFD69E2E);
  static const Color growthBackground = Color(0xFFFFFFFF);
  static const Color growthTextPrimary = Color(0xFF1A202C);
  static const Color growthTextSecondary = Color(0xFF4A5568);
  static const Color growthCardBackground = Color(0xFFF7FAFC);

  // --- Healing Mode Colors ---
  static const Color healingPrimary = Color(0xFF6B46C1);
  static const Color healingSecondary = Color(0xFFED64A6);
  static const Color healingAccent = Color(0xFF9F7AEA);
  static const Color healingBackground = Color(0xFFFDF7F0);
  static const Color healingTextPrimary = Color(0xFF2D3748);
  static const Color healingTextSecondary = Color(0xFF718096);
  static const Color healingCardBackground = Color(0xFFFFFFFF);
}
