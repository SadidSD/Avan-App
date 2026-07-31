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
}
