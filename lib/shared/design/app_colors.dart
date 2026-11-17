import 'package:flutter/material.dart';

/// Farb-Tokens. Status wird nie nur über Farbe vermittelt,
/// sondern immer zusätzlich über Text oder Symbol.
abstract final class AppColors {
  // Hell
  static const Color primaryLight = Color(0xFF2F6B5E);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFF52616B);
  static const Color backgroundLight = Color(0xFFF7F8F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1B1F1E);
  static const Color onSurfaceMutedLight = Color(0xFF5B6360);
  static const Color outlineLight = Color(0xFFC9CFCC);

  // Dunkel
  static const Color primaryDark = Color(0xFF8FD3C1);
  static const Color onPrimaryDark = Color(0xFF00382F);
  static const Color secondaryDark = Color(0xFFB7C6CF);
  static const Color backgroundDark = Color(0xFF111413);
  static const Color surfaceDark = Color(0xFF1B1F1E);
  static const Color onSurfaceDark = Color(0xFFE2E6E4);
  static const Color onSurfaceMutedDark = Color(0xFFA9B1AE);
  static const Color outlineDark = Color(0xFF3F4744);

  // Status (gleich in hell und dunkel)
  static const Color statusOk = Color(0xFF2E7D4F);
  static const Color statusCaution = Color(0xFFB26A00);
  static const Color statusWarning = Color(0xFFB3261E);
}
