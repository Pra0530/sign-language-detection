import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Primary hero gradient
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryPurple, AppColors.primaryTeal],
  );

  // Dark background gradient
  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgDark, AppColors.bgDarkSecondary, AppColors.bgDarkTertiary],
  );

  // Accent warm gradient
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentOrange, AppColors.accentAmber],
  );

  // Saffron-Green Indian gradient
  static const LinearGradient indian = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.saffron, AppColors.indiaGreen],
  );

  // Card gradient (subtle)
  static const LinearGradient cardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A6C3CE1),
      Color(0x0D00D4AA),
    ],
  );

  // Button gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryPurple, Color(0xFF8B5CF6)],
  );

  // Success gradient
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00D4AA)],
  );

  // Purple glow
  static const RadialGradient purpleGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x406C3CE1),
      Color(0x006C3CE1),
    ],
  );

  // Teal glow
  static const RadialGradient tealGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x4000D4AA),
      Color(0x0000D4AA),
    ],
  );

  // Shimmer gradient for loading effects
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0x00FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Nav bar gradient
  static const LinearGradient navBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xE6111328),
      Color(0xFF0A0E21),
    ],
  );
}
