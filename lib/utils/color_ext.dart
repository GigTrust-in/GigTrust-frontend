import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Use instead of `withOpacity` to avoid deprecated APIs / precision loss.
  Color withOpacitySafe(double opacity) {
    final argb = toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return Color.fromRGBO(r, g, b, opacity.clamp(0.0, 1.0));
  }
}