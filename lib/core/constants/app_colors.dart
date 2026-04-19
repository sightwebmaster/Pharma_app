import 'package:flutter/material.dart';

class AppColors {
  // ===== PRIMARY GREEN (from design tokens) =====
  static const Color primaryGreen  = Color(0xFF12B8A0); // T.green
  static const Color greenDark     = Color(0xFF0E9886); // T.greenDark
  static const Color greenMid      = Color(0xFF14C7AD); // T.greenMid
  static const Color greenSoft     = Color(0xFFE6F7F3); // T.greenSoft
  static const Color greenTint     = Color(0xFFF2FBF8); // T.greenTint

  // ===== KEEP BLUE ALIAS for pharmacien (kept as compat, same teal) =====
  static const Color primaryBlue   = Color(0xFF12B8A0);
  static const Color accentBlue    = Color(0xFF12B8A0);
  static const Color cardGreen     = Color(0xFF12B8A0);
  static const Color blueLight     = Color(0xFF14C7AD);
  static const Color blueSurface   = Color(0xFFE6F7F3);
  static const Color blueDeep      = Color(0xFF0E9886);

  // ===== NEUTRALS (warm — from design tokens) =====
  static const Color ink           = Color(0xFF0F1F1C); // T.ink
  static const Color textPrimary   = Color(0xFF1F2A29); // T.text
  static const Color textSecondary = Color(0xFF6B7776); // T.textMuted
  static const Color textFaint     = Color(0xFF9BA4A3); // T.textFaint
  static const Color border        = Color(0xFFE8ECEB); // T.line
  static const Color borderSoft    = Color(0xFFF1F3F2); // T.lineSoft
  static const Color background    = Color(0xFFF6F8F7); // T.bg
  static const Color surface       = Color(0xFFFFFFFF); // T.card
  static const Color surfaceAlt    = Color(0xFFF1F3F2); // T.lineSoft

  // Legacy aliases
  static const Color white         = surface;
  static const Color black         = ink;
  static const Color grey          = textFaint;
  static const Color lightGrey     = borderSoft;
  static const Color divider       = border;

  // ===== STATUS COLORS =====
  static const Color okBg          = Color(0xFFE6F7F3);
  static const Color okFg          = Color(0xFF0E9886);
  static const Color warnBg        = Color(0xFFFFF3E0);
  static const Color warnFg        = Color(0xFFC87A1F);
  static const Color errBg         = Color(0xFFFDECEC);
  static const Color errFg         = Color(0xFFD14343);
  static const Color infoBg        = Color(0xFFEEF2FF);
  static const Color infoFg        = Color(0xFF5B6FD4);
  static const Color lateBg        = Color(0xFFFEEBE6);
  static const Color lateFg        = Color(0xFFCC4A2F);

  // Legacy
  static const Color errorRed      = errFg;
  static const Color errorSurface  = errBg;
  static const Color success        = okFg;
  static const Color successSurface = okBg;
  static const Color warning        = warnFg;
  static const Color warningSurface = warnBg;
  static const Color info           = infoFg;
  static const Color infoSurface    = infoBg;
  static const Color amber          = warnFg;
  static const Color amberSurface   = warnBg;
  static const Color rose           = errFg;

  // ===== GRADIENTS =====
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment(-0.7, -1.0),
    end:   Alignment(0.7, 1.0),
    colors: [Color(0xFF14C7AD), Color(0xFF0E9886)],
  );

  // Alias
  static const LinearGradient patientGradient     = greenGradient;
  static const LinearGradient pharmacienGradient  = greenGradient;
  static const LinearGradient subtleGradient      = LinearGradient(
    begin: Alignment.topCenter,
    end:   Alignment.bottomCenter,
    colors: [Color(0xFFF2FBF8), Color(0xFFF6F8F7)],
  );

  // ===== SHADOWS =====
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0A10201E),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    const BoxShadow(
      color: Color(0x0D10201E),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowLg => [
    const BoxShadow(
      color: Color(0x0F10201E),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    const BoxShadow(
      color: Color(0x1410201E),
      blurRadius: 40,
      offset: Offset(0, 20),
    ),
  ];

  static List<BoxShadow> get greenShadow => [
    const BoxShadow(
      color: Color(0x4712B8A0),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
