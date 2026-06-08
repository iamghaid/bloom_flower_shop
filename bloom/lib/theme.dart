import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFFDF6EE);
  static const petal = Color(0xFFF5E6DA);
  static const rose = Color(0xFFC17B6B);
  static const roseDark = Color(0xFF8B5E52);
  static const bark = Color(0xFF3D2B1F);
  static const muted = Color(0xFF9B8880);
  static const white = Color(0xFFFFFFFF);
  static const leaf = Color(0xFF6B7C5E);

  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAEEE3), Color(0xFFFDF6EE)],
  );
}

class AppTypography {
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.cormorantGaramond(
        fontSize: _clamp(context, 48, 80),
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -1,
        color: AppColors.bark,
      );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.cormorantGaramond(
        fontSize: _clamp(context, 32, 52),
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.bark,
      );

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.cormorantGaramond(
        fontSize: _clamp(context, 22, 30),
        fontWeight: FontWeight.w500,
        color: AppColors.bark,
      );

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.mulish(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.75,
        color: AppColors.muted,
      );

  static TextStyle label(BuildContext context) =>
      GoogleFonts.mulish(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
        color: AppColors.rose,
      );

  static TextStyle price(BuildContext context) =>
      GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.roseDark,
      );

  static double _clamp(BuildContext context, double min, double max) {
    final w = MediaQuery.of(context).size.width;
    return (min + (max - min) * ((w - 360) / (1400 - 360))).clamp(min, max);
  }
}
