import 'package:flutter/material.dart';

class Skeuo {
  Skeuo._();

  static const bg = Color(0xFFF0F0F0);
  static const accent = Color(0xFF3B82F6);
  static const danger = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const text = Color(0xFF333333);
  static const textMuted = Color(0xFF8A8A8A);
  static const border = Color(0x80FFFFFF);

  static const shadowOut = [
    BoxShadow(color: Color(0xFFD1D1D1), offset: Offset(8, 8), blurRadius: 16),
    BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-8, -8), blurRadius: 16),
  ];

  static const shadowButton = [
    BoxShadow(color: Color(0xFFD1D1D1), offset: Offset(4, 4), blurRadius: 8),
    BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-4, -4), blurRadius: 8),
  ];

  static const shadowDial = [
    BoxShadow(color: Color(0xFFD1D1D1), offset: Offset(10, 10), blurRadius: 20),
    BoxShadow(
      color: Color(0xFFFFFFFF),
      offset: Offset(-10, -10),
      blurRadius: 20,
    ),
  ];

  static const dialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6E6E6), Color(0xFFFFFFFF)],
  );

  static const insetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE2E2E2), Color(0xFFF8F8F8)],
  );

  static const brushedMetal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
  );

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: bg,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: text)),
    );
  }
}
