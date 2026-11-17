import 'package:flutter/material.dart';

/// Schriftrollen. Größen skalieren mit der Textgröße des Systems.
abstract final class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle title = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );

  /// Ordnet die Rollen dem Material-TextTheme zu.
  static TextTheme textTheme(Color color, Color mutedColor) => TextTheme(
    displaySmall: display.copyWith(color: color),
    titleLarge: title.copyWith(color: color),
    titleMedium: title.copyWith(fontSize: 18, color: color),
    bodyLarge: body.copyWith(color: color),
    bodyMedium: body.copyWith(fontSize: 15, color: color),
    labelLarge: label.copyWith(color: color),
    labelMedium: label.copyWith(fontSize: 12, color: color),
    bodySmall: caption.copyWith(color: mutedColor),
  );
}
